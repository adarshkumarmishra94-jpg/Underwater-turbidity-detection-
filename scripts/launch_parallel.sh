#!/bin/bash
# ============================================================
# launch_parallel.sh — Safe 2-stream parallel training launcher
#
# Waits for current process (infra models 1-12) to finish yolov8x_infra,
# then runs:
#   Stream A: infra remaining (yolov9t → yolo11x), 16 models
#   Stream B: survivor all 28 + combined all 28 = 56 models (sequential)
#
# VRAM safety: each stream trains one model at a time.
# Both streams running together = max ~26GB used (nano+xlarge worst case)
# which fits in our 30GB budget.
#
# Usage:
#   nohup bash scripts/launch_parallel.sh > logs/parallel_launch_$(date +%Y%m%d_%H%M%S).log 2>&1 &
# ============================================================

set -euo pipefail

PROJECT_ROOT="/workspace/projects/vision/turbid_review"
LOG_DIR="$PROJECT_ROOT/logs"
PYTHON="/workspace/miniconda3/envs/vision/bin/python"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$LOG_DIR"
source /workspace/.secrets/api_keys.env 2>/dev/null || true
export PYTHONUNBUFFERED=1

echo "============================================================"
echo " PARALLEL TRAINING LAUNCHER"
echo " $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"
echo ""
echo "Batch sizes (updated):"
echo "  nano=128  small=96  medium=64  large=48  xlarge=32"
echo ""

# ── Wait for yolov8x_infra to complete ───────────────────────
echo "Waiting for existing infra run to complete yolov8x_infra..."
while true; do
    done=$(grep -c "✅ Training complete" "$LOG_DIR/train_20260806_114142.log" 2>/dev/null || echo 0)
    if [ "$done" -ge 12 ]; then
        echo "  $(date '+%H:%M:%S') infra models complete: $done — launching parallel streams!"
        break
    fi
    echo "  $(date '+%H:%M:%S') infra models done: $done/12, waiting..."
    sleep 60
done

echo ""

# ── Stream A: Infra remaining (yolov9t → yolo11x) ────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " STREAM A — infra: models 13-28 (yolov9t → yolo11x)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

INFRA_REMAINING=(yolov9t yolov9s yolov9m yolov9c yolov9e
                 yolov10n yolov10s yolov10m yolov10b yolov10l yolov10x
                 yolo11n yolo11s yolo11m yolo11l yolo11x)

stream_a() {
    echo "[Stream A] Starting: $(date '+%Y-%m-%d %H:%M:%S')"
    for model in "${INFRA_REMAINING[@]}"; do
        ckpt="$PROJECT_ROOT/checkpoints/${model}_infra/weights/best.pt"
        if [ -f "$ckpt" ]; then
            echo "[Stream A] SKIP $model infra — already has best.pt"
            continue
        fi
        echo ""
        echo "[Stream A] $(date '+%H:%M:%S') Training: $model / infra"
        "$PYTHON" -u "$PROJECT_ROOT/train.py" \
            --model "$model" \
            --dataset infra \
            --output "$PROJECT_ROOT/results/task_002_infra_remaining.md"
    done
    echo ""
    echo "[Stream A] COMPLETE: $(date '+%Y-%m-%d %H:%M:%S')"
}

# ── Stream B: Survivor → Combined ────────────────────────────
stream_b() {
    echo "[Stream B] Starting: $(date '+%Y-%m-%d %H:%M:%S')"

    echo ""
    echo "[Stream B] === SURVIVOR (all 28 models) ==="
    "$PYTHON" -u "$PROJECT_ROOT/train.py" \
        --dataset survivor \
        --output "$PROJECT_ROOT/results/task_002_survivor.md"

    echo ""
    echo "[Stream B] === COMBINED (all 28 models) ==="
    "$PYTHON" -u "$PROJECT_ROOT/train.py" \
        --dataset combined \
        --output "$PROJECT_ROOT/results/task_002_combined.md"

    echo ""
    echo "[Stream B] COMPLETE: $(date '+%Y-%m-%d %H:%M:%S')"
}

# Export the functions for subshell use
export -f stream_a stream_b
export PROJECT_ROOT LOG_DIR PYTHON INFRA_REMAINING

# Launch in parallel
LOG_A="$LOG_DIR/stream_A_infra_${TIMESTAMP}.log"
LOG_B="$LOG_DIR/stream_B_surv_comb_${TIMESTAMP}.log"

bash -c 'stream_a' > "$LOG_A" 2>&1 &
PID_A=$!
echo "  Stream A launched — PID $PID_A"
echo "$PID_A" > "$LOG_DIR/stream_A.pid"

# Stagger by 45s so they don't hit VRAM peak simultaneously
sleep 45

bash -c 'stream_b' > "$LOG_B" 2>&1 &
PID_B=$!
echo "  Stream B launched — PID $PID_B"
echo "$PID_B" > "$LOG_DIR/stream_B.pid"

echo ""
echo "============================================================"
echo " BOTH STREAMS RUNNING"
echo "   A (infra 13-28):       PID $PID_A"
echo "   B (survivor+combined): PID $PID_B"
echo ""
echo " Monitor streams:"
echo "   tail -f $LOG_A"
echo "   tail -f $LOG_B"
echo "   bash scripts/live_progress_parallel.sh"
echo "============================================================"

wait $PID_A $PID_B
echo ""
echo "============================================================"
echo " ALL STREAMS COMPLETE: $(date '+%Y-%m-%d %H:%M:%S')"
echo " Run next: nohup bash scripts/run_post_training.sh > logs/post_training_\$(date +%Y%m%d_%H%M%S).log 2>&1 &"
echo "============================================================"
