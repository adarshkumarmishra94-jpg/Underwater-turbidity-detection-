# YOLO Model Zoo — All Variants Benchmarked

## Overview

This project benchmarks **28 YOLO model variants** across 6 families on underwater/turbid-water detection tasks.

---

## YOLOv3 (Legacy)

| Model | Params | GFLOPs | Notes |
|-------|--------|--------|-------|
| YOLOv3u | ~63M | ~155 | Updated ultralytics architecture |
| YOLOv3-tinyu | ~12M | ~13 | Lightweight legacy model |

- **Paper**: [YOLOv3: An Incremental Improvement](https://arxiv.org/abs/1804.02767) (Redmon & Farhadi, 2018)
- **Architecture**: Darknet-53 backbone + FPN

---

## YOLOv5 (Ultralytics Updated)

| Model | Params (M) | GFLOPs | Input Size |
|-------|-----------|--------|------------|
| YOLOv5nu | ~2.6 | ~7.7 | 640 |
| YOLOv5su | ~9.1 | ~24.0 | 640 |
| YOLOv5mu | ~25.1 | ~64.2 | 640 |
| YOLOv5lu | ~53.2 | ~135.0 | 640 |
| YOLOv5xu | ~97.2 | ~246.4 | 640 |

- **Source**: [Ultralytics YOLOv5](https://github.com/ultralytics/yolov5)
- **Architecture**: CSPDarknet backbone, PANet neck, anchor-based detection

---

## YOLOv8

| Model | Params (M) | GFLOPs | Input Size |
|-------|-----------|--------|------------|
| YOLOv8n | ~3.2 | ~8.7 | 640 |
| YOLOv8s | ~11.2 | ~28.6 | 640 |
| YOLOv8m | ~25.9 | ~78.9 | 640 |
| YOLOv8l | ~43.7 | ~165.2 | 640 |
| YOLOv8x | ~68.2 | ~257.8 | 640 |

- **Paper**: [Ultralytics YOLOv8](https://docs.ultralytics.com/models/yolov8/)
- **Architecture**: C2f module, anchor-free detection, decoupled head

---

## YOLOv9

| Model | Params (M) | GFLOPs | Input Size |
|-------|-----------|--------|------------|
| YOLOv9t | ~2.0 | ~7.7 | 640 |
| YOLOv9s | ~7.2 | ~26.7 | 640 |
| YOLOv9m | ~20.1 | ~76.8 | 640 |
| YOLOv9c | ~25.5 | ~102.8 | 640 |
| YOLOv9e | ~58.1 | ~192.5 | 640 |

- **Paper**: [YOLOv9: Learning What You Want to Learn Using Programmable Gradient Information](https://arxiv.org/abs/2402.13616)
- **Architecture**: GELAN (Generalized Efficient Layer Aggregation Network) + PGI

---

## YOLOv10

| Model | Params (M) | GFLOPs | Input Size |
|-------|-----------|--------|------------|
| YOLOv10n | ~2.3 | ~6.7 | 640 |
| YOLOv10s | ~7.2 | ~21.6 | 640 |
| YOLOv10m | ~15.4 | ~59.1 | 640 |
| YOLOv10b | ~19.1 | ~92.0 | 640 |
| YOLOv10l | ~24.4 | ~120.3 | 640 |
| YOLOv10x | ~29.5 | ~160.4 | 640 |

- **Paper**: [YOLOv10: Real-Time End-to-End Object Detection](https://arxiv.org/abs/2405.14458)
- **Architecture**: NMS-free training, consistent dual assignments

---

## YOLO11

| Model | Params (M) | GFLOPs | Input Size |
|-------|-----------|--------|------------|
| YOLO11n | ~2.6 | ~6.5 | 640 |
| YOLO11s | ~9.4 | ~21.5 | 640 |
| YOLO11m | ~20.1 | ~68.0 | 640 |
| YOLO11l | ~25.3 | ~86.9 | 640 |
| YOLO11x | ~56.9 | ~194.9 | 640 |

- **Source**: [Ultralytics YOLO11](https://docs.ultralytics.com/models/yolo11/)
- **Architecture**: C3k2 blocks, SPPF, C2PSA attention

---

> **Note**: Param counts and GFLOPs above are approximate reference values from official sources. Actual values will be profiled and reported in `results/model_profiles_pretrained.md`.
