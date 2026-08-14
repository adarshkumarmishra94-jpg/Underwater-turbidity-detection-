#!/bin/bash
# ============================================================
# smoke_test.sh — Validate ALL scripts before full runs
# ============================================================
# Runs each component with minimal data:
#   - 1 model (yolov8n) on 1 dataset (survivor — smallest)
#   - 1 epoch for training
#   - 10 images for inference
#   - Single model for profiling
#
# Usage: bash scripts/smoke_test.sh
# ============================================================

set -uo pipefail  # Don't use -e, we want to continue on failures

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_DIR="$PROJECT_ROOT/logs/smoketest_${TIMESTAMP}"

mkdir -p "$LOG_DIR"

PASS=0
FAIL=0
TOTAL=0

# Source API keys
source /workspace/.secrets/api_keys.env 2>/dev/null || true
export WANDB_MODE=disabled  # Don't log smoke tests to WandB

run_test() {
    local TEST_NAME="$1"
    local TEST_CMD="$2"
    local LOG_FILE="$LOG_DIR/${TEST_NAME}.log"

    TOTAL=$((TOTAL + 1))
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  [$TOTAL] SMOKE TEST: $TEST_NAME"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  CMD: $TEST_CMD"
    echo "  LOG: $LOG_FILE"
    echo ""

    START=$(date +%s)
    eval "$TEST_CMD" > "$LOG_FILE" 2>&1
    EXIT_CODE=$?
    END=$(date +%s)
    DURATION=$((END - START))

    if [ $EXIT_CODE -eq 0 ]; then
        PASS=$((PASS + 1))
        echo "  ✅ PASSED (${DURATION}s) — exit code: $EXIT_CODE"
    else
        FAIL=$((FAIL + 1))
        echo "  ❌ FAILED (${DURATION}s) — exit code: $EXIT_CODE"
        echo "  Last 10 lines:"
        tail -10 "$LOG_FILE" | sed 's/^/    /'
    fi

    return $EXIT_CODE
}

echo "============================================================"
echo " TURBID REVIEW — Smoke Test Suite"
echo " Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo " Logs: $LOG_DIR"
echo "============================================================"

# ── 1. Model Registry ─────────────────────────────────────
run_test "01_model_registry" \
    "conda run -n vision python $PROJECT_ROOT/models/model_registry.py"

# ── 2. Dataset Stats ──────────────────────────────────────
run_test "02_dataset_stats" \
    "conda run -n vision python $PROJECT_ROOT/data/dataset_stats.py"

# ── 3. Dataset Validation ─────────────────────────────────
run_test "03_prepare_datasets" \
    "conda run -n vision python $PROJECT_ROOT/data/prepare_datasets.py"

# ── 4. Test (Pretrained Eval) — 1 model, 1 dataset ───────
run_test "04_test_pretrained" \
    "conda run -n vision python $PROJECT_ROOT/test.py --model yolov8n --dataset survivor --output $LOG_DIR/smoke_task001.md"

# ── 5. Train — 1 model, 1 dataset, 2 epochs ──────────────
run_test "05_train_finetune" \
    "conda run -n vision python $PROJECT_ROOT/train.py --model yolov8n --dataset survivor --epochs 2 --output $LOG_DIR/smoke_task002.md"

# ── 6. Profile — 1 model only ────────────────────────────
run_test "06_profile_model" \
    "conda run -n vision python $PROJECT_ROOT/models/profile_model.py --model yolov8n.pt --num-runs 10 --output $LOG_DIR/smoke_profile.md"

# ── 7. Inference — trained checkpoint, 10 images, 1 size ─
# Check if smoke training produced a checkpoint
SMOKE_CKPT="$PROJECT_ROOT/checkpoints/yolov8n_survivor/weights/best.pt"
if [ -f "$SMOKE_CKPT" ]; then
    run_test "07_inference_benchmark" \
        "conda run -n vision python $PROJECT_ROOT/inference.py --model $SMOKE_CKPT --dataset survivor --imgsz 640 --max-images 10 --output $LOG_DIR/smoke_task003.md"
else
    echo ""
    echo "  ⚠️  Skipping inference test — no checkpoint from smoke training"
    echo "     (Expected at: $SMOKE_CKPT)"
    # Try with pretrained instead
    run_test "07_inference_pretrained" \
        "conda run -n vision python $PROJECT_ROOT/inference.py --model yolov8n.pt --dataset survivor --imgsz 640 --max-images 10 --output $LOG_DIR/smoke_task003.md"
fi

# ── 8. Export ONNX — single checkpoint ────────────────────
if [ -f "$SMOKE_CKPT" ]; then
    run_test "08_export_onnx" \
        "conda run -n vision python $PROJECT_ROOT/models/export_onnx.py --checkpoint $SMOKE_CKPT --output $LOG_DIR/smoke_exports"
else
    echo ""
    echo "  ⚠️  Skipping ONNX export — no checkpoint available"
fi

# ── 9. Verify result files were created ───────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  RESULT FILES CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for f in smoke_task001.md smoke_task002.md smoke_task003.md smoke_profile.md; do
    if [ -f "$LOG_DIR/$f" ]; then
        LINES=$(wc -l < "$LOG_DIR/$f")
        echo "  ✅ $f ($LINES lines)"
    else
        echo "  ⚠️  $f — not created"
    fi
done

# Check for dataset analysis
if [ -f "$PROJECT_ROOT/docs/dataset_analysis.md" ]; then
    LINES=$(wc -l < "$PROJECT_ROOT/docs/dataset_analysis.md")
    echo "  ✅ docs/dataset_analysis.md ($LINES lines)"
fi

# ── Summary ───────────────────────────────────────────────
echo ""
echo "============================================================"
echo " SMOKE TEST SUMMARY"
echo " Finished: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"
echo ""
echo "  Total:  $TOTAL"
echo "  Passed: $PASS ✅"
echo "  Failed: $FAIL ❌"
echo ""
echo "  All logs: $LOG_DIR/"
echo ""

# List all log files with sizes
echo "  Log files:"
ls -lh "$LOG_DIR/" | grep -v "^total" | awk '{print "    " $NF " (" $5 ")"}'
echo ""

if [ $FAIL -eq 0 ]; then
    echo "  🎉 ALL SMOKE TESTS PASSED — Ready for full runs!"
else
    echo "  ⚠️  $FAIL tests failed — review logs before full runs"
fi

echo "============================================================"

exit $FAIL
