#!/usr/bin/env python3
"""
test.py — Task 1: Evaluate ALL pretrained YOLO models on all datasets.

Runs model.val() for each model×dataset combination.
Collects: mAP50, mAP50-95, precision, recall, per-class metrics.
Saves results to results/task_001_pretrained_eval.md and .json.

Usage:
    python test.py                              # Run all models on all datasets
    python test.py --model yolov8n              # Single model, all datasets
    python test.py --dataset infra              # All models, single dataset
    python test.py --model yolov8n --dataset infra  # Single model, single dataset
"""

import argparse
import json
import os
import sys
import time
import yaml
from pathlib import Path
from datetime import datetime

# Setup WandB before importing ultralytics
os.environ.setdefault("WANDB_PROJECT", "turbid_review")

from ultralytics import YOLO

try:
    import wandb
    WANDB_AVAILABLE = True
except ImportError:
    WANDB_AVAILABLE = False

PROJECT_ROOT = Path(__file__).resolve().parent


# ── Dataset configs ──────────────────────────────────────────
DATASETS = {
    "infra": {
        "yaml": str(PROJECT_ROOT / "configs" / "datasets" / "infra.yaml"),
        "classes": {0: "crack", 1: "corrosion"},
    },
    "survivor": {
        "yaml": str(PROJECT_ROOT / "configs" / "datasets" / "survivor.yaml"),
        "classes": {0: "person"},
    },
    "combined": {
        "yaml": str(PROJECT_ROOT / "configs" / "datasets" / "combined.yaml"),
        "classes": {
            0: "holothurian", 1: "echinus", 2: "scallop", 3: "starfish",
            4: "fish", 5: "small_fish", 6: "crab", 7: "shrimp",
            8: "jellyfish", 9: "bio", 10: "cloth", 11: "fishing",
            12: "metal", 13: "paper", 14: "plastic", 15: "rov",
            16: "rubber", 17: "unknown", 18: "wood",
        },
    },
}


def load_models_config():
    """Load all model variants from config."""
    config_path = PROJECT_ROOT / "configs" / "models.yaml"
    with open(config_path, "r") as f:
        return yaml.safe_load(f)


def get_all_models(filter_name=None):
    """Get flat list of model dicts, optionally filtered."""
    config = load_models_config()
    models = []
    for family, variants in config.items():
        for variant in variants:
            variant["family"] = family
            if filter_name is None or variant["name"] == filter_name:
                models.append(variant)
    return models


def evaluate_model_on_dataset(model_info, dataset_name, dataset_config):
    """Run pretrained model evaluation on a dataset.

    Returns:
        dict with metrics or error info.
    """
    result = {
        "model": model_info["name"],
        "family": model_info["family"],
        "size": model_info["size"],
        "dataset": dataset_name,
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    }

    print(f"\n{'─' * 60}")
    print(f"Evaluating: {model_info['name']} on {dataset_name}")
    print(f"{'─' * 60}")

    try:
        # Load pretrained model
        model = YOLO(model_info["weights"])

        # Run validation
        start_time = time.time()
        metrics = model.val(
            data=dataset_config["yaml"],
            imgsz=640,
            batch=16,
            conf=0.001,
            iou=0.6,
            max_det=300,
            device=0,
            workers=8,
            verbose=True,
        )
        eval_time = time.time() - start_time

        # Extract metrics
        result["mAP50"] = round(float(metrics.box.map50), 4)
        result["mAP50_95"] = round(float(metrics.box.map), 4)
        result["precision"] = round(float(metrics.box.mp), 4)
        result["recall"] = round(float(metrics.box.mr), 4)
        result["eval_time_s"] = round(eval_time, 1)

        # Per-class metrics
        per_class = {}
        class_names = dataset_config["classes"]
        if hasattr(metrics.box, "ap50") and metrics.box.ap50 is not None:
            for i, (cls_id, cls_name) in enumerate(class_names.items()):
                if i < len(metrics.box.ap50):
                    per_class[cls_name] = {
                        "ap50": round(float(metrics.box.ap50[i]), 4),
                        "ap50_95": round(float(metrics.box.ap[i]), 4) if i < len(metrics.box.ap) else None,
                    }
        result["per_class"] = per_class
        result["status"] = "success"

        # Log to WandB
        if WANDB_AVAILABLE:
            try:
                wandb.log({
                    f"pretrained/{dataset_name}/{model_info['name']}/mAP50": result["mAP50"],
                    f"pretrained/{dataset_name}/{model_info['name']}/mAP50-95": result["mAP50_95"],
                    f"pretrained/{dataset_name}/{model_info['name']}/precision": result["precision"],
                    f"pretrained/{dataset_name}/{model_info['name']}/recall": result["recall"],
                })
            except Exception:
                pass

        print(f"  ✅ mAP50={result['mAP50']:.4f} | mAP50-95={result['mAP50_95']:.4f} | "
              f"P={result['precision']:.4f} | R={result['recall']:.4f} | Time={eval_time:.1f}s")

    except Exception as e:
        result["status"] = "failed"
        result["error"] = str(e)
        print(f"  ❌ Failed: {e}")

    return result


