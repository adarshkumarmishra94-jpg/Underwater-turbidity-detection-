#!/usr/bin/env python3
"""
model_registry.py — Centralized model loading and management.

Loads all YOLO model variants from the models.yaml config.
Handles downloading pretrained weights and version-specific quirks.
"""

import yaml
from pathlib import Path
from ultralytics import YOLO


PROJECT_ROOT = Path(__file__).resolve().parent.parent
MODELS_CONFIG = PROJECT_ROOT / "configs" / "models.yaml"


def load_models_config():
    """Load model registry from YAML config."""
    with open(MODELS_CONFIG, "r") as f:
        config = yaml.safe_load(f)
    return config


def get_all_models():
    """Return flat list of all model dicts with family info."""
    config = load_models_config()
    models = []
    for family, variants in config.items():
        for variant in variants:
            variant["family"] = family
            models.append(variant)
    return models


def get_models_by_family(family):
    """Return models for a specific family (e.g., 'yolov8')."""
    config = load_models_config()
    return config.get(family, [])


def get_model_by_name(name):
    """Return a single model dict by name."""
    for model in get_all_models():
        if model["name"] == name:
            return model
    return None


def load_pretrained_model(model_info):
    """Load a pretrained YOLO model.

    Args:
        model_info: dict with 'name' and 'weights' keys.

    Returns:
        YOLO model instance.
    """
    weights = model_info["weights"]
    print(f"Loading pretrained model: {model_info['name']} ({weights})")
    try:
        model = YOLO(weights)
        return model
    except Exception as e:
        print(f"  ❌ Failed to load {model_info['name']}: {e}")
        return None


def load_finetuned_model(checkpoint_path):
    """Load a fine-tuned model from a checkpoint path.

    Args:
        checkpoint_path: Path to the .pt checkpoint file.

    Returns:
        YOLO model instance.
    """
    print(f"Loading fine-tuned model: {checkpoint_path}")
    try:
        model = YOLO(str(checkpoint_path))
        return model
    except Exception as e:
        print(f"  ❌ Failed to load checkpoint {checkpoint_path}: {e}")
        return None


def get_model_info_str(model):
    """Get model info string for logging."""
    try:
        info = model.info(verbose=False)
        return info
    except Exception:
        return "Info unavailable"


if __name__ == "__main__":
    # Quick test: list all models
    models = get_all_models()
    print(f"Total models registered: {len(models)}")
    print()
    for m in models:
        print(f"  {m['family']:>10s} | {m['name']:<15s} | {m['weights']:<20s} | size={m['size']}")
