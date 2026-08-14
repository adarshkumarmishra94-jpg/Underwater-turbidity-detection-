#!/usr/bin/env bash
# TensorRT edge benchmark for the Jetson Nano (JetPack 4.6 / TensorRT 8.0).
# This workflow never installs packages and uses /data for every remote artifact.

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TIMESTAMP="$(date -u +%Y%m%d_%H%M%S)"
LOG_DIR="$PROJECT_ROOT/logs"
RESULTS_DIR="$PROJECT_ROOT/results/edge"
REPORT="$PROJECT_ROOT/results/task_003_edge_inference.md"
REMOTE_ROOT="${JETSON_DATA_DIR:-/data/turbid_review}"
JETSON_TARGET="${JETSON_TARGET:-nvidia@10.0.16.65}"
MAX_IMAGES=50
WARMUP=5
WORKSPACE_MIB=256
PRECISION=fp16
RUN_ALL=false
KEEP_REMOTE=false
REQUESTED_MODELS=()
IMAGE_SIZES=(224 480 640)

declare -A DATASET_IMAGES=(
    [infra]="/workspace/datasets/turbid_water/_derived/ultralytics/infra/images/val"
    [survivor]="/workspace/datasets/turbid_water/_derived/ultralytics/survivor/images/val"
    [combined]="/workspace/datasets/turbid_water/_derived/yolo_underwater_detector/images/val"
)

usage() {
    cat <<'USAGE'

Usage:
  JETSON_PASSWORD=... bash scripts/run_edge.sh
  JETSON_PASSWORD=... bash scripts/run_edge.sh --model yolov8n_infra
  JETSON_PASSWORD=... bash scripts/run_edge.sh --all

Options:
  --model NAME       Benchmark one model; may be repeated.
  --all              Benchmark all 84 fine-tuned checkpoints.
  --sizes LIST       Comma-separated sizes (default: 224,480,640).
  --max-images N     Images per dataset (default: 50).
  --warmup N         Warm-up runs per engine (default: 5).
  --workspace N      TensorRT builder workspace in MiB (default: 256).
  --fp32             Build FP32 instead of FP16 engines.
  --keep-remote      Keep the last ONNX/engine for troubleshooting.
  -h, --help         Show this help.

Without --model/--all, the edge-focused set is used:
  yolov8n_infra, yolov3-tinyu_survivor, yolo11n_combined

Authentication uses an existing SSH key, or JETSON_PASSWORD/SSHPASS with
sshpass. The password is intentionally not stored in this repository.
USAGE
}

while (($#)); do
    case "$1" in
        --model)
            [[ $# -ge 2 ]] || { echo "--model requires a value" >&2; exit 2; }
            REQUESTED_MODELS+=("$2")
            shift 2
            ;;
        --all)
            RUN_ALL=true
            shift
            ;;
        --sizes)
            [[ $# -ge 2 ]] || { echo "--sizes requires a value" >&2; exit 2; }
            IFS=',' read -r -a IMAGE_SIZES <<< "$2"
            shift 2
            ;;
        --max-images)
            MAX_IMAGES="$2"
            shift 2
            ;;
        --warmup)
            WARMUP="$2"
            shift 2
            ;;
        --workspace)
            WORKSPACE_MIB="$2"
            shift 2
            ;;
        --fp32)
            PRECISION=fp32
            shift
            ;;
        --keep-remote)
            KEEP_REMOTE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

[[ "$MAX_IMAGES" =~ ^[1-9][0-9]*$ ]] || { echo "Invalid --max-images" >&2; exit 2; }
[[ "$WARMUP" =~ ^[0-9]+$ ]] || { echo "Invalid --warmup" >&2; exit 2; }
[[ "$WORKSPACE_MIB" =~ ^[1-9][0-9]*$ ]] || { echo "Invalid --workspace" >&2; exit 2; }
for size in "${IMAGE_SIZES[@]}"; do
    [[ "$size" =~ ^[1-9][0-9]*$ ]] || { echo "Invalid image size: $size" >&2; exit 2; }
done

