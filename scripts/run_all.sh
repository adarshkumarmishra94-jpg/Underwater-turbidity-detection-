#!/bin/bash
# ============================================================
# run_all.sh — Master script: runs all tasks in sequence
# ============================================================
# Usage:
#   nohup bash scripts/run_all.sh > logs/all_$(date +%Y%m%d_%H%M%S).log 2>&1 &
#
# This runs Tasks 1-3 (A100 only). Edge inference (Jetson) must be
# run separately when the Jetson Nano is free:
#   bash scripts/run_edge.sh
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "============================================================"
echo " TURBID REVIEW — Full Pipeline"
echo " Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"

# ── Task 1: Pretrained Evaluation ──────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " TASK 1 — Pretrained Model Evaluation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/run_test.sh"

# ── Task 2: Fine-tuning ───────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " TASK 2 — Fine-tune Models (30 epochs)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/run_train.sh"

# ── Profiling ──────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " MODEL PROFILING — FLOPs, Params, Latency"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/run_profile.sh"

# ── Task 3a: A100 Inference ───────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " TASK 3a — A100 Inference Benchmark (224, 480, 640)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/run_inference.sh"

# ── Done (A100 tasks) ─────────────────────────────────────
echo ""
echo "============================================================"
echo " ALL A100 TASKS COMPLETE"
echo " Finished: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"
echo ""
echo " Results:"
echo "   Task 1: results/task_001_pretrained_eval.md"
echo "   Task 2: results/task_002_finetuned_eval.md"
echo "   Profiles: results/model_profiles_*.md"
echo "   Task 3a: results/task_003_inference.md"
echo ""
echo " ⚠️  Jetson Nano edge inference NOT included."
echo " Run separately when Jetson is free:"
echo "   bash scripts/run_edge.sh"
echo ""
echo " Don't forget to git push:"
echo "   cd $PROJECT_ROOT && git add . && git commit -m 'Results update' && git push"
