#!/bin/bash
# live_progress_parallel.sh — Shows progress across all parallel training streams
# Usage: bash scripts/live_progress_parallel.sh

python3 << 'PYEOF'
import re, glob, os
from collections import defaultdict

logs = {
    'infra (original)':   sorted(glob.glob('/workspace/projects/vision/turbid_review/logs/train_20260806_114142.log')),
    'infra (stream A)':   sorted(glob.glob('/workspace/projects/vision/turbid_review/logs/stream_A_infra_*.log')),
    'survivor (stream B)': sorted(glob.glob('/workspace/projects/vision/turbid_review/logs/stream_B_surv_comb_*.log')),
    'combined (stream B)': sorted(glob.glob('/workspace/projects/vision/turbid_review/logs/stream_B_surv_comb_*.log')),
}

MODEL_ORDER = ['yolov3u','yolov3-tinyu',
               'yolov5nu','yolov5su','yolov5mu','yolov5lu','yolov5xu',
               'yolov8n','yolov8s','yolov8m','yolov8l','yolov8x',
               'yolov9t','yolov9s','yolov9m','yolov9c','yolov9e',
               'yolov10n','yolov10s','yolov10m','yolov10b','yolov10l','yolov10x',
               'yolo11n','yolo11s','yolo11m','yolo11l','yolo11x']

def parse_log(log_path, dataset_filter=None):
    """Extract completed runs and current run from a log file."""
    if not log_path or not os.path.exists(log_path):
        return [], None, None
    with open(log_path) as f:
        log = f.read()

    runs = re.findall(
        r'name=([a-z0-9_\-]+),.*?Starting training.*?'
        r'✅ Training complete in ([\d.]+) min\s+'
        r'mAP50=([\d.]+) \| mAP50-95=([\d.]+) \| P=([\d.]+) \| R=([\d.]+)',
        log, re.DOTALL
    )
    if dataset_filter:
        runs = [r for r in runs if r[0].endswith(f'_{dataset_filter}')]

    name_blocks = re.findall(r'name=([a-z0-9_\-]+),', log)
    current = name_blocks[-1] if name_blocks else None
    ep = re.findall(r'(\d+)/30\s+[\d.]+G', log)
    epoch = ep[-1] if ep else '?'
    return runs, current, epoch

# Gather all completed runs across all streams
all_done = {}  # key=(model,dataset) -> (mAP50, time)
currently = {}  # dataset -> (model, epoch)

# Original infra log
runs, cur, ep = parse_log('/workspace/projects/vision/turbid_review/logs/train_20260806_114142.log', 'infra')
for name, t, m50, *_ in runs:
    model = name.rsplit('_',1)[0]; ds = name.rsplit('_',1)[-1]
    all_done[(model,ds)] = (float(m50), float(t))
if cur and cur.endswith('_infra'):
    currently['infra (orig)'] = (cur.rsplit('_',1)[0], ep)

# Stream A log
a_logs = sorted(glob.glob('/workspace/projects/vision/turbid_review/logs/stream_A_infra_*.log'))
if a_logs:
    runs, cur, ep = parse_log(a_logs[-1], 'infra')
    for name, t, m50, *_ in runs:
        model = name.rsplit('_',1)[0]; ds = 'infra'
        all_done[(model,ds)] = (float(m50), float(t))
    if cur:
        currently['infra (A)'] = (cur.rsplit('_',1)[0], ep)

# Stream B log (survivor + combined interleaved)
b_logs = sorted(glob.glob('/workspace/projects/vision/turbid_review/logs/stream_B_surv_comb_*.log'))
if b_logs:
    runs_s, cur, ep = parse_log(b_logs[-1], 'survivor')
    for name, t, m50, *_ in runs_s:
        model = name.rsplit('_',1)[0]
        all_done[(model,'survivor')] = (float(m50), float(t))
    runs_c, cur_c, ep_c = parse_log(b_logs[-1], 'combined')
    for name, t, m50, *_ in runs_c:
        model = name.rsplit('_',1)[0]
        all_done[(model,'combined')] = (float(m50), float(t))
    if cur:
        ds = 'combined' if cur.endswith('_combined') else 'survivor'
        currently[f'{ds} (B)'] = (cur.rsplit('_',1)[0], ep)

# Print status
print("=" * 72)
print("  TASK 2 — Parallel Training Progress")
print("=" * 72)

infra_done   = [(m,ds) for (m,ds) in all_done if ds=='infra']
surv_done    = [(m,ds) for (m,ds) in all_done if ds=='survivor']
comb_done    = [(m,ds) for (m,ds) in all_done if ds=='combined']
total_done   = len(all_done)

print(f"  infra:    {len(infra_done):>2}/28  {'█'*len(infra_done)+'░'*(28-len(infra_done))}")
print(f"  survivor: {len(surv_done):>2}/28  {'█'*len(surv_done)+'░'*(28-len(surv_done))}")
print(f"  combined: {len(comb_done):>2}/28  {'█'*len(comb_done)+'░'*(28-len(comb_done))}")
print(f"  TOTAL:    {total_done:>2}/84")
print()

if currently:
    print("  Currently training:")
    for stream, (model, ep) in currently.items():
        print(f"    [{stream}] {model}  epoch {ep}/30")
    print()

# Table of all completed
print(f"  {'Model':<16} {'infra':>8} {'survivor':>9} {'combined':>9}")
print(f"  {'-'*16} {'-'*8} {'-'*9} {'-'*9}")
for m in MODEL_ORDER:
    i = f"{all_done.get((m,'infra'),(None,))[0]:.4f}" if (m,'infra') in all_done else '—'
    s = f"{all_done.get((m,'survivor'),(None,))[0]:.4f}" if (m,'survivor') in all_done else '—'
    c = f"{all_done.get((m,'combined'),(None,))[0]:.4f}" if (m,'combined') in all_done else '—'
    if i!='—' or s!='—' or c!='—':
        print(f"  {m:<16} {i:>8} {s:>9} {c:>9}")

print("=" * 72)
PYEOF
