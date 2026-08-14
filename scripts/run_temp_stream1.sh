#!/bin/bash
# ============================================================
# run_temp_stream1.sh — Temp Container Stream 1
# Utilizes ~18 GB VRAM on Temp A100 GPU
# ============================================================

set -euo pipefail

PROJECT_ROOT="/workspace/projects/vision/turbid_review"
LOG_DIR="$PROJECT_ROOT/logs"
PYTHON="/workspace/miniconda3/envs/vision/bin/python"

mkdir -p "$LOG_DIR"
source /workspace/.secrets/api_keys.env 2>/dev/null || true
export PYTHONUNBUFFERED=1
export TURBID_BATCH_MAX=24
export TURBID_WORKERS=4

echo "============================================================"
echo " TEMP CONTAINER STREAM 1 STARTED: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"

MODELS=(
    yolov9m
    yolov9e
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
        --output "$PROJECT_ROOT/results/task_002_temp_stream1.md"
done

echo "============================================================"
echo " TEMP CONTAINER STREAM 1 COMPLETED: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"
