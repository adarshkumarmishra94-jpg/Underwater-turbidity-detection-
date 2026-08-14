#!/usr/bin/env python3
"""
export_onnx.py — Export trained YOLO models to ONNX for edge deployment.

Usage:
    python models/export_onnx.py --checkpoint checkpoints/yolov8n_infra/weights/best.pt --output checkpoints/exports/
    python models/export_onnx.py --all-checkpoints  # Export all best.pt checkpoints
"""

import argparse
import shutil
import sys
import yaml
from pathlib import Path
from datetime import datetime
from ultralytics import YOLO


PROJECT_ROOT = Path(__file__).resolve().parent.parent


def load_export_config():
    """Load export settings from train_config.yaml."""
    config_path = PROJECT_ROOT / "configs" / "train_config.yaml"
    with open(config_path, "r") as f:
        config = yaml.safe_load(f)
    return config.get("export", {})


def export_model(checkpoint_path, output_path, export_config=None):
    """Export a single model to ONNX.

    Args:
        checkpoint_path: Path to .pt checkpoint.
        output_path: Directory or explicit ``.onnx`` destination.
        export_config: Export configuration dict.

    Returns:
        Path to exported ONNX file, or None on failure.
    """
    if export_config is None:
        export_config = load_export_config()

    checkpoint_path = Path(checkpoint_path)
    output_path = Path(output_path)
    explicit_file = output_path.suffix.lower() == ".onnx"
    output_dir = output_path.parent if explicit_file else output_path
    output_dir.mkdir(parents=True, exist_ok=True)

    model_name = checkpoint_path.parent.parent.name  # e.g., yolov8n_infra
    print(f"\nExporting {model_name} to ONNX...")
    print(f"  Checkpoint: {checkpoint_path}")

    try:
        model = YOLO(str(checkpoint_path))

        exported_path = Path(model.export(
            format=export_config.get("format", "onnx"),
            imgsz=export_config.get("imgsz", 640),
            half=export_config.get("half", False),
            dynamic=export_config.get("dynamic", False),
            simplify=export_config.get("simplify", True),
            opset=export_config.get("opset", 12),
        ))

        destination = output_path if explicit_file else output_dir / f"{model_name}.onnx"
        if exported_path.resolve() != destination.resolve():
            shutil.move(str(exported_path), str(destination))

        print(f"  ✅ Exported to: {destination}")
        return destination

    except Exception as e:
        print(f"  ❌ Export failed: {e}")
        return None


def find_all_checkpoints():
    """Find all best.pt checkpoints in the checkpoints directory."""
    ckpt_dir = PROJECT_ROOT / "checkpoints"
    checkpoints = list(ckpt_dir.glob("*/weights/best.pt"))
    return sorted(checkpoints)


def main():
    parser = argparse.ArgumentParser(description="Export YOLO models to ONNX")
    parser.add_argument("--checkpoint", type=str, help="Path to a specific .pt checkpoint")
    parser.add_argument("--output", type=str, default="checkpoints/exports",
                        help="Output directory for ONNX files")
    parser.add_argument("--all-checkpoints", action="store_true",
                        help="Export all best.pt checkpoints found in checkpoints/")
    parser.add_argument("--imgsz", type=int, default=None, help="Override image size")
    parser.add_argument("--half", action="store_true", help="Export with FP16")
    parser.add_argument("--dynamic", action="store_true",
                        help="Export dynamic height/width axes for TensorRT profiles")
    parser.add_argument("--no-simplify", action="store_true",
                        help="Disable ONNX graph simplification")

    args = parser.parse_args()

    export_config = load_export_config()
    if args.imgsz:
        export_config["imgsz"] = args.imgsz
    if args.half:
        export_config["half"] = True
    if args.dynamic:
        export_config["dynamic"] = True
    if args.no_simplify:
        export_config["simplify"] = False

    output_path = Path(args.output)
    if not output_path.is_absolute():
        output_path = PROJECT_ROOT / output_path

    if args.all_checkpoints:
        checkpoints = find_all_checkpoints()
        if not checkpoints:
            print("No checkpoints found in checkpoints/*/weights/best.pt")
            return 1

        print(f"Found {len(checkpoints)} checkpoints to export")
        results = []
        for ckpt in checkpoints:
            result = export_model(ckpt, output_path, export_config)
            results.append((ckpt, result))

        # Summary
        print(f"\n{'=' * 60}")
        print(f"Export Summary")
        print(f"{'=' * 60}")
        for ckpt, result in results:
            status = "✅" if result else "❌"
            print(f"  {status} {ckpt.parent.parent.name}")

    elif args.checkpoint:
        export_model(args.checkpoint, output_path, export_config)
    else:
        parser.print_help()
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