if "$RUN_ALL"; then
    mapfile -t MODELS < <(
        find "$PROJECT_ROOT/checkpoints" -mindepth 3 -maxdepth 3 \
            -path '*/weights/best.pt' -printf '%h\n' |
        sed 's#/weights$##; s#.*/##' | sort
    )
elif ((${#REQUESTED_MODELS[@]})); then
    MODELS=("${REQUESTED_MODELS[@]}")
else
    MODELS=(yolov8n_infra yolov3-tinyu_survivor yolo11n_combined)
fi

((${#MODELS[@]})) || { echo "No models selected" >&2; exit 1; }

SSH=(ssh -o ConnectTimeout=10 -o ServerAliveInterval=15 -o ServerAliveCountMax=4)
SCP=(scp -q -o ConnectTimeout=10)
if [[ -n "${JETSON_PASSWORD:-}" ]]; then
    export SSHPASS="$JETSON_PASSWORD"
fi
if [[ -n "${SSHPASS:-}" ]]; then
    command -v sshpass >/dev/null || { echo "sshpass is required for password authentication" >&2; exit 1; }
    SSH=(sshpass -e "${SSH[@]}")
    SCP=(sshpass -e "${SCP[@]}")
fi

mkdir -p "$LOG_DIR" "$RESULTS_DIR"
LOCAL_TEMP="$(mktemp -d -p /tmp turbid-edge.XXXXXXXX)"
LOG_FILE="$LOG_DIR/edge_inference_${TIMESTAMP}.log"
exec > >(tee "$LOG_FILE") 2>&1

remote_cleanup() {
    if ! "$KEEP_REMOTE"; then
        "${SSH[@]}" "$JETSON_TARGET" \
            "find '$REMOTE_ROOT/models' -maxdepth 1 -type f \( -name '*.onnx' -o -name '*.plan' \) -delete" \
            >/dev/null 2>&1 || true
    fi
}

remote_final_cleanup() {
    remote_cleanup
    if ! "$KEEP_REMOTE"; then
        "${SSH[@]}" "$JETSON_TARGET" \
            "find '$REMOTE_ROOT/images' -mindepth 1 -type f -delete" \
            >/dev/null 2>&1 || true
    fi
}

cleanup() {
    remote_final_cleanup
    find "$LOCAL_TEMP" -mindepth 1 -delete 2>/dev/null || true
    rmdir "$LOCAL_TEMP" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

echo "Jetson edge inference started at $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "Target: $JETSON_TARGET"
echo "Models: ${MODELS[*]}"
echo "Sizes: ${IMAGE_SIZES[*]} | images/dataset: $MAX_IMAGES | precision: $PRECISION"

echo "[1/5] Checking the existing Jetson runtime (no installs)"
"${SSH[@]}" "$JETSON_TARGET" "bash -s" <<REMOTE_CHECK
set -eu
test -x /usr/src/tensorrt/bin/trtexec
python3 -c 'import cv2, numpy, tensorrt; print("TensorRT=" + tensorrt.__version__ + ", OpenCV=" + cv2.__version__ + ", NumPy=" + numpy.__version__)'
df -h / /data
free -h
mkdir -p '$REMOTE_ROOT/models' '$REMOTE_ROOT/images' '$REMOTE_ROOT/results' '$REMOTE_ROOT/scripts'
REMOTE_CHECK

echo "[2/5] Deploying the lightweight TensorRT runner"
"${SCP[@]}" "$PROJECT_ROOT/edge_inference/inference_trt.py" \
    "$JETSON_TARGET:$REMOTE_ROOT/scripts/inference_trt.py"

declare -A STAGED_DATASETS=()

stage_images() {
    local dataset="$1"
    local source_dir="${DATASET_IMAGES[$dataset]}"
    local remote_dir="$REMOTE_ROOT/images/$dataset"
    local -a images=()

    [[ -d "$source_dir" ]] || { echo "Missing image directory: $source_dir" >&2; return 1; }
    mapfile -d '' -t images < <(
        find -L "$source_dir" -maxdepth 1 -type f \
            \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.bmp' \) \
            -print0 | sort -z | head -z -n "$MAX_IMAGES"
    )
    ((${#images[@]})) || { echo "No images found for $dataset" >&2; return 1; }

    echo "  Staging ${#images[@]} $dataset images once"
    "${SSH[@]}" "$JETSON_TARGET" \
        "mkdir -p '$remote_dir' && find '$remote_dir' -maxdepth 1 -type f -delete"
    "${SCP[@]}" "${images[@]}" "$JETSON_TARGET:$remote_dir/"
    STAGED_DATASETS[$dataset]=1
}

write_failure() {
    local output="$1" model="$2" dataset="$3" size="$4" message="$5"
    python3 - "$output" "$model" "$dataset" "$size" "$PRECISION" "$message" <<'PY'
import json
import sys
path, model, dataset, size, precision, message = sys.argv[1:]
with open(path, "w") as handle:
    json.dump({"status": "failed", "model": model, "dataset": dataset,
               "imgsz": int(size), "precision": precision, "error": message},
              handle, indent=2, sort_keys=True)
    handle.write("\n")
PY
}

echo "[3/5] Exporting, transferring, and benchmarking one model at a time"
for model in "${MODELS[@]}"; do
    dataset="${model##*_}"
    if [[ -z "${DATASET_IMAGES[$dataset]+present}" ]]; then
        echo "Cannot infer dataset from model name: $model" >&2
        exit 1
    fi
    checkpoint="$PROJECT_ROOT/checkpoints/$model/weights/best.pt"
    [[ -f "$checkpoint" ]] || { echo "Missing checkpoint: $checkpoint" >&2; exit 1; }

    if [[ -z "${STAGED_DATASETS[$dataset]:-}" ]]; then
        stage_images "$dataset"
    fi

    local_onnx="$LOCAL_TEMP/${model}_dynamic.onnx"
    remote_onnx="$REMOTE_ROOT/models/${model}_dynamic.onnx"
    remote_cleanup
    model_export_mode=dynamic
    if [[ "$model" == yolov3* ]]; then
        # TensorRT 8.0 requires YOLOv3's dynamic Pad inputs to be initializers.
        model_export_mode=static
        echo "  [$model] Using fixed-shape exports for TensorRT 8.0 legacy Pad compatibility"
    else
        echo "  [$model] Exporting one dynamic ONNX artifact"
        conda run -n vision python "$PROJECT_ROOT/models/export_onnx.py" \
            --checkpoint "$checkpoint" --output "$local_onnx" \
            --dynamic --no-simplify --imgsz 640
        conda run -n vision python "$PROJECT_ROOT/edge_inference/patch_onnx_trt8.py" "$local_onnx"
        echo "  [$model] Transferring $(du -h "$local_onnx" | awk '{print $1}') ONNX"
        "${SCP[@]}" "$local_onnx" "$JETSON_TARGET:$remote_onnx"
    fi

    for size in "${IMAGE_SIZES[@]}"; do
        remote_engine="$REMOTE_ROOT/models/${model}_${size}_${PRECISION}.plan"
        remote_result="$REMOTE_ROOT/results/edge_${model}_${size}.json"
        remote_build_log="$REMOTE_ROOT/results/build_${model}_${size}.log"
        remote_timing_cache="$REMOTE_ROOT/results/tensorrt_timing.cache"
        local_result="$RESULTS_DIR/edge_${model}_${size}.json"
        precision_flag=()
        [[ "$PRECISION" == fp16 ]] && precision_flag=(--fp16)

        if [[ "$model_export_mode" == static ]]; then
            local_static_onnx="$LOCAL_TEMP/${model}_${size}_static.onnx"
            echo "  [$model @ $size] Exporting and transferring a fixed-shape ONNX"
            conda run -n vision python "$PROJECT_ROOT/models/export_onnx.py" \
                --checkpoint "$checkpoint" --output "$local_static_onnx" \
                --imgsz "$size"
            conda run -n vision python "$PROJECT_ROOT/edge_inference/fold_static_pads.py" \
                "$local_static_onnx"
            "${SCP[@]}" "$local_static_onnx" "$JETSON_TARGET:$remote_onnx"
            rm -f "$local_static_onnx"
            shape_flags=""
        else
            shape_flags="--minShapes=images:1x3x${size}x${size} --optShapes=images:1x3x${size}x${size} --maxShapes=images:1x3x${size}x${size}"
        fi

        echo "  [$model @ $size] Building the TensorRT engine on-device"
        "${SSH[@]}" "$JETSON_TARGET" "rm -f '$remote_result' '$remote_engine'"
        if ! "${SSH[@]}" "$JETSON_TARGET" \
            "/usr/src/tensorrt/bin/trtexec --onnx='$remote_onnx' --saveEngine='$remote_engine' --buildOnly --workspace='$WORKSPACE_MIB' --minTiming=1 --avgTiming=1 --timingCacheFile='$remote_timing_cache' ${precision_flag[*]} $shape_flags >'$remote_build_log' 2>&1"; then
            if [[ "$model_export_mode" == dynamic ]]; then
                echo "  [$model @ $size] Dynamic build failed; retrying once with a fixed-shape ONNX"
                model_export_mode=static
                local_static_onnx="$LOCAL_TEMP/${model}_${size}_static.onnx"
                conda run -n vision python "$PROJECT_ROOT/models/export_onnx.py" \
                    --checkpoint "$checkpoint" --output "$local_static_onnx" \
                    --imgsz "$size"
                conda run -n vision python "$PROJECT_ROOT/edge_inference/fold_static_pads.py" \
                    "$local_static_onnx"
                "${SCP[@]}" "$local_static_onnx" "$JETSON_TARGET:$remote_onnx"
                rm -f "$local_static_onnx"
                if ! "${SSH[@]}" "$JETSON_TARGET" \
                    "/usr/src/tensorrt/bin/trtexec --onnx='$remote_onnx' --saveEngine='$remote_engine' --buildOnly --workspace='$WORKSPACE_MIB' --minTiming=1 --avgTiming=1 --timingCacheFile='$remote_timing_cache' ${precision_flag[*]} >'$remote_build_log' 2>&1"; then
                    echo "  [$model @ $size] Fixed-shape TensorRT build also failed"
                    "${SSH[@]}" "$JETSON_TARGET" "tail -40 '$remote_build_log'" || true
                    write_failure "$local_result" "$model" "$dataset" "$size" "TensorRT engine build failed; see $remote_build_log"
                    continue
                fi
            else
                echo "  [$model @ $size] TensorRT build failed"
                "${SSH[@]}" "$JETSON_TARGET" "tail -40 '$remote_build_log'" || true
                write_failure "$local_result" "$model" "$dataset" "$size" "TensorRT engine build failed; see $remote_build_log"
                continue
            fi
        fi

        echo "  [$model @ $size] Running $MAX_IMAGES real images"
        if ! "${SSH[@]}" "$JETSON_TARGET" \
            "python3 '$REMOTE_ROOT/scripts/inference_trt.py' --engine '$remote_engine' --images '$REMOTE_ROOT/images/$dataset' --output '$remote_result' --model-name '$model' --dataset '$dataset' --imgsz '$size' --precision '$PRECISION' --max-images '$MAX_IMAGES' --warmup '$WARMUP'"; then
            echo "  [$model @ $size] Inference runner reported failure"
        fi
        if ! "${SCP[@]}" "$JETSON_TARGET:$remote_result" "$local_result"; then
            write_failure "$local_result" "$model" "$dataset" "$size" "Remote result was not produced"
        fi
        "${SSH[@]}" "$JETSON_TARGET" \
            "find '$REMOTE_ROOT/models' -maxdepth 1 -type f -name '*.plan' -delete; rm -f '$remote_result'" || true
    done

    "${SSH[@]}" "$JETSON_TARGET" "rm -f '$remote_onnx'" || true
    rm -f "$local_onnx"
done

echo "[4/5] Generating the consolidated report"
python3 "$PROJECT_ROOT/edge_inference/generate_report.py" \
    --results-dir "$RESULTS_DIR" --output "$REPORT"

echo "[5/5] Final storage check and cleanup"
remote_final_cleanup
"${SSH[@]}" "$JETSON_TARGET" "df -h / /data; find '$REMOTE_ROOT' -maxdepth 2 -type f -printf '%s %p\n' | sort -n"

echo "Completed: $REPORT"
echo "Raw results: $RESULTS_DIR"
echo "Log: $LOG_FILE"
