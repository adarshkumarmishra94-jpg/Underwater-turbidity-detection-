#!/usr/bin/env python3
"""
inference.py — Task 3: Run inference benchmarks at multiple image sizes.

Measures per-image latency, throughput (FPS) at 224×224, 480×480, 640×640.
Saves annotated outputs and comprehensive results tables.

Usage:
    python inference.py --all-checkpoints                     # Benchmark all trained models
    python inference.py --model checkpoints/yolov8n_infra/weights/best.pt --dataset infra
    python inference.py --all-checkpoints --imgsz 224         # Single size override
"""

import argparse
import json
import os
import sys
import time
import statistics
import yaml
from pathlib import Path
from datetime import datetime

import torch
from ultralytics import YOLO

PROJECT_ROOT = Path(__file__).resolve().parent

# Default inference image sizes
DEFAULT_IMAGE_SIZES = [224, 480, 640]

DEFAULT_DATASETS = {
    "infra": {
        "yaml": str(PROJECT_ROOT / "configs" / "datasets" / "infra.yaml"),
        "val_images": "/workspace/datasets/turbid_water/_derived/ultralytics/infra/images/val",
    },
    "survivor": {
        "yaml": str(PROJECT_ROOT / "configs" / "datasets" / "survivor.yaml"),
        "val_images": "/workspace/datasets/turbid_water/_derived/ultralytics/survivor/images/val",
    },
    "combined": {
        "yaml": str(PROJECT_ROOT / "configs" / "datasets" / "combined.yaml"),
        "val_images": "/workspace/datasets/turbid_water/_derived/yolo_underwater_detector/images/val",
    },
}


def checkpoint_name(path):
    """Return the model_dataset name for hierarchical or flat checkpoints."""
    path = Path(path)
    return path.parent.parent.name if path.stem == "best" else path.stem


def find_checkpoints(checkpoint_dir):
    """Find checkpoints in training-run or final_checkpoints layouts."""
    checkpoint_dir = Path(checkpoint_dir)
    hierarchical = checkpoint_dir.glob("*/weights/best.pt")
    flat = checkpoint_dir.glob("*.pt")
    return sorted(set(hierarchical) | set(flat), key=lambda path: checkpoint_name(path))


def resolve_device_name(device, explicit_name=None):
    """Resolve a report label without hard-coding the benchmark GPU."""
    if explicit_name:
        return explicit_name
    device_text = str(device).lower()
    if device_text == "cpu":
        return "CPU"
    if torch.cuda.is_available():
        if device_text.startswith("cuda:"):
            index = int(device_text.split(":", 1)[1])
        elif device_text.isdigit():
            index = int(device_text)
        else:
            index = torch.cuda.current_device()
        return torch.cuda.get_device_name(index)
    return str(device)


def load_inference_config():
    """Load inference config from train_config.yaml."""
    config_path = PROJECT_ROOT / "configs" / "train_config.yaml"
    with open(config_path, "r") as f:
        config = yaml.safe_load(f)
    return config.get("inference", {})


def benchmark_model(model_path, image_dir, imgsz=640, conf=0.25, iou=0.45,
                    device=0, num_warmup=10, max_images=None, save_output=False):
    """Run inference benchmark on a set of images at a specific image size.

    Returns:
        dict with latency, throughput, and detection stats.
    """
    result = {
        "model_path": str(model_path),
        "image_dir": str(image_dir),
        "device": str(device),
        "imgsz": imgsz,
        "conf": conf,
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    }

    try:
        model = YOLO(str(model_path))

        # Collect images
        img_extensions = {".jpg", ".jpeg", ".png", ".bmp"}
        images = []
        for ext in img_extensions:
            images.extend(Path(image_dir).glob(f"*{ext}"))
            images.extend(Path(image_dir).glob(f"*{ext.upper()}"))
        images = sorted(images)

        if max_images and len(images) > max_images:
            images = images[:max_images]

        if not images:
            result["status"] = "failed"
            result["error"] = f"No images found in {image_dir}"
            return result

        result["num_images"] = len(images)

        # Warmup
        print(f"    Warming up ({num_warmup} runs) at {imgsz}×{imgsz}...")
        for _ in range(num_warmup):
            _ = model.predict(str(images[0]), imgsz=imgsz, conf=conf, iou=iou,
                              device=device, verbose=False)

        # Timed inference
        print(f"    Running inference on {len(images)} images...")
        latencies = []
        total_detections = 0

        for img_path in images:
            start = time.perf_counter()
            results = model.predict(
                str(img_path), imgsz=imgsz, conf=conf, iou=iou,
                device=device, verbose=False,
                save=save_output,
                project=str(PROJECT_ROOT / "results" / "inference_outputs"),
            )
            end = time.perf_counter()

            latency_ms = (end - start) * 1000
            latencies.append(latency_ms)

            for r in results:
                total_detections += len(r.boxes)

        # Statistics
        result["total_time_s"] = round(sum(latencies) / 1000, 2)
        result["avg_latency_ms"] = round(statistics.mean(latencies), 2)
        result["median_latency_ms"] = round(statistics.median(latencies), 2)
        result["min_latency_ms"] = round(min(latencies), 2)
        result["max_latency_ms"] = round(max(latencies), 2)
        result["std_latency_ms"] = round(statistics.stdev(latencies), 2) if len(latencies) > 1 else 0
        result["fps"] = round(1000 / result["avg_latency_ms"], 1)
        result["total_detections"] = total_detections
        result["avg_detections_per_image"] = round(total_detections / len(images), 2)
        result["status"] = "success"

        print(f"    ✅ [{imgsz}×{imgsz}] Avg: {result['avg_latency_ms']:.1f}ms | "
              f"FPS: {result['fps']:.1f} | Dets: {total_detections}")

    except Exception as e:
        result["status"] = "failed"
        result["error"] = str(e)
        print(f"    ❌ [{imgsz}×{imgsz}] Failed: {e}")

    return result


