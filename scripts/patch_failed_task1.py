#!/usr/bin/env python3
"""
patch_failed_task1.py — Re-evaluate the 2 failed Task 1 entries and merge into existing results.

Failed entries:
  - yolov3u / infra
  - yolov5mu / infra

This script:
  1. Re-runs evaluation for these 2 entries
  2. Merges them into task_001_pretrained_eval.json (replacing failed entries)
  3. Regenerates task_001_pretrained_eval.md from the merged JSON
"""

import json
import os
import sys
import time
from pathlib import Path
from datetime import datetime

os.environ.setdefault("WANDB_PROJECT", "turbid_review")
os.environ["WANDB_MODE"] = "disabled"  # small patch run, no need for wandb

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from ultralytics import YOLO

# ── Config ───────────────────────────────────────────────────
RESULTS_JSON = PROJECT_ROOT / "results" / "task_001_pretrained_eval.json"
RESULTS_MD   = PROJECT_ROOT / "results" / "task_001_pretrained_eval.md"

FAILED_ENTRIES = [
    {"model": "yolov3u",  "dataset": "infra",
     "yaml": str(PROJECT_ROOT / "configs" / "datasets" / "infra.yaml"),
     "weight": str(PROJECT_ROOT / "yolov3u.pt"),
     "family": "yolov3", "size": "large"},
    {"model": "yolov5mu", "dataset": "infra",
     "yaml": str(PROJECT_ROOT / "configs" / "datasets" / "infra.yaml"),
     "weight": str(PROJECT_ROOT / "yolov5mu.pt"),
     "family": "yolov5", "size": "medium"},
]

INFRA_CLASSES = {0: "crack", 1: "corrosion"}


def evaluate_one(entry):
    model_name = entry["model"]
    dataset    = entry["dataset"]
    weight     = entry["weight"]
    yaml_path  = entry["yaml"]

    print(f"\n{'─'*60}")
    print(f"Re-evaluating: {model_name} on {dataset}")
    print(f"{'─'*60}")

    result = {
        "model": model_name,
        "family": entry["family"],
        "size": entry["size"],
        "dataset": dataset,
        "status": "failed",
        "error": None,
        "mAP50": None,
        "mAP50_95": None,
        "precision": None,
        "recall": None,
        "inference_time_s": None,
        "per_class": {},
    }

    try:
        model = YOLO(weight)
        t0 = time.time()
        metrics = model.val(
            data=yaml_path,
            imgsz=640,
            batch=16,
            device=0,
            verbose=True,
            save_json=False,
            plots=False,
            name=f"patch_{model_name}_{dataset}",
            project=str(PROJECT_ROOT / "checkpoints"),
            exist_ok=True,
        )
        elapsed = time.time() - t0

        result["status"]           = "success"
        result["mAP50"]            = round(float(metrics.box.map50), 4)
        result["mAP50_95"]         = round(float(metrics.box.map),   4)
        result["precision"]        = round(float(metrics.box.mp),     4)
        result["recall"]           = round(float(metrics.box.mr),     4)
        result["inference_time_s"] = round(elapsed, 1)

        # Per-class
        if hasattr(metrics.box, "ap_class_index") and metrics.box.ap_class_index is not None:
            for idx, cls_idx in enumerate(metrics.box.ap_class_index):
                cls_name = INFRA_CLASSES.get(int(cls_idx), f"class_{cls_idx}")
                ap50    = round(float(metrics.box.ap50[idx]), 4)
                ap50_95 = round(float(metrics.box.ap[idx]),   4)
                result["per_class"][cls_name] = {"ap50": ap50, "ap50_95": ap50_95}

        print(f"  SUCCESS: mAP50={result['mAP50']} | mAP50-95={result['mAP50_95']}"
              f" | P={result['precision']} | R={result['recall']}")

    except Exception as e:
        result["error"] = str(e)
        print(f"  FAILED: {e}")

    return result


def merge_and_save(new_results):
    # Load existing JSON
    with open(RESULTS_JSON) as f:
        all_results = json.load(f)

    # Build lookup key -> index for existing failed entries
    lookup = {(r["model"], r["dataset"]): i for i, r in enumerate(all_results)}

    updated = 0
    for new_r in new_results:
        key = (new_r["model"], new_r["dataset"])
        if key in lookup:
            idx = lookup[key]
            all_results[idx] = new_r
            updated += 1
            print(f"  Updated entry: {new_r['model']} / {new_r['dataset']}")
        else:
            all_results.append(new_r)
            print(f"  Appended new entry: {new_r['model']} / {new_r['dataset']}")

    # Save updated JSON
    with open(RESULTS_JSON, "w") as f:
        json.dump(all_results, f, indent=2, default=str)
    print(f"\n  JSON saved: {RESULTS_JSON}  ({len(all_results)} total entries)")

    # Regenerate MD from merged data
    regenerate_md(all_results)
    return all_results


def regenerate_md(all_results):
    """Regenerate the markdown table from merged results."""
    from collections import defaultdict
    datasets_seen = defaultdict(list)
    for r in all_results:
        datasets_seen[r["dataset"]].append(r)

    ds_order = ["infra", "survivor", "combined"]
    lines = [
        "# Task 1 — Pretrained Model Evaluation",
        "",
        f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        "",
    ]

    for ds_name in ds_order:
        if ds_name not in datasets_seen:
            continue
        rows = datasets_seen[ds_name]
        lines += [
            f"## Dataset: {ds_name.upper()}",
            "",
            "| Model | Family | Size | mAP50 | mAP50-95 | Precision | Recall | Time (s) | Status |",
            "|-------|--------|------|-------|----------|-----------|--------|----------|--------|",
        ]
        for r in rows:
            if r["status"] == "success":
                lines.append(
                    f"| {r['model']} | {r['family']} | {r['size']} "
                    f"| {r['mAP50']} | {r['mAP50_95']} "
                    f"| {r['precision']} | {r['recall']} "
                    f"| {r['inference_time_s']} | ✅ |"
                )
            else:
                err = (r.get("error") or "unknown")[:40]
                lines.append(
                    f"| {r['model']} | {r['family']} | {r['size']} "
                    f"| — | — | — | — | — | ❌ {err} |"
                )
        lines.append("")

        # Per-class tables for successful entries
        for r in rows:
            if r["status"] == "success" and r.get("per_class"):
                lines += [
                    f"### {r['model']} — Per-Class AP50",
                    "",
                    "| Class | AP50 | AP50-95 |",
                    "|-------|------|---------|",
                ]
                for cls_name, v in r["per_class"].items():
                    lines.append(f"| {cls_name} | {v['ap50']} | {v['ap50_95']} |")
                lines.append("")

        lines += ["---", ""]

    with open(RESULTS_MD, "w") as f:
        f.write("\n".join(lines))
    print(f"  MD  saved: {RESULTS_MD}")


def main():
    print("=" * 60)
    print("PATCH: Re-evaluating 2 failed Task 1 entries")
    print("=" * 60)

    new_results = []
    for entry in FAILED_ENTRIES:
        res = evaluate_one(entry)
        new_results.append(res)

    print("\n" + "=" * 60)
    print("Merging results into existing files...")
    print("=" * 60)
    all_results = merge_and_save(new_results)

    success = sum(1 for r in all_results if r["status"] == "success")
    failed  = sum(1 for r in all_results if r["status"] == "failed")

    print(f"\nFINAL: {success} success, {failed} failed out of {len(all_results)}")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
