#!/bin/bash
# ============================================================
# setup.sh — One-time project setup
# ============================================================
# Usage: bash scripts/setup.sh
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "============================================================"
echo " TURBID REVIEW — Project Setup"
echo " $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"

# ── 1. Source API keys ───────────────────────────────────────
echo ""
echo "[1/6] Loading API keys..."
if [ -f /workspace/.secrets/api_keys.env ]; then
    source /workspace/.secrets/api_keys.env
    echo "  ✅ API keys loaded"
else
    echo "  ❌ /workspace/.secrets/api_keys.env not found"
    exit 1
fi

# ── 2. Install packages in conda env ────────────────────────
echo ""
echo "[2/6] Installing packages in conda vision env..."
conda run -n vision pip install ultralytics wandb thop onnxruntime-gpu psutil tabulate pandas matplotlib seaborn 2>&1 | tail -3
echo "  ✅ Packages installed"

# ── 3. Verify installations ─────────────────────────────────
echo ""
echo "[3/6] Verifying installations..."
conda run -n vision python -c "
from ultralytics import YOLO
import wandb
import torch
print(f'  ultralytics: OK')
print(f'  wandb: OK')
print(f'  torch: {torch.__version__}')
print(f'  CUDA available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'  GPU: {torch.cuda.get_device_name(0)}')
    # print(f'  VRAM: {torch.cuda.get_device_properties(0).total_mem / 1024**3:.1f} GB')
"
echo "  ✅ Verification complete"

# ── 4. Login to WandB ───────────────────────────────────────
echo ""
echo "[4/6] Setting up WandB..."
if [ -n "${WANDB_API_KEY:-}" ]; then
    conda run -n vision wandb login "$WANDB_API_KEY" 2>&1 | tail -1
    echo "  ✅ WandB logged in"
else
    echo "  ⚠️ WANDB_API_KEY not set, skipping"
fi

# ── 5. Validate datasets ────────────────────────────────────
echo ""
echo "[5/6] Validating datasets and creating symlinks..."
conda run -n vision python "$PROJECT_ROOT/data/prepare_datasets.py"

# ── 6. Create directories ───────────────────────────────────
echo ""
echo "[6/6] Creating project directories..."
mkdir -p "$PROJECT_ROOT/checkpoints"
mkdir -p "$PROJECT_ROOT/results"
mkdir -p "$PROJECT_ROOT/logs"
mkdir -p "$PROJECT_ROOT/docs"
echo "  ✅ Directories created"

# ── Done ─────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo " Setup complete! $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"
echo ""
echo "Next steps:"
echo "  1. Run pretrained eval:  nohup bash scripts/run_test.sh > logs/task1_\$(date +%Y%m%d_%H%M%S).log 2>&1 &"
echo "  2. Run fine-tuning:      nohup bash scripts/run_train.sh > logs/task2_\$(date +%Y%m%d_%H%M%S).log 2>&1 &"
echo "  3. Run inference:        nohup bash scripts/run_inference.sh > logs/task3_\$(date +%Y%m%d_%H%M%S).log 2>&1 &"
echo "  4. Run edge deployment:  bash scripts/run_edge.sh"
