#!/bin/bash
# ============================================================
# run_test.sh — Task 1: Pretrained YOLO evaluation
# ============================================================
# Usage:
#   nohup bash scripts/run_test.sh > logs/task1_$(date +%Y%m%d_%H%M%S).log 2>&1 &
#
# Run single model:
#   bash scripts/run_test.sh --model yolov8n
# Run single dataset:
#   bash scripts/run_test.sh --dataset infra
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_DIR="$PROJECT_ROOT/logs"

mkdir -p "$LOG_DIR"

echo "============================================================"
echo " TASK 1 — Pretrained YOLO Model Evaluation"
echo " Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"

# Source API keys for WandB
source /workspace/.secrets/api_keys.env 2>/dev/null || true

export PYTHONUNBUFFERED=1

# Pass through any arguments (--model, --dataset)
EXTRA_ARGS="${@}"

# Run evaluation using vision env python directly (unbuffered)
/workspace/miniconda3/envs/vision/bin/python -u "$PROJECT_ROOT/test.py" \
    --output "$PROJECT_ROOT/results/task_001_pretrained_eval.md" \
    $EXTRA_ARGS 2>&1 | tee "$LOG_DIR/test_pretrained_${TIMESTAMP}.log"

echo ""
echo "============================================================"
echo " TASK 1 — Complete"
echo " Finished: $(date '+%Y-%m-%d %H:%M:%S')"
echo " Results: $PROJECT_ROOT/results/task_001_pretrained_eval.md"
echo " Log: $LOG_DIR/test_pretrained_${TIMESTAMP}.log"
echo "============================================================"
