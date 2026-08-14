#!/bin/bash
# ============================================================
# live_progress.sh — Show live training progress from log
# Usage: bash scripts/live_progress.sh
# ============================================================

LOG=$(ls -t /workspace/projects/vision/turbid_review/logs/train_*.log 2>/dev/null | head -1)

if [ -z "$LOG" ]; then
    echo "No training log found."
    exit 1
fi

echo "Reading: $LOG"
echo ""

python3 << 'PYEOF'
import re, sys

log_path = None
import subprocess, os
result = subprocess.run(
    ['ls', '-t'] + [f for f in __import__('glob').glob('/workspace/projects/vision/turbid_review/logs/train_*.log')],
    capture_output=True, text=True
)
logs = result.stdout.strip().split('\n')
if not logs or not logs[0]:
    print("No train log found.")
    sys.exit(1)
log_path = logs[0]

with open(log_path) as f:
    log = f.read()

# Extract completed runs
runs = re.findall(
    r'name=([a-z0-9_\-]+),.*?Starting training.*?'
    r'✅ Training complete in ([\d.]+) min\s+'
    r'mAP50=([\d.]+) \| mAP50-95=([\d.]+) \| P=([\d.]+) \| R=([\d.]+)',
    log, re.DOTALL
)

# Current training
name_blocks = re.findall(r'name=([a-z0-9_\-]+),', log)
current_name = name_blocks[-1] if name_blocks else "unknown"
ep = re.findall(r'(\d+)/30\s+[\d.]+G', log)
current_epoch = ep[-1] if ep else "?"

print(f"{'='*70}")
print(f"  TASK 2 — Fine-tuning Progress")
print(f"{'='*70}")
print(f"  Completed : {len(runs)} / 84 runs")
print(f"  Currently : {current_name}  epoch {current_epoch}/30")
print(f"{'='*70}")
print()
print(f"  {'Model':<24} {'mAP50':>7} {'mAP50-95':>9} {'P':>7} {'R':>7} {'Time':>7}")
print(f"  {'-'*24} {'-'*7} {'-'*9} {'-'*7} {'-'*7} {'-'*7}")
for name, t, m50, m5095, p, r in runs:
    flag = " 🏆" if float(m50) == max(float(x[2]) for x in runs) else ""
    print(f"  {name:<24} {m50:>7} {m5095:>9} {p:>7} {r:>7} {float(t):>6.0f}m{flag}")
print()

# Dataset breakdown
datasets = {'infra': 0, 'survivor': 0, 'combined': 0}
for name, *_ in runs:
    for ds in datasets:
        if name.endswith(f'_{ds}'):
            datasets[ds] += 1
print(f"  Dataset breakdown:")
for ds, count in datasets.items():
    bar = '█' * count + '░' * (28 - count)
    print(f"  {ds:<10} [{bar}] {count}/28")
PYEOF