def generate_inference_report(all_results, output_path, device_name):
    """Generate markdown report for inference benchmarks grouped by image size."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    measured_sizes = sorted({result.get("imgsz") for result in all_results})
    size_label = ", ".join(f"{size}×{size}" for size in measured_sizes)

    lines = [
        "# Task 3 — Inference Benchmark Results (Multi-Size)",
        "",
        f"> Generated: {timestamp}",
        f"> Device: {device_name}",
        f"> Image Sizes: {size_label}",
        f"> Conf: 0.25 | IoU: 0.45",
        "",
    ]

    # Group by image size
    by_size = {}
    for r in all_results:
        sz = r.get("imgsz", "unknown")
        if sz not in by_size:
            by_size[sz] = []
        by_size[sz].append(r)

    for imgsz in sorted(by_size.keys()):
        results = by_size[imgsz]
        lines.append(f"## Image Size: {imgsz}×{imgsz}")
        lines.append("")
        lines.append("| Model | Dataset | Images | Avg Latency (ms) | Median (ms) | Min (ms) | Max (ms) | FPS | Detections | Status |")
        lines.append("|-------|---------|--------|------------------|-------------|----------|----------|-----|------------|--------|")

        for r in results:
            model_name = checkpoint_name(r["model_path"])
            if r["status"] == "success":
                lines.append(
                    f"| {model_name} | {r.get('dataset', 'N/A')} | "
                    f"{r['num_images']} | {r['avg_latency_ms']:.1f} | "
                    f"{r['median_latency_ms']:.1f} | {r['min_latency_ms']:.1f} | "
                    f"{r['max_latency_ms']:.1f} | {r['fps']:.1f} | "
                    f"{r['total_detections']} | ✅ |"
                )
            else:
                lines.append(
                    f"| {model_name} | {r.get('dataset', 'N/A')} | "
                    f"— | — | — | — | — | — | — | ❌ |"
                )

        lines.append("")
        lines.append("---")
        lines.append("")

    # Summary comparison table across sizes
    lines.append("## Summary — FPS Comparison Across Image Sizes")
    lines.append("")

    # Collect unique model+dataset combinations
    model_ds_combos = {}
    for r in all_results:
        m_name = checkpoint_name(r["model_path"])
        key = f"{m_name}_{r.get('dataset', '')}"
        if key not in model_ds_combos:
            model_ds_combos[key] = {"model": m_name, "dataset": r.get("dataset", "")}
        model_ds_combos[key][r.get("imgsz", 0)] = r.get("fps", "—") if r["status"] == "success" else "❌"

    sizes = sorted(by_size.keys())
    header = "| Model | Dataset | " + " | ".join([f"FPS@{s}" for s in sizes]) + " |"
    sep = "|-------|---------|" + "|".join(["------" for _ in sizes]) + "|"
    lines.append(header)
    lines.append(sep)

    for key, data in model_ds_combos.items():
        fps_cols = " | ".join([str(data.get(s, "—")) for s in sizes])
        lines.append(f"| {data['model']} | {data['dataset']} | {fps_cols} |")

    lines.append("")

    report = "\n".join(lines)

    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w") as f:
        f.write(report)

    json_path = Path(output_path).with_suffix(".json")
    with open(json_path, "w") as f:
        json.dump(all_results, f, indent=2, default=str)

    print(f"\n📄 Report saved to: {output_path}")
    print(f"📄 Raw data saved to: {json_path}")


def main():
    parser = argparse.ArgumentParser(description="Task 3: Inference benchmarks at multiple sizes")
    parser.add_argument("--model", type=str, help="Path to model checkpoint")
    parser.add_argument("--onnx-model", type=str, help="Path to ONNX model")
    parser.add_argument("--dataset", type=str, choices=list(DEFAULT_DATASETS.keys()),
                        help="Dataset to run inference on")
    parser.add_argument("--all-checkpoints", action="store_true",
                        help="Benchmark all fine-tuned checkpoints")
    parser.add_argument("--checkpoints-dir", type=str,
                        default=str(PROJECT_ROOT / "checkpoints"),
                        help="Directory containing */weights/best.pt or flat *.pt files")
    parser.add_argument("--imgsz", type=int, nargs="+", default=None,
                        help="Override image sizes (e.g., --imgsz 224 480 640)")
    parser.add_argument("--max-images", type=int, default=None,
                        help="Max images to process (for quick tests)")
    parser.add_argument("--device", type=str, default="0", help="Device (0=GPU, cpu)")
    parser.add_argument("--device-name", type=str, default=None,
                        help="Optional report label; defaults to the detected CUDA device")
    parser.add_argument("--infra-images", type=str,
                        default=os.environ.get("INFRA_IMAGES", DEFAULT_DATASETS["infra"]["val_images"]))
    parser.add_argument("--survivor-images", type=str,
                        default=os.environ.get("SURVIVOR_IMAGES", DEFAULT_DATASETS["survivor"]["val_images"]))
    parser.add_argument("--combined-images", type=str,
                        default=os.environ.get("COMBINED_IMAGES", DEFAULT_DATASETS["combined"]["val_images"]))
    parser.add_argument("--save-output", action="store_true", help="Save annotated images")
    parser.add_argument("--output", type=str,
                        default=str(PROJECT_ROOT / "results" / "task_003_inference.md"))

    args = parser.parse_args()

    datasets = {
        "infra": {**DEFAULT_DATASETS["infra"], "val_images": args.infra_images},
        "survivor": {**DEFAULT_DATASETS["survivor"], "val_images": args.survivor_images},
        "combined": {**DEFAULT_DATASETS["combined"], "val_images": args.combined_images},
    }
    device_name = resolve_device_name(args.device, args.device_name)

    # Determine image sizes
    if args.imgsz:
        image_sizes = args.imgsz
    else:
        inf_config = load_inference_config()
        image_sizes = inf_config.get("image_sizes", DEFAULT_IMAGE_SIZES)

    print(f"Inference image sizes: {image_sizes}")

    all_results = []

    if args.all_checkpoints:
        checkpoints = find_checkpoints(args.checkpoints_dir)
        if not checkpoints:
            print(f"❌ No checkpoints found in {args.checkpoints_dir}")
            return 1

        jobs = []
        for ckpt in checkpoints:
            model_name = checkpoint_name(ckpt)
            # Extract dataset name from checkpoint name
            parts = model_name.rsplit("_", 1)
            ds_name = parts[-1] if len(parts) > 1 and parts[-1] in datasets else None

            datasets_to_run = {ds_name: datasets[ds_name]} if ds_name else datasets
            for ds_name_run, ds in datasets_to_run.items():
                for imgsz in image_sizes:
                    jobs.append((ckpt, model_name, ds_name_run, ds, imgsz))

        for current, (ckpt, model_name, ds_name_run, ds, imgsz) in enumerate(jobs, 1):
            print(f"\n[{current}/{len(jobs)}] {model_name} on {ds_name_run} @ {imgsz}×{imgsz}")
            result = benchmark_model(
                ckpt, ds["val_images"], imgsz=imgsz,
                device=args.device, max_images=args.max_images,
                save_output=args.save_output,
            )
            result["dataset"] = ds_name_run
            result["device_name"] = device_name
            all_results.append(result)

    elif args.model or args.onnx_model:
        model_path = args.model or args.onnx_model
        datasets_to_run = {args.dataset: datasets[args.dataset]} if args.dataset else datasets

        for ds_name, ds in datasets_to_run.items():
            for imgsz in image_sizes:
                print(f"\nBenchmarking on {ds_name} @ {imgsz}×{imgsz}...")
                result = benchmark_model(
                    model_path, ds["val_images"], imgsz=imgsz,
                    device=args.device, max_images=args.max_images,
                    save_output=args.save_output,
                )
                result["dataset"] = ds_name
                result["device_name"] = device_name
                all_results.append(result)
    else:
        parser.print_help()
        return 1

    generate_inference_report(all_results, args.output, device_name)

    success = sum(1 for r in all_results if r["status"] == "success")
    failed = sum(1 for r in all_results if r["status"] == "failed")
    print(f"\n{'=' * 60}")
    print(f"INFERENCE COMPLETE: {success} success, {failed} failed")
    print(f"{'=' * 60}")

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
