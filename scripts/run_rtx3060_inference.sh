#!/usr/bin/env bash
# Run the complete fine-tuned benchmark on an NVIDIA RTX 3060 without
# overwriting the existing A100 or Jetson reports.

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TIMESTAMP="$(date -u +%Y%m%d_%H%M%S)"
PYTHON_BIN="${PYTHON_BIN:-python3}"
CHECKPOINTS_DIR="${FINETUNED_DIR:-$PROJECT_ROOT/final_checkpoints/finetuned}"
INFRA_DIR="${INFRA_IMAGES:-$PROJECT_ROOT/datasets/infra/images/val}"
SURVIVOR_DIR="${SURVIVOR_IMAGES:-$PROJECT_ROOT/datasets/survivor/images/val}"
COMBINED_DIR="${COMBINED_IMAGES:-$PROJECT_ROOT/datasets/combined/images/val}"
DEVICE="${DEVICE:-0}"
OUTPUT="$PROJECT_ROOT/results/task_003_inference_rtx3060.md"
LOG_DIR="$PROJECT_ROOT/logs"

usage() {
    cat <<'USAGE'
Usage:
  bash scripts/run_rtx3060_inference.sh

Default dataset layout (relative to the cloned repository):
  datasets/infra/images/val       (940 images)
  datasets/survivor/images/val    (218 images)
  datasets/combined/images/val  (3,169 images)

To use data stored elsewhere:
  bash scripts/run_rtx3060_inference.sh \
    --checkpoints-dir /path/to/final_checkpoints/finetuned \
    --infra-images /path/to/infra/images/val \
    --survivor-images /path/to/survivor/images/val \
    --combined-images /path/to/combined/images/val

The same paths can be supplied through FINETUNED_DIR, INFRA_IMAGES,
SURVIVOR_IMAGES, and COMBINED_IMAGES. Extra arguments such as
`--max-images 10` or `--imgsz 640` are passed to inference.py.
USAGE
}

PASSTHROUGH=()
while (($#)); do
    case "$1" in
        --checkpoints-dir)
            CHECKPOINTS_DIR="$2"
            shift 2
            ;;
        --infra-images)
            INFRA_DIR="$2"
            shift 2
            ;;
        --survivor-images)
            SURVIVOR_DIR="$2"
            shift 2
            ;;
        --combined-images)
            COMBINED_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            PASSTHROUGH+=("$1")
            shift
            ;;
    esac
done

[[ -d "$CHECKPOINTS_DIR" ]] || {
    echo "Missing fine-tuned checkpoint directory: $CHECKPOINTS_DIR" >&2
    echo "Download final_checkpoints/finetuned first (84 .pt files)." >&2
    exit 1
}
for entry in \
    "infra|940|$INFRA_DIR" \
    "survivor|218|$SURVIVOR_DIR" \
    "combined|3169|$COMBINED_DIR"; do
    IFS='|' read -r name expected path <<< "$entry"
    [[ -n "$path" && -d "$path" ]] || {
        echo "Missing $name validation image directory: ${path:-<not supplied>}" >&2
        usage >&2
        exit 1
    }
    if ! find -L "$path" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.bmp' \) \
        -print -quit | grep -q .; then
        echo "No supported validation images found for $name in $path" >&2
        exit 1
    fi
    image_count="$(find -L "$path" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.bmp' \) \
        -printf '.' | wc -c)"
    if [[ "$image_count" -ne "$expected" ]]; then
        echo "Expected $expected $name validation images, found $image_count in $path" >&2
        echo "See docs/dataset_sources.md for the required prepared benchmark layout." >&2
        exit 1
    fi
done

mapfile -t CHECKPOINTS < <(
    find "$CHECKPOINTS_DIR" -maxdepth 1 -type f -name '*.pt' -printf '%f\n' | sort
)
if ((${#CHECKPOINTS[@]} != 84)); then
    echo "Expected 84 flat fine-tuned checkpoints, found ${#CHECKPOINTS[@]} in $CHECKPOINTS_DIR" >&2
    exit 1
fi
for dataset in infra survivor combined; do
    count="$(find "$CHECKPOINTS_DIR" -maxdepth 1 -type f -name "*_${dataset}.pt" -printf '.' | wc -c)"
    if [[ "$count" -ne 28 ]]; then
        echo "Expected 28 $dataset checkpoints, found $count in $CHECKPOINTS_DIR" >&2
        exit 1
    fi
done

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/inference_rtx3060_${TIMESTAMP}.log"

BENCHMARK_DEVICE="$DEVICE" "$PYTHON_BIN" - <<'PY'
import os
import sys
import torch
from ultralytics import YOLO

if not torch.cuda.is_available():
    raise SystemExit("CUDA is not available in this Python environment")
device = os.environ["BENCHMARK_DEVICE"].lower()
if device.startswith("cuda:"):
    index = int(device.split(":", 1)[1])
elif device.isdigit():
    index = int(device)
else:
    raise SystemExit("DEVICE must be a CUDA index such as 0 or cuda:0")
name = torch.cuda.get_device_name(index)
if "3060" not in name:
    raise SystemExit("Expected an RTX 3060, detected: {}".format(name))
print("Python: {}".format(sys.version.split()[0]))
print("PyTorch: {}".format(torch.__version__))
print("CUDA runtime: {}".format(torch.version.cuda))
print("CUDA device: {}".format(index))
print("GPU: {}".format(name))
print("Ultralytics import: OK")
PY

echo "Starting 84-model × 3-resolution RTX 3060 benchmark"
echo "Checkpoints: $CHECKPOINTS_DIR"
echo "Results: $OUTPUT"

export PYTHONUNBUFFERED=1
"$PYTHON_BIN" -u "$PROJECT_ROOT/inference.py" \
    --all-checkpoints \
    --checkpoints-dir "$CHECKPOINTS_DIR" \
    --infra-images "$INFRA_DIR" \
    --survivor-images "$SURVIVOR_DIR" \
    --combined-images "$COMBINED_DIR" \
    --device "$DEVICE" \
    --output "$OUTPUT" \
    "${PASSTHROUGH[@]}" 2>&1 | tee "$LOG_FILE"

echo "Completed: $OUTPUT"
echo "Raw JSON: ${OUTPUT%.md}.json"
echo "Log: $LOG_FILE"
