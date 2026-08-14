#!/bin/bash
# ============================================================
# run_post_training.sh — Task 3 + ONNX export pipeline
# Runs AFTER Task 2 (fine-tuning) completes.
#
# Steps:
#   1. A100 Inference benchmarks (224, 480, 640) on all fine-tuned checkpoints
#   2. ONNX export of all best.pt checkpoints (for Jetson Nano)
#   3. Profile all models (FLOPs, params, speed)
#
# Usage:
#   nohup bash scripts/run_post_training.sh > logs/post_training_$(date +%Y%m%d_%H%M%S).log 2>&1 &
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_DIR="$PROJECT_ROOT/logs"
PYTHON="/workspace/miniconda3/envs/vision/bin/python"

mkdir -p "$LOG_DIR"

source /workspace/.secrets/api_keys.env 2>/dev/null || true
export PYTHONUNBUFFERED=1

header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

echo "============================================================"
echo " POST-TRAINING PIPELINE"
echo " Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"

# ── Step 1: A100 Inference Benchmark ──────────────────────────
header "STEP 1 — A100 Inference Benchmark (224 / 480 / 640)"

"$PYTHON" -u "$PROJECT_ROOT/inference.py" \
    --all-checkpoints \
    --device 0 \
    --output "$PROJECT_ROOT/results/task_003_inference.md" \
    2>&1 | tee "$LOG_DIR/inference_a100_${TIMESTAMP}.log"

echo ""
echo "  ✅ Inference benchmark complete"
echo "     Results: $PROJECT_ROOT/results/task_003_inference.md"

# ── Step 2: ONNX Export ───────────────────────────────────────
header "STEP 2 — ONNX Export (all checkpoints → checkpoints/exports/)"

"$PYTHON" -u "$PROJECT_ROOT/models/export_onnx.py" \
    --all-checkpoints \
    --output "$PROJECT_ROOT/checkpoints/exports" \
    2>&1 | tee "$LOG_DIR/onnx_export_${TIMESTAMP}.log"

echo ""
echo "  ✅ ONNX export complete"
echo "     Models: $PROJECT_ROOT/checkpoints/exports/"

# ── Step 3: Model Profiling (FLOPs, Params) ───────────────────
header "STEP 3 — Model Profiling (pretrained + fine-tuned)"

"$PYTHON" -u "$PROJECT_ROOT/models/profile_model.py" \
    --all-checkpoints \
    --output "$PROJECT_ROOT/results/model_profiles_finetuned.md" \
    2>&1 | tee "$LOG_DIR/profile_finetuned_${TIMESTAMP}.log" || true

echo ""
echo "  ✅ Profiling complete"
echo "     Results: $PROJECT_ROOT/results/model_profiles_finetuned.md"

# ── Summary ───────────────────────────────────────────────────
echo ""
echo "============================================================"
echo " POST-TRAINING PIPELINE COMPLETE"
echo " Finished: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"
echo ""
echo "  Next step: Jetson Nano edge inference"
echo "  When Jetson is free, transfer ONNX models and run:"
echo "    bash scripts/run_edge.sh"
echo ""
