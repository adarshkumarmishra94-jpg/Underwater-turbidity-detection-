#!/bin/bash
# ============================================================
# run_temp_container.sh — Training script for temp container (172.30.0.24)
# Handles: COMBINED dataset (26 remaining models)
#
# This container has its own A100 40GB (completely idle).
# Workspace is shared (/workspace), so checkpoints are shared.
# Skip logic: check for best.pt before training each model.
#
# Usage (run on TEMP container):
#   nohup bash scripts/run_temp_container.sh > logs/temp_combined_$(date +%Y%m%d_%H%M%S).log 2>&1 &
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
export TURBID_BATCH_MAX=96
export TURBID_WORKERS=4

echo "============================================================"
echo " TEMP CONTAINER — COMBINED DATASET TRAINING"
echo " Host: $(hostname)"
echo " Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo " GPU: $(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null || echo 'A100')"
echo " Batch sizes: nano=128 small=96 medium=64 large=48 xlarge=32"
echo "============================================================"
echo ""

# Models to train on combined dataset
# Skip if best.pt already exists (in case another container got there first)
MODELS=(
    yolov3u
    yolov3-tinyu
    yolov5nu
    yolov5su
    yolov5mu
    yolov5lu
    yolov5xu
    yolov8n
    yolov8s
    yolov8m
    yolov8l
    yolov8x
    yolov9t
    yolov9s
    yolov9m
    yolov9c
    yolov9e
    yolov10n
    yolov10s
    yolov10m
    yolov10b
    yolov10l
    yolov10x
    yolo11n
    yolo11s
    yolo11m
    yolo11l
    yolo11x
)

DATASET="combined"
TOTAL=${#MODELS[@]}
SUCCESS=0
SKIPPED=0
FAILED=0

for i in "${!MODELS[@]}"; do
    model="${MODELS[$i]}"
    num=$((i + 1))
    ckpt="$PROJECT_ROOT/checkpoints/${model}_${DATASET}/weights/best.pt"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " [$num/$TOTAL] ${model}_${DATASET}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ -f "$ckpt" ]; then
        echo " SKIP — best.pt already exists"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    echo " $(date '+%H:%M:%S') Training $model on $DATASET..."
    if "$PYTHON" -u "$PROJECT_ROOT/train.py" \
        --model "$model" \
        --dataset "$DATASET" \
        --output "$PROJECT_ROOT/results/task_002_combined.md"; then
        SUCCESS=$((SUCCESS + 1))
        echo " ✅ Done: $model/$DATASET"
    else
        FAILED=$((FAILED + 1))
        echo " ❌ Failed: $model/$DATASET"
    fi
done

echo ""
echo "============================================================"
echo " COMBINED TRAINING COMPLETE"
echo " Finished: $(date '+%Y-%m-%d %H:%M:%S')"
echo " Success: $SUCCESS | Skipped: $SKIPPED | Failed: $FAILED"
echo "============================================================"
