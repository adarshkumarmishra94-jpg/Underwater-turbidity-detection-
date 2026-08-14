#!/usr/bin/env python3
"""
profile_model.py — Profile YOLO models for FLOPs, parameters, memory, and runtime.

Usage:
    python models/profile_model.py --model yolov8n.pt --imgsz 640
    python models/profile_model.py --all-models
    python models/profile_model.py --all-checkpoints
"""

import argparse
import json
import sys
import time
import yaml
from pathlib import Path
from datetime import datetime

import torch
from ultralytics import YOLO


PROJECT_ROOT = Path(__file__).resolve().parent.parent


def load_models_config():
    """Load model registry."""
    config_path = PROJECT_ROOT / "configs" / "models.yaml"
    with open(config_path, "r") as f:
        return yaml.safe_load(f)


def profile_model(model_path, imgsz=640, num_warmup=10, num_runs=100, device="cuda"):
    """Profile a YOLO model comprehensively.

    Returns dict with: params, gflops, layers, memory_mb, latency_ms, fps
    """
    results = {
        "model_path": str(model_path),
        "imgsz": imgsz,
        "device": device,
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    }

    try:
        model = YOLO(str(model_path))

        # Get model info (params, GFLOPs, layers)
        from ultralytics.utils.torch_utils import get_flops, get_num_params
        total_params = get_num_params(model.model)
        flops = get_flops(model.model, imgsz)
        results["params"] = total_params
        results["gflops"] = round(flops, 2)

        # Count layers
        results["layers"] = len(list(model.model.modules()))

        # Memory profiling
        if device == "cuda" and torch.cuda.is_available():
            torch.cuda.reset_peak_memory_stats()
            torch.cuda.empty_cache()

            # Dummy forward pass
            dummy_input = torch.randn(1, 3, imgsz, imgsz).to(device)
            model.model.to(device)
            model.model.eval()

            with torch.no_grad():
                _ = model.model(dummy_input)

            results["peak_memory_mb"] = torch.cuda.max_memory_allocated() / (1024 ** 2)

            # Latency profiling
            # Warmup
            with torch.no_grad():
                for _ in range(num_warmup):
                    _ = model.model(dummy_input)

            torch.cuda.synchronize()

            # Timed runs
            start = time.perf_counter()
            with torch.no_grad():
                for _ in range(num_runs):
                    _ = model.model(dummy_input)
                    torch.cuda.synchronize()
            end = time.perf_counter()

            avg_latency = (end - start) / num_runs * 1000  # ms
            results["latency_ms"] = round(avg_latency, 3)
            results["fps"] = round(1000 / avg_latency, 1)

            # Cleanup
            torch.cuda.empty_cache()
        else:
            results["peak_memory_mb"] = None
            results["latency_ms"] = None
            results["fps"] = None

        results["status"] = "success"

    except Exception as e:
        results["status"] = "failed"
        results["error"] = str(e)

    return results


def format_params(n):
    """Format parameter count for display."""
    if n is None:
        return "N/A"
    if n >= 1e6:
        return f"{n / 1e6:.1f}M"
    if n >= 1e3:
        return f"{n / 1e3:.1f}K"
    return str(n)


def generate_profile_report(all_results):
    """Generate markdown report from profiling results."""
    lines = [
        "# Model Profiling Report (Complete Fine-Tuned Benchmark)",
        "",
        f"> Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"> Device: NVIDIA A100-SXM4-40GB | Image Size: 640×640",
        "",
        "| Model | Params (Exact) | Params (M) | GFLOPs | Layers | Memory (MB) | Latency (ms) | FPS |",
        "|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|",
    ]

    for r in all_results:
        p = Path(r["model_path"])
        model_name = r.get("model_name") or (p.parent.parent.name if p.stem == "best" else p.stem)
        if r["status"] == "success":
            params_raw = r.get("params")
            params_exact = f"{params_raw:,}" if isinstance(params_raw, int) else str(params_raw)
            params_m = f"{params_raw / 1e6:.2f}M" if isinstance(params_raw, (int, float)) and params_raw > 1e4 else str(params_raw)
            gflops = f"{r['gflops']:.2f}" if r.get("gflops") is not None else "N/A"
            layers = str(r.get("layers", "N/A"))
            memory = f"{r['peak_memory_mb']:.1f}" if r.get("peak_memory_mb") else "N/A"
            latency = f"{r['latency_ms']:.1f}" if r.get("latency_ms") else "N/A"
            fps = f"{r['fps']:.0f}" if r.get("fps") else "N/A"
            lines.append(f"| **{model_name}** | {params_exact} | {params_m} | **{gflops}** | {layers} | {memory} | {latency} | {fps} |")
        else:
            lines.append(f"| **{model_name}** | — | ❌ Failed | — | — | — | — | — |")

    lines.append("")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Profile YOLO models")
    parser.add_argument("--model", type=str, help="Path to a specific model/weights")
    parser.add_argument("--all-models", action="store_true", help="Profile all pretrained models")
    parser.add_argument("--all-checkpoints", action="store_true",
                        help="Profile all fine-tuned checkpoints")
    parser.add_argument("--imgsz", type=int, default=640, help="Image size")
    parser.add_argument("--num-runs", type=int, default=100, help="Number of inference runs for timing")
    parser.add_argument("--device", type=str, default="cuda", help="Device (cuda or cpu)")
    parser.add_argument("--output", type=str, default=None, help="Output markdown file")

    args = parser.parse_args()

    all_results = []

    if args.all_models:
        config = load_models_config()
        for family, variants in config.items():
            for variant in variants:
                print(f"\nProfiling {variant['name']}...")
                result = profile_model(
                    variant["weights"], args.imgsz, num_runs=args.num_runs, device=args.device
                )
                result["model_name"] = variant["name"]
                result["family"] = family
                result["size"] = variant["size"]
                all_results.append(result)
                print(f"  Params: {format_params(result.get('params'))} | "
                      f"Latency: {result.get('latency_ms', 'N/A')}ms | "
                      f"FPS: {result.get('fps', 'N/A')}")

    elif args.all_checkpoints:
        ckpt_dir = PROJECT_ROOT / "checkpoints"
        checkpoints = sorted(ckpt_dir.glob("*/weights/best.pt"))
        if not checkpoints:
            print("No checkpoints found")
            return 1

        for ckpt in checkpoints:
            model_name = ckpt.parent.parent.name
            print(f"\nProfiling {model_name}...")
            result = profile_model(str(ckpt), args.imgsz, num_runs=args.num_runs, device=args.device)
            result["model_name"] = model_name
            all_results.append(result)

    elif args.model:
        result = profile_model(args.model, args.imgsz, num_runs=args.num_runs, device=args.device)
        all_results.append(result)
    else:
        parser.print_help()
        return 1

    # Generate report
    report = generate_profile_report(all_results)
    print(f"\n{report}")

    # Save report
    output_path = args.output or str(PROJECT_ROOT / "results" / "model_profiles.md")
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w") as f:
        f.write(report)
    print(f"\nReport saved to: {output_path}")

    # Save raw JSON
    json_path = Path(output_path).with_suffix(".json")
    with open(json_path, "w") as f:
        json.dump(all_results, f, indent=2, default=str)
    print(f"Raw data saved to: {json_path}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
