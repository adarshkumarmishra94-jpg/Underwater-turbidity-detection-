#!/usr/bin/env python3
"""
train.py — Task 2: Fine-tune YOLO models on underwater detection datasets.

Trains each model variant on each dataset, logs to WandB,
saves checkpoints and evaluation metrics.

Usage:
    python train.py                                  # Train all models on all datasets
    python train.py --model yolov8n --dataset infra  # Single model, single dataset
    python train.py --model yolov8n                  # Single model, all datasets
    python train.py --dataset infra                  # All models, single dataset
    python train.py --epochs 100                     # Override epochs
"""

import argparse
import json
import os
import sys
import time
import yaml
from pathlib import Path
from datetime import datetime
if "PYTORCH_CUDA_ALLOC_CONF" not in os.environ:
    os.environ["PYTORCH_CUDA_ALLOC_CONF"] = "max_split_size_mb:128"
os.environ.setdefault("WANDB_PROJECT", "turbid_review")

import torch
try:
    torch.multiprocessing.set_sharing_strategy('file_system')
except Exception:
    pass

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
    "infra": str(PROJECT_ROOT / "configs" / "datasets" / "infra.yaml"),
    "survivor": str(PROJECT_ROOT / "configs" / "datasets" / "survivor.yaml"),
    "combined": str(PROJECT_ROOT / "configs" / "datasets" / "combined.yaml"),
}


def load_train_config():
    """Load training configuration."""
    config_path = PROJECT_ROOT / "configs" / "train_config.yaml"
    with open(config_path, "r") as f:
        return yaml.safe_load(f)


def load_models_config():
    """Load model registry."""
    config_path = PROJECT_ROOT / "configs" / "models.yaml"
    with open(config_path, "r") as f:
        return yaml.safe_load(f)


def get_batch_size(model_size, batch_overrides):
    """Get appropriate batch size based on model size.
    Respects TURBID_BATCH_MAX env var to cap batch when sharing GPU.
    """
    size = batch_overrides.get(model_size, 16)
    env_max = os.environ.get('TURBID_BATCH_MAX')
    if env_max:
        size = min(size, int(env_max))
    return size


def train_model(model_info, dataset_name, dataset_yaml, train_config, epochs_override=None):
    """Fine-tune a single YOLO model on a dataset.

    Returns:
        dict with training results and evaluation metrics.
    """
    training_cfg = train_config["training"]
    batch_overrides = train_config.get("batch_overrides", {})
    eval_cfg = train_config.get("evaluation", {})

    model_name = model_info["name"]
    run_name = f"{model_name}_{dataset_name}"
    epochs = epochs_override or training_cfg["epochs"]
    batch_size = get_batch_size(model_info["size"], batch_overrides)

    result = {
        "model": model_name,
        "family": model_info["family"],
        "size": model_info["size"],
        "dataset": dataset_name,
        "epochs": epochs,
        "batch_size": batch_size,
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    }

    print(f"\n{'═' * 60}")
    print(f"TRAINING: {model_name} on {dataset_name}")
    print(f"  Epochs: {epochs} | Batch: {batch_size} | ImgSz: {training_cfg['imgsz']}")
    print(f"{'═' * 60}")

    try:
        # Load pretrained model
        model = YOLO(model_info["weights"])

        # Train
        start_time = time.time()
        train_results = model.train(
            data=dataset_yaml,
            epochs=epochs,
            batch=batch_size,
            imgsz=training_cfg["imgsz"],
            optimizer=training_cfg.get("optimizer", "auto"),
            lr0=training_cfg.get("lr0", 0.01),
            lrf=training_cfg.get("lrf", 0.01),
            momentum=training_cfg.get("momentum", 0.937),
            weight_decay=training_cfg.get("weight_decay", 0.0005),
            warmup_epochs=training_cfg.get("warmup_epochs", 3),
            patience=training_cfg.get("patience", 15),
            save_period=training_cfg.get("save_period", 10),
            workers=int(os.environ.get("TURBID_WORKERS", training_cfg.get("workers", 8))),
            device=training_cfg.get("device", 0),
            project=str(PROJECT_ROOT / "checkpoints"),
            name=run_name,
            exist_ok=training_cfg.get("exist_ok", True),
            pretrained=training_cfg.get("pretrained", True),
            resume=training_cfg.get("resume", False),
            seed=training_cfg.get("seed", 42),
            deterministic=training_cfg.get("deterministic", True),
            amp=training_cfg.get("amp", True),
            cache=training_cfg.get("cache", False),
            close_mosaic=training_cfg.get("close_mosaic", 10),
            verbose=True,
        )
        train_time = time.time() - start_time

        result["train_time_s"] = round(train_time, 1)
        result["train_time_min"] = round(train_time / 60, 1)

        # Evaluate on val set with the best checkpoint
        best_ckpt = PROJECT_ROOT / "checkpoints" / run_name / "weights" / "best.pt"
        if best_ckpt.exists():
            eval_model = YOLO(str(best_ckpt))
            metrics = eval_model.val(
                data=dataset_yaml,
                imgsz=training_cfg["imgsz"],
                batch=batch_size,
                conf=eval_cfg.get("conf", 0.001),
                iou=eval_cfg.get("iou", 0.6),
                device=training_cfg.get("device", 0),
            )

            result["mAP50"] = round(float(metrics.box.map50), 4)
            result["mAP50_95"] = round(float(metrics.box.map), 4)
            result["precision"] = round(float(metrics.box.mp), 4)
            result["recall"] = round(float(metrics.box.mr), 4)
            result["best_checkpoint"] = str(best_ckpt)
        else:
            result["mAP50"] = None
            result["mAP50_95"] = None
            result["precision"] = None
            result["recall"] = None
            result["best_checkpoint"] = None

        result["status"] = "success"

        print(f"\n  ✅ Training complete in {result['train_time_min']:.1f} min")
        if result["mAP50"] is not None:
            print(f"     mAP50={result['mAP50']:.4f} | mAP50-95={result['mAP50_95']:.4f} | "
                  f"P={result['precision']:.4f} | R={result['recall']:.4f}")

    except Exception as e:
        result["status"] = "failed"
        result["error"] = str(e)
        print(f"  ❌ Training failed: {e}")

    return result


