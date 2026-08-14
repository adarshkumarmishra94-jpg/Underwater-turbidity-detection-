#!/bin/bash
# ============================================================
# run_missing_infra.sh — Train 7 missing infra models
# Models: yolov9s, yolov9m, yolov9e, yolov10n, yolov10s, yolov10m, yolov10b
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
export TURBID_WORKERS=2

echo "============================================================"
echo " TRAINING MISSING INFRA MODELS"
echo " Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"

MISSING_MODELS=(
    yolov9s
    yolov9m
    yolov9e
    yolov10n
    yolov10s
    yolov10m
    yolov10b
)

DATASET="infra"

for model in "${MISSING_MODELS[@]}"; do
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
        --output "$PROJECT_ROOT/results/task_002_infra_missing.md"
done

echo ""
echo "============================================================"
echo " ALL MISSING INFRA MODELS COMPLETE: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"
