# Benchmark Validity in Underwater Object Detection

### A Case Study on 28 YOLO Detectors

> An empirical benchmark of 28 YOLO architectures (v3–v11) for underwater search & rescue, infrastructure inspection, and marine object detection.
---
## 📑 Table of Contents

1. [Overview](#-overview)
2. [Datasets](#-datasets)
3. [Benchmark Results](#-benchmark-results-summary)
4. [Inference](#-a100-multi-resolution-inference-summary)
5. [Project Structure](#-repository-structure)
6. [Quick Start](#-quick-start--usage)
7. [Checkpoints](#-model-checkpoints--google-drive-download)
8. [License](#-license)
   
## 🌊 Overview

This repository presents an empirical benchmark of 28 YOLO architectures
for underwater object detection.

The models are evaluated across three specialized datasets covering
infrastructure inspection, underwater search & rescue, and marine object
detection.

The benchmark includes pretrained evaluation, fine-tuning, multi-resolution
inference, model profiling, and edge deployment.

## 🎯 Key Benchmark Scope

- *28 YOLO architectures* evaluated across YOLOv3–YOLOv11.
- *3 underwater datasets* covering infrastructure, search & rescue, and marine detection.
- Evaluation includes *pretrained models, fine-tuning, multi-resolution inference, and edge deployment*.

---

## 🗂️ Datasets

| Dataset | Classes | Application |
|---|---|---|
| *INFRA* | 2 — crack, corrosion | Infrastructure inspection |
| *SURVIVOR* | 1 — person | Underwater search & rescue |
| *COMBINED* | 19 marine classes | Marine object detection |

Dataset configurations:

configs/datasets/infra.yaml  
configs/datasets/survivor.yaml  
configs/datasets/combined.yaml

---

## 🏆 Benchmark Results Summary

> Comparison of pretrained and fine-tuned YOLO models across the three underwater datasets.

### 1. Pretrained vs. Fine-Tuned Accuracy Gains

Fine-tuning on domain-specific turbid water datasets yields substantial performance gains across the evaluated model families.
```
Dataset       Runs    Pretrained mAP50    Fine-Tuned mAP50    Absolute Gain    Fine-Tuned mAP50-95
──────────────────────────────────────────────────────────────────────────────────────────────────
INFRA          26          0.0085              0.6048            +0.5964               0.4405
SURVIVOR       28          0.3612              0.9035            +0.5422               0.7057
COMBINED       25          0.0146              0.7422            +0.7277               0.5700
```

These primary aggregates include only the 79 archived records that report the
complete 30-epoch schedule. Five shorter records remain in the raw archive but
are excluded from this comparison.

---

### 2. Top Performing YOLO Models per Domain

### 🔹 Combined Marine Detection (19 classes)

| Rank | Model | Parameters | GFLOPs | Fine-Tuned mAP50 | Fine-Tuned mAP50-95 | Latency @ 640 | FPS @ 640 |
|---:|---|---:|---:|---:|---:|---:|---:|
| 1 | yolov9s | 7.29M | 27.42 | 0.7668 | 0.5849 | 32.23 ms | 31.0 |
| 2 | yolov5xu | 97.22M | 246.99 | 0.7599 | 0.6020 | 32.47 ms | 30.8 |
| 3 | yolov8l | 43.64M | 165.48 | 0.7584 | 0.5978 | 25.89 ms | 38.6 |
| 4 | yolov9e | 58.16M | 192.75 | 0.7565 | 0.5997 | 40.24 ms | 24.9 |
| 5 | yolov10m | 16.51M | 64.08 | 0.7564 | 0.5929 | 25.74 ms | 38.9 |

### 🔹 Subsea Infrastructure & Structural Inspection (INFRA)

| Rank | Model | Parameters | GFLOPs | Fine-Tuned mAP50 | Fine-Tuned mAP50-95 | Latency @ 640 | FPS @ 640 |
|---:|---|---:|---:|---:|---:|---:|---:|
| 1 | yolov8l | 43.63M | 165.41 | 0.6731 | 0.4816 | 13.92 ms | 71.8 |
| 2 | yolov8m | 25.86M | 79.07 | 0.6498 | 0.4790 | 16.90 ms | 59.2 |
| 3 | yolov11m | 20.05M | 68.19 | 0.6385 | 0.4661 | 20.97 ms | 47.7 |
| 4 | yolov8x | 68.15M | 258.13 | 0.6347 | 0.4814 | 22.12 ms | 45.2 |
| 5 | yolo11s | 9.43M | 21.55 | 0.6338 | 0.4702 | 18.56 ms | 53.9 |

### 🔹 Search & Rescue / Diver Rescue (SURVIVOR)

| Rank | Model | Parameters | GFLOPs | Fine-Tuned mAP50 | Fine-Tuned mAP50-95 | Latency @ 640 | FPS @ 640 |
|---:|---|---:|---:|---:|---:|---:|---:|
| 1 | yolov3-tiny | 12.13M | 19.06 | 0.9714 | 0.7872 | 11.81 ms | 84.7 |
| 2 | yolov8s | 11.14M | 28.65 | 0.9621 | 0.7839 | 14.36 ms | 69.6 |
| 3 | yolov8n | 3.01M | 8.19 | 0.9564 | 0.7835 | 13.07 ms | 76.5 |
| 4 | yolov5su | 9.12M | 24.04 | 0.9430 | 0.7433 | 17.59 ms | 56.9 |
| 5 | yolov5nu | 2.51M | 7.18 | 0.9379 | 0.7625 | 16.47 ms | 60.7 |

---

## ⚡ A100 Multi-Resolution Inference summary

The application benchmark times the full framework prediction call over each
real validation split. Values below are means over all 28 fine-tuned models;
they are not Jetson engine-only measurements.

| Dataset | Mean FPS @ 224×224 | Mean FPS @ 480×480 | Mean FPS @ 640×640 |
|---|---:|---:|---:|
| INFRA | 56.94 | 52.91 | 51.90 |
| SURVIVOR | 56.56 | 52.20 | 51.58 |
| COMBINED | 40.33 | 38.36 | 36.82 |
---

## 📁 Repository Structure
```text
underwater-turbidity-detection/
├── README.md                    # This document
├── LICENSE.md                   # Academic/research license
├── requirements.txt             # Python dependencies
│
├── configs/
│   ├── datasets/
│   │   ├── infra.yaml           # 2 classes (crack, corrosion)
│   │   ├── survivor.yaml        # 1 class (person)
│   │   └── combined.yaml        # 10 marine classes
│   ├── models.yaml              # 28 registered YOLO model variants
│   └── train_config.yaml        # Hyperparameters (30 epochs, 640 image)
│
├── checkpoints/
│   ├── pretrained/              # Pretrained COCO baseline weights
│   ├── export/                  # Exported ONNX models for Jetson Nano
│   └── finetuned/               # Fine-tuned checkpoints
│
├── results/
│   ├── task_001_pretrained_eval.md       # Pretrained zero-shot evaluation
│   ├── task_002_finetuned_eval.md        # Fine-tuned evaluation metrics
│   ├── summary_pretrained_vs_finetuned.md # Comparison & gain tables
│   ├── task_003_inference.md             # Multi-resolution latency & FPS
│   └── model_profiling_finetuned.md      # FLOPs, parameters, memory profiling
│
├── models/
│   ├── export_weights.py         # Export PyTorch weights to ONNX with ONNX Slim
│   ├── model_loader.py           # Model zoo loader
│   └── profiler.py               # Parameters & FLOPs profiler
│
├── edge_inference/
│   ├── inference.py              # Package-free Jetson TensorRT runner
│   ├── compatibility.py          # Dynamic-shape compatibility rewrite
│   ├── yolov8_compat.py          # Legacy YOLOv8 compatibility rewrite
│   └── generate_report.py        # Consolidated edge report generator
│
└── scripts/
    └── setup.sh                  # Environment setup
```

---

## 🚀 Quick Start & Usage

### 1. Environment Setup
```bash
conda activate vision
pip install -r requirements.txt
bash scripts/setup.sh
```

### 2. Pretrained Zero-Shot Evaluation (Task 1)
```bash
python test.py --dataset infra
bash scripts/run_test.sh
```

### 3. Fine-Tuning 30 Epochs (Task 2)
```bash
python train.py --model yolov8n --dataset survivor --epochs 30
bash scripts/run_train.sh
```

### 4. Multi-Resolution Inference Benchmarking (Task 3)
```bash
python inference.py --all-checkpoints --device 0
```

### RTX 3060 Reproduction

Use the dedicated portable runner. It verifies the RTX 3060, accepts external
checkpoint/dataset locations, and writes a separate report. Place the prepared
validation images under `datasets/{infra,survivor,combined}/images/val`, then:

```bash
bash scripts/run_rtx3060_inference.sh
```

See [`docs/rtx3060_inference.md`](docs/rtx3060_inference.md) for the smoke test,
full run, required files, and output locations. See
[`docs/dataset_sources.md`](docs/dataset_sources.md) for authoritative dataset
download URLs, provenance, expected image counts, and exact placement.

### 5. Edge Deployment on Jetson Nano

```bash
JETSON_PASSWORD='<password>' bash scripts/run_edge.sh
```

Verified results: **9/9 successful runs**. At 640 px, GPU-only throughput was
18.40 FPS (`yolov8n_infra`), 13.93 FPS (`yolov3-tinyu_survivor`), and 18.22 FPS
(`yolo11n_combined`). See [`results/task_003_edge_inference.md`](results/task_003_edge_inference.md)
and [`docs/jetson_deployment.md`](docs/jetson_deployment.md).

## 💾 Model Checkpoints & Google Drive Download

All essential model checkpoints required to reproduce our benchmark (Task 1 Pretrained zero-shot evaluation, Task 2 Fine-tuned models, and Task 3 Multi-Resolution inference & Jetson Nano edge deployment) are packaged under [`final_checkpoints/`](final_checkpoints/):

> 🔗 **Google Drive Master Folder**: [Download All Checkpoints (Google Drive)](https://drive.google.com/open?id=1izhIWZVEntqZbcQ0Pk39UR3MnjCDSfgw)

| Checkpoint Category | Count | Total Size | Description | Google Drive Link |
|:---|:---:|:---:|:---|:---:|
| **`final_checkpoints/finetuned/`** | **84 models** | **~4.8 GB** | All 84 best fine-tuned PyTorch weights (`{model}_{dataset}.pt`) | [Download Fine-Tuned Weights](https://drive.google.com/open?id=1izhIWZVEntqZbcQ0Pk39UR3MnjCDSfgw) |
| **`final_checkpoints/pretrained/`** | **28 models** | **~1.4 GB** | All 28 baseline COCO pretrained `.pt` models | [Download Pretrained Weights](https://drive.google.com/open?id=1izhIWZVEntqZbcQ0Pk39UR3MnjCDSfgw) |
| **`final_checkpoints/onnx/`** | **84 models** | **~8.8 GB** | All 84 exported ONNX models for Jetson Nano / Edge | [Download ONNX Models](https://drive.google.com/open?id=1izhIWZVEntqZbcQ0Pk39UR3MnjCDSfgw) |

### 🚀 Direct Reproduction Commands:
```bash
# 1. Evaluate any fine-tuned checkpoint directly:
python -c "from ultralytics import YOLO; model = YOLO('final_checkpoints/finetuned/yolov8n_infra.pt'); model.val(data='configs/datasets/infra.yaml', imgsz=640)"

# 2. Benchmark inference latency & FPS:
python inference.py --model final_checkpoints/finetuned/yolov8n_infra.pt --dataset infra --imgsz 640

# 3. Test pretrained zero-shot baseline (Task 1):
python test.py --model yolov8n --dataset infra
```

---

## 📄 License
This project is released under the MIT License for research and academic evaluation.

