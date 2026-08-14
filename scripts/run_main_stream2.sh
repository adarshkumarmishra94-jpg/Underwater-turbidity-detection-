#!/bin/bash
# ============================================================
# run_main_stream2.sh — Parallel training stream on MAIN container
# Utilizes the remaining ~23 GB VRAM on Main A100 GPU
# Trains remaining combined models in parallel with Stream 1
# ============================================================

set -euo pipefail

PROJECT_ROOT="/workspace/projects/vision/turbid_review"
LOG_DIR="$PROJECT_ROOT/logs"
PYTHON="/workspace/miniconda3/envs/vision/bin/python"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$LOG_DIR"
source /workspace/.secrets/api_keys.env 2>/dev/null || true
export PYTHONUNBUFFERED=1
export WANDB_PROJECT="turbid_review"
export PYTORCH_CUDA_ALLOC_CONF="expandable_segments:True"
export TURBID_BATCH_MAX=16
export TURBID_WORKERS=4

echo "============================================================"
echo " MAIN CONTAINER STREAM 2 — PARALLEL COMBINED TRAINING"
echo " Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo " Target: Maximize A100 VRAM saturation"
echo "============================================================"

# Reverse order to meet Stream 1 in the middle
MODELS=(
    yolo11x
    yolov10x
    yolov9e
    yolov9m
)

DATASET="combined"

for model in "${MODELS[@]}"; do
    ckpt="$PROJECT_ROOT/checkpoints/${model}_${DATASET}/weights/best.pt"
    if [ -f "$ckpt" ]; then
        echo " SKIP — $model on $DATASET already completed"
        continue
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " Training $model on $DATASET..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    "$PYTHON" -u "$PROJECT_ROOT/train.py" \
        --model "$model" \
        --dataset "$DATASET" \
        --output "$PROJECT_ROOT/results/task_002_combined_stream2.md"
done

echo ""
echo "============================================================"
echo " MAIN CONTAINER STREAM 2 COMPLETE: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"
