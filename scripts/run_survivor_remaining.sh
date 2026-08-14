#!/bin/bash
# ============================================================
# run_survivor_remaining.sh — Train remaining survivor models
# Handles: SURVIVOR dataset (14 models missing best.pt)
#
# Run on MAIN container to fill the gap left by Stream B
# which has moved on to combined.
#
# Usage:
#   nohup bash scripts/run_survivor_remaining.sh > logs/survivor_remaining_$(date +%Y%m%d_%H%M%S).log 2>&1 &
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

echo "============================================================"
echo " MAIN CONTAINER — SURVIVOR REMAINING"
echo " Host: $(hostname)"
echo " Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"
echo ""

# All 28 survivor models — skip if best.pt exists
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

DATASET="survivor"
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
        --output "$PROJECT_ROOT/results/task_002_survivor.md"; then
        SUCCESS=$((SUCCESS + 1))
        echo " ✅ Done: $model/$DATASET"
    else
        FAILED=$((FAILED + 1))
        echo " ❌ Failed: $model/$DATASET"
    fi
done

echo ""
echo "============================================================"
echo " SURVIVOR REMAINING COMPLETE"
echo " Finished: $(date '+%Y-%m-%d %H:%M:%S')"
echo " Success: $SUCCESS | Skipped: $SKIPPED | Failed: $FAILED"
echo "============================================================"
