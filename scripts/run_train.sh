#!/bin/bash
# ============================================================
# run_train.sh — Task 2: Fine-tune YOLO models
# ============================================================
# Usage:
#   nohup bash scripts/run_train.sh > logs/task2_$(date +%Y%m%d_%H%M%S).log 2>&1 &
#
# Run single model:
#   nohup bash scripts/run_train.sh --model yolov8n > logs/train_yolov8n_$(date +%Y%m%d_%H%M%S).log 2>&1 &
# Run single dataset:
#   nohup bash scripts/run_train.sh --dataset infra > logs/train_infra_$(date +%Y%m%d_%H%M%S).log 2>&1 &
# Override epochs:
#   bash scripts/run_train.sh --model yolov8n --dataset infra --epochs 10
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_DIR="$PROJECT_ROOT/logs"

mkdir -p "$LOG_DIR"

echo "============================================================"
echo " TASK 2 — Fine-tune YOLO Models"
echo " Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"

# Source API keys for WandB
source /workspace/.secrets/api_keys.env 2>/dev/null || true

export PYTHONUNBUFFERED=1

# Pass through any arguments
EXTRA_ARGS="${@}"

# Run training using vision env python directly (unbuffered)
/workspace/miniconda3/envs/vision/bin/python -u "$PROJECT_ROOT/train.py" \
    --output "$PROJECT_ROOT/results/task_002_finetuned_eval.md" \
    $EXTRA_ARGS 2>&1 | tee "$LOG_DIR/train_${TIMESTAMP}.log"

echo ""
echo "============================================================"
echo " TASK 2 — Complete"
echo " Finished: $(date '+%Y-%m-%d %H:%M:%S')"
echo " Results: $PROJECT_ROOT/results/task_002_finetuned_eval.md"
echo " Checkpoints: $PROJECT_ROOT/checkpoints/"
echo " Log: $LOG_DIR/train_${TIMESTAMP}.log"
echo "============================================================"
