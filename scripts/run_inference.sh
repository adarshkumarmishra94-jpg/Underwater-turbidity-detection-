#!/bin/bash
# ============================================================
# run_inference.sh — Task 3a: A100 inference benchmark
# ============================================================
# Usage:
#   nohup bash scripts/run_inference.sh > logs/inference_$(date +%Y%m%d_%H%M%S).log 2>&1 &
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_DIR="$PROJECT_ROOT/logs"

mkdir -p "$LOG_DIR"

echo "============================================================"
echo " TASK 3a — A100 Inference Benchmark"
echo " Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"

# Source API keys
source /workspace/.secrets/api_keys.env 2>/dev/null || true

export PYTHONUNBUFFERED=1

EXTRA_ARGS="${@}"

# Run inference benchmark on all fine-tuned checkpoints (unbuffered)
/workspace/miniconda3/envs/vision/bin/python -u "$PROJECT_ROOT/inference.py" \
    --all-checkpoints \
    --device 0 \
    --output "$PROJECT_ROOT/results/task_003_inference.md" \
    $EXTRA_ARGS 2>&1 | tee "$LOG_DIR/inference_a100_${TIMESTAMP}.log"

echo ""
echo "============================================================"
echo " TASK 3a — Complete"
echo " Finished: $(date '+%Y-%m-%d %H:%M:%S')"
echo " Results: $PROJECT_ROOT/results/task_003_inference.md"
echo " Log: $LOG_DIR/inference_a100_${TIMESTAMP}.log"
echo "============================================================"
