#!/bin/bash
# ============================================================
# run_parallel_train.sh
# Launches 3 parallel training streams (one per dataset)
# using the remaining VRAM alongside the current infra run.
#
# Strategy:
#   Stream A (infra):    resumes from model 13 (yolov9t) onwards
#                        current process already handles models 1-12
#   Stream B (survivor): all 28 models, new process
#   Stream C (combined): all 28 models, new process
#
# Batch sizes are now doubled (set in train_config.yaml):
#   nano=128, small=96, medium=64, large=48, xlarge=32
#
# Usage:
#   bash scripts/run_parallel_train.sh
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PROJECT_ROOT/logs"
PYTHON="/workspace/miniconda3/envs/vision/bin/python"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$LOG_DIR"

source /workspace/.secrets/api_keys.env 2>/dev/null || true
export PYTHONUNBUFFERED=1

echo "============================================================"
echo " PARALLEL TRAINING LAUNCH"
echo " Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo " New batch sizes: nano=128 small=96 medium=64 large=48 xlarge=32"
echo "============================================================"

# ── Wait for existing infra run (models 1-12) to finish ──────
echo ""
echo "Waiting for existing infra run (yolov8x_infra) to complete..."

while ps aux | grep -q "[t]rain\.py.*output.*task_002" ; do
    remaining_infra=$(grep -c "✅ Training complete" "$LOG_DIR/train_20260806_114142.log" 2>/dev/null || echo 0)
    echo "  $(date '+%H:%M:%S') — infra models done so far: $remaining_infra/28"
    sleep 120  # check every 2 minutes
    # Once we have 12 done, we can break and launch stream A for remaining
    if [ "$remaining_infra" -ge 12 ]; then
        break
    fi
done

echo ""
echo "  ✅ First 12 infra models complete. Launching parallel streams..."
echo ""

# ── Stream A: Infra remaining (models 13-28, after yolov8x) ──
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " STREAM A — Infra remaining (yolov9t → yolo11x)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# We'll train each remaining infra model explicitly, skipping already-done ones
INFRA_REMAINING=(yolov9t yolov9s yolov9m yolov9c yolov9e
                 yolov10n yolov10s yolov10m yolov10b yolov10l yolov10x
                 yolo11n yolo11s yolo11m yolo11l yolo11x)

{
    for model in "${INFRA_REMAINING[@]}"; do
        # Skip if checkpoint already exists (in case of restart)
        ckpt="$PROJECT_ROOT/checkpoints/${model}_infra/weights/best.pt"
        if [ -f "$ckpt" ]; then
            echo "[SKIP] $model infra — checkpoint already exists"
            continue
        fi
        echo ""
        echo "[STREAM A] Training: $model / infra"
        "$PYTHON" -u "$PROJECT_ROOT/train.py" \
            --model "$model" \
            --dataset infra \
            --output "$PROJECT_ROOT/results/task_002_infra.md"
    done
    echo ""
    echo "STREAM A COMPLETE: $(date '+%Y-%m-%d %H:%M:%S')"
} > "$LOG_DIR/stream_A_infra_${TIMESTAMP}.log" 2>&1 &
PID_A=$!
echo "  Stream A PID: $PID_A  (log: logs/stream_A_infra_${TIMESTAMP}.log)"
echo "$PID_A" > "$LOG_DIR/stream_A.pid"

sleep 30  # stagger start to avoid simultaneous VRAM spikes

# ── Stream B: Survivor (all 28 models) ────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " STREAM B — Survivor (all 28 models)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

{
    "$PYTHON" -u "$PROJECT_ROOT/train.py" \
        --dataset survivor \
        --output "$PROJECT_ROOT/results/task_002_survivor.md"
    echo ""
    echo "STREAM B COMPLETE: $(date '+%Y-%m-%d %H:%M:%S')"
} > "$LOG_DIR/stream_B_survivor_${TIMESTAMP}.log" 2>&1 &
PID_B=$!
echo "  Stream B PID: $PID_B  (log: logs/stream_B_survivor_${TIMESTAMP}.log)"
echo "$PID_B" > "$LOG_DIR/stream_B.pid"

sleep 30  # stagger start

# ── Stream C: Combined (all 28 models) ────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " STREAM C — Combined (all 28 models)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

{
    "$PYTHON" -u "$PROJECT_ROOT/train.py" \
        --dataset combined \
        --output "$PROJECT_ROOT/results/task_002_combined.md"
    echo ""
    echo "STREAM C COMPLETE: $(date '+%Y-%m-%d %H:%M:%S')"
} > "$LOG_DIR/stream_C_combined_${TIMESTAMP}.log" 2>&1 &
PID_C=$!
echo "  Stream C PID: $PID_C  (log: logs/stream_C_combined_${TIMESTAMP}.log)"
echo "$PID_C" > "$LOG_DIR/stream_C.pid"

echo ""
echo "============================================================"
echo " ALL 3 STREAMS LAUNCHED"
echo "   A (infra-remaining):   PID $PID_A"
echo "   B (survivor):          PID $PID_B"
echo "   C (combined):          PID $PID_C"
echo ""
echo " Monitor with:"
echo "   bash scripts/live_progress.sh"
echo "   tail -f logs/stream_A_infra_${TIMESTAMP}.log"
echo "   tail -f logs/stream_B_survivor_${TIMESTAMP}.log"
echo "   tail -f logs/stream_C_combined_${TIMESTAMP}.log"
echo "============================================================"

# Wait for all and merge results
wait $PID_A $PID_B $PID_C
echo ""
echo "============================================================"
echo " ALL STREAMS COMPLETE: $(date '+%Y-%m-%d %H:%M:%S')"
echo " Now merge results and run post-training pipeline..."
echo "============================================================"
