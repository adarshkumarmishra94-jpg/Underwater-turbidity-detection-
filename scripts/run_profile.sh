#!/bin/bash
# ============================================================
# run_profile.sh — Profile all models: FLOPs, params, memory, latency
# ============================================================
# Usage:
#   nohup bash scripts/run_profile.sh > logs/profile_$(date +%Y%m%d_%H%M%S).log 2>&1 &
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_DIR="$PROJECT_ROOT/logs"

mkdir -p "$LOG_DIR"

echo "============================================================"
echo " Model Profiling — FLOPs, Params, Memory, Latency"
echo " Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"

source /workspace/.secrets/api_keys.env 2>/dev/null || true

export PYTHONUNBUFFERED=1

# Profile all pretrained models (unbuffered)
echo ""
echo "[1/2] Profiling pretrained models..."
/workspace/miniconda3/envs/vision/bin/python -u "$PROJECT_ROOT/models/profile_model.py" \
    --all-models \
    --output "$PROJECT_ROOT/results/model_profiles_pretrained.md" \
    2>&1 | tee "$LOG_DIR/profile_pretrained_${TIMESTAMP}.log"

# Profile all fine-tuned checkpoints (if they exist)
CKPT_COUNT=$(find "$PROJECT_ROOT/checkpoints" -name "best.pt" 2>/dev/null | wc -l)
if [ "$CKPT_COUNT" -gt 0 ]; then
    echo ""
    echo "[2/2] Profiling fine-tuned checkpoints..."
    /workspace/miniconda3/envs/vision/bin/python -u "$PROJECT_ROOT/models/profile_model.py" \
        --all-checkpoints \
        --output "$PROJECT_ROOT/results/model_profiles_finetuned.md" \
        2>&1 | tee "$LOG_DIR/profile_finetuned_${TIMESTAMP}.log"
else
    echo ""
    echo "[2/2] No fine-tuned checkpoints found — skipping"
fi

echo ""
echo "============================================================"
echo " Profiling — Complete"
echo " Finished: $(date '+%Y-%m-%d %H:%M:%S')"
echo " Results: $PROJECT_ROOT/results/model_profiles_*.md"
echo "============================================================"