def generate_results_table(all_results, output_path):
    """Generate markdown results table for fine-tuned models."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    lines = [
        "# Task 2 — Fine-tuned YOLO Model Evaluation",
        "",
        f"> Generated: {timestamp}",
        f"> Device: NVIDIA A100-SXM4-40GB | ImgSz: 640",
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
        lines.append("| Model | Family | Size | Epochs | Batch | mAP50 | mAP50-95 | Precision | Recall | Train Time (min) | Status |")
        lines.append("|-------|--------|------|--------|-------|-------|----------|-----------|--------|-----------------|--------|")

        for r in results:
            if r["status"] == "success":
                mAP50 = f"{r['mAP50']:.4f}" if r.get("mAP50") is not None else "N/A"
                mAP50_95 = f"{r['mAP50_95']:.4f}" if r.get("mAP50_95") is not None else "N/A"
                precision = f"{r['precision']:.4f}" if r.get("precision") is not None else "N/A"
                recall = f"{r['recall']:.4f}" if r.get("recall") is not None else "N/A"
                lines.append(
                    f"| {r['model']} | {r['family']} | {r['size']} | {r['epochs']} | {r['batch_size']} | "
                    f"{mAP50} | {mAP50_95} | {precision} | {recall} | "
                    f"{r.get('train_time_min', 'N/A')} | ✅ |"
                )
            else:
                lines.append(
                    f"| {r['model']} | {r['family']} | {r['size']} | {r.get('epochs', '—')} | "
                    f"{r.get('batch_size', '—')} | — | — | — | — | — | "
                    f"❌ {r.get('error', 'unknown')[:30]} |"
                )

        lines.append("")
        lines.append("---")
        lines.append("")

    report = "\n".join(lines)

    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w") as f:
        f.write(report)
    print(f"\n📄 Results saved to: {output_path}")

    json_path = Path(output_path).with_suffix(".json")
    with open(json_path, "w") as f:
        json.dump(all_results, f, indent=2, default=str)
    print(f"📄 Raw data saved to: {json_path}")


def main():
    parser = argparse.ArgumentParser(description="Task 2: Fine-tune YOLO models")
    parser.add_argument("--model", type=str, default=None,
                        help="Specific model name (e.g., yolov8n). Default: all")
    parser.add_argument("--dataset", type=str, default=None, choices=list(DATASETS.keys()),
                        help="Specific dataset. Default: all")
    parser.add_argument("--epochs", type=int, default=None, help="Override epochs")
    parser.add_argument("--batch-max", type=int, default=None,
                        help="Cap batch size (useful when sharing GPU). Sets TURBID_BATCH_MAX.")
    parser.add_argument("--output", type=str,
                        default=str(PROJECT_ROOT / "results" / "task_002_finetuned_eval.md"),
                        help="Output markdown file")
    args = parser.parse_args()

    # Apply batch cap if specified
    if args.batch_max:
        os.environ['TURBID_BATCH_MAX'] = str(args.batch_max)
        print(f"  Batch size capped at: {args.batch_max} (--batch-max flag)")

    # Load configs
    train_config = load_train_config()
    models_config = load_models_config()

    # Get models
    models = []
    for family, variants in models_config.items():
        for variant in variants:
            variant["family"] = family
            if args.model is None or variant["name"] == args.model:
                models.append(variant)

    if not models:
        print(f"❌ No models found matching '{args.model}'")
        return 1

    # Get datasets
    if args.dataset:
        datasets = {args.dataset: DATASETS[args.dataset]}
    else:
        datasets = DATASETS

    total_runs = len(models) * len(datasets)
    print(f"{'=' * 60}")
    print(f"TASK 2 — Fine-tune YOLO Models")
    print(f"{'=' * 60}")
    print(f"Models: {len(models)} | Datasets: {list(datasets.keys())} | Total runs: {total_runs}")
    print(f"{'=' * 60}")

    # Train
    all_results = []
    current = 0

    for ds_name, ds_yaml in datasets.items():
        for model_info in models:
            current += 1
            print(f"\n[{current}/{total_runs}]")
            result = train_model(model_info, ds_name, ds_yaml, train_config, args.epochs)
            all_results.append(result)

    # Generate results
    generate_results_table(all_results, args.output)

    # Summary
    success = sum(1 for r in all_results if r["status"] == "success")
    failed = sum(1 for r in all_results if r["status"] == "failed")
    print(f"\n{'=' * 60}")
    print(f"TASK 2 COMPLETE: {success} success, {failed} failed out of {total_runs}")
    print(f"{'=' * 60}")

    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