def generate_results_table(all_results, output_path):
    """Generate markdown results table."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    lines = [
        "# Task 1 — Pretrained YOLO Model Evaluation",
        "",
        f"> Generated: {timestamp}",
        f"> Dataset: All | Device: NVIDIA A100-SXM4-40GB | ImgSz: 640",
        "",
    ]

    # Group by dataset
    datasets_seen = {}
    for r in all_results:
        ds = r["dataset"]
        if ds not in datasets_seen:
            datasets_seen[ds] = []
        datasets_seen[ds].append(r)

    for ds_name, results in datasets_seen.items():
        lines.append(f"## Dataset: {ds_name.upper()}")
        lines.append("")
        lines.append("| Model | Family | Size | mAP50 | mAP50-95 | Precision | Recall | Time (s) | Status |")
        lines.append("|-------|--------|------|-------|----------|-----------|--------|----------|--------|")

        for r in results:
            if r["status"] == "success":
                lines.append(
                    f"| {r['model']} | {r['family']} | {r['size']} | "
                    f"{r['mAP50']:.4f} | {r['mAP50_95']:.4f} | "
                    f"{r['precision']:.4f} | {r['recall']:.4f} | "
                    f"{r['eval_time_s']:.1f} | ✅ |"
                )
            else:
                lines.append(
                    f"| {r['model']} | {r['family']} | {r['size']} | "
                    f"— | — | — | — | — | ❌ {r.get('error', 'unknown')[:30]} |"
                )

        lines.append("")

        # Per-class details (if available)
        for r in results:
            if r["status"] == "success" and r.get("per_class"):
                lines.append(f"### {r['model']} — Per-Class AP50")
                lines.append("")
                lines.append("| Class | AP50 | AP50-95 |")
                lines.append("|-------|------|---------|")
                for cls_name, cls_metrics in r["per_class"].items():
                    ap50 = f"{cls_metrics['ap50']:.4f}" if cls_metrics.get("ap50") is not None else "N/A"
                    ap50_95 = f"{cls_metrics['ap50_95']:.4f}" if cls_metrics.get("ap50_95") is not None else "N/A"
                    lines.append(f"| {cls_name} | {ap50} | {ap50_95} |")
                lines.append("")

        lines.append("---")
        lines.append("")

    report = "\n".join(lines)

    # Save markdown
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w") as f:
        f.write(report)
    print(f"\n📄 Results saved to: {output_path}")

    # Save JSON
    json_path = Path(output_path).with_suffix(".json")
    with open(json_path, "w") as f:
        json.dump(all_results, f, indent=2, default=str)
    print(f"📄 Raw data saved to: {json_path}")


def main():
    parser = argparse.ArgumentParser(description="Task 1: Pretrained YOLO evaluation")
    parser.add_argument("--model", type=str, default=None,
                        help="Specific model name (e.g., yolov8n). Default: all models")
    parser.add_argument("--dataset", type=str, default=None, choices=list(DATASETS.keys()),
                        help="Specific dataset. Default: all datasets")
    parser.add_argument("--output", type=str,
                        default=str(PROJECT_ROOT / "results" / "task_001_pretrained_eval.md"),
                        help="Output markdown file")
    args = parser.parse_args()

    # Initialize WandB
    if WANDB_AVAILABLE:
        try:
            wandb.init(
                project="turbid_review",
                name=f"task1_pretrained_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
                tags=["task1", "pretrained", "evaluation"],
                config={"task": "pretrained_eval", "imgsz": 640},
            )
        except Exception as e:
            print(f"⚠️ WandB init failed: {e}")

    # Get models
    models = get_all_models(filter_name=args.model)
    if not models:
        print(f"❌ No models found" + (f" matching '{args.model}'" if args.model else ""))
        return 1

    # Get datasets
    if args.dataset:
        datasets = {args.dataset: DATASETS[args.dataset]}
    else:
        datasets = DATASETS

    print(f"{'=' * 60}")
    print(f"TASK 1 — Pretrained YOLO Model Evaluation")
    print(f"{'=' * 60}")
    print(f"Models: {len(models)}")
    print(f"Datasets: {list(datasets.keys())}")
    print(f"Total runs: {len(models) * len(datasets)}")
    print(f"{'=' * 60}")

    # Run evaluations
    all_results = []
    total = len(models) * len(datasets)
    current = 0

    for ds_name, ds_config in datasets.items():
        for model_info in models:
            current += 1
            print(f"\n[{current}/{total}] ", end="")
            result = evaluate_model_on_dataset(model_info, ds_name, ds_config)
            all_results.append(result)

    # Generate results
    generate_results_table(all_results, args.output)

    # Finish WandB
    if WANDB_AVAILABLE:
        try:
            wandb.finish()
        except Exception:
            pass

    # Summary
    success = sum(1 for r in all_results if r["status"] == "success")
    failed = sum(1 for r in all_results if r["status"] == "failed")
    print(f"\n{'=' * 60}")
    print(f"TASK 1 COMPLETE: {success} success, {failed} failed out of {total}")
    print(f"{'=' * 60}")

    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
