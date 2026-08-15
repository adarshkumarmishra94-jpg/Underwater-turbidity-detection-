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

Object detection in turbid underwater environments presents severe challenges including light scattering, color degradation, severe attenuation, and floating particulates. 

This repository provides a multi-dimensional empirical benchmark evaluating
**28 YOLO model architectures** across **3 specialized underwater datasets**
(totaling **84 fine-tuned model records** and **252 multi-resolution inference
evaluations**).

## 🎯 Key Benchmark Scope

- *28 YOLO architectures* — YOLOv3 to YOLOv11
- *3 specialized datasets* — Infrastructure, Survivor, and Combined Marine
- *Pretrained evaluation*
- *Fine-tuned evaluation*
- *Multi-resolution inference benchmarking*
- *Latency and FPS analysis*
- *Model parameters and FLOPs profiling*
- *ONNX export and TensorRT deployment*
- *NVIDIA Jetson Nano edge inference*

---

## 🗄️ Datasets

The benchmark evaluates three specialized underwater datasets:

| Dataset | Classes | Application |
|---|---|---|
| *INFRA* | 2 — crack, corrosion | Infrastructure inspection |
| *SURVIVOR* | 1 — person | Underwater search & rescue |
| *COMBINED* | 19 marine classes | General marine object detection |

Dataset configuration files are available in:

```text
configs/datasets/
├── infra.yaml
├── survivor.yaml
└── combined.yaml

---

## 🏆 Benchmark Results Summary

> Comparison of pretrained and fine-tuned YOLO models across the evaluated underwater datasets.

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

#### 🔹 Combined Marine Detection (19 Classes)
| Rank | Model | Parameters | GFLOPs | Fine-Tuned mAP50 | Fine-Tuned mAP50-95 | Latency @ 640 | FPS @ 640 |
|:---:|:---|:---:|:---:|:---:|:---:|:---:|:---:|
| 🥇 | **`yolov9s`** | 7.29M | 27.42 | **0.7668** | 0.5849 | 32.23 ms | 31.0 FPS |
| 🥈 | **`yolov5xu`** | 97.22M | 246.99 | **0.7599** | 0.6020 | 32.47 ms | 30.8 FPS |
| 🥉 | **`yolov8l`** | 43.64M | 165.48 | **0.7584** | 0.5978 | 25.89 ms | 38.6 FPS |
| 4 | **`yolov9e`** | 58.16M | 192.75 | **0.7565** | 0.5997 | 40.24 ms | 24.9 FPS |
| 5 | **`yolov10m`** | 16.51M | 64.08 | **0.7564** | 0.5929 | 25.74 ms | 38.9 FPS |

#### 🔹 Subsea Infrastructure & Structural Inspection (`INFRA`)
| Rank | Model | Parameters | GFLOPs | Fine-Tuned mAP50 | Fine-Tuned mAP50-95 | Latency @ 640 | FPS @ 640 |
|:---:|:---|:---:|:---:|:---:|:---:|:---:|:---:|
| 🥇 | **`yolov8l`** | 43.63M | 165.41 | **0.6731** | 0.4816 | 13.92 ms | 71.8 FPS |
| 🥈 | **`yolov8m`** | 25.86M | 79.07 | **0.6498** | 0.4790 | 16.90 ms | 59.2 FPS |
| 🥉 | **`yolo11m`** | 20.05M | 68.19 | **0.6385** | 0.4661 | 20.97 ms | 47.7 FPS |
| 4 | **`yolov8x`** | 68.15M | 258.13 | **0.6347** | 0.4814 | 22.12 ms | 45.2 FPS |
| 5 | **`yolo11s`** | 9.43M | 21.55 | **0.6338** | 0.4702 | 18.56 ms | 53.9 FPS |

#### 🔹 Search & Rescue / Diver Rescue (`SURVIVOR`)
| Rank | Model | Parameters | GFLOPs | Fine-Tuned mAP50 | Fine-Tuned mAP50-95 | Latency @ 640 | FPS @ 640 |
|:---:|:---|:---:|:---:|:---:|:---:|:---:|:---:|
| 🥇 | **`yolov3-tinyu`** | 12.13M | 19.04 | **0.9714** | 0.7872 | 11.81 ms | **84.7 FPS** |
| 🥈 | **`yolov8s`** | 11.14M | 28.65 | **0.9621** | 0.7839 | 14.36 ms | **69.6 FPS** |
| 🥉 | **`yolov8n`** | 3.01M | 8.19 | **0.9564** | 0.7835 | 13.07 ms | **76.5 FPS** |
| 4 | **`yolov5su`** | 9.12M | 24.04 | **0.9430** | 0.7433 | 17.59 ms | **56.9 FPS** |
| 5 | **`yolov5nu`** | 2.51M | 7.18 | **0.9379** | 0.7625 | 16.47 ms | **60.7 FPS** |

---

## ⚡ A100 Multi-Resolution Inference summary

The application benchmark times the full framework prediction call over each
real validation split. Values below are means over all 28 fine-tuned models;
they are not Jetson engine-only measurements.

| Dataset | Mean FPS @ 224×224 | Mean FPS @ 480×480 | Mean FPS @ 640×640 |
|:---|---:|---:|---:|
| **`INFRA`** | 56.94 | 52.91 | 51.90 |
| **`SURVIVOR`** | 56.56 | 52.20 | 51.58 |
| **`COMBINED`** | 40.33 | 38.36 | 36.82 |

---

## 📂 Repository Structure

```
text
turbid_review/
├── README.md                              # This document
├── requirements.txt                       # Python dependencies
│
├── configs/
│   ├── datasets/                          # Dataset definitions
│   │   ├── infra.yaml                     # 2 classes (crack, corrosion)
│   │   ├── survivor.yaml                  # 1 class (person)
│   │   └── combined.yaml                  # 19 marine classes
│   ├── models.yaml                        # 28 registered YOLO model variants
│   └── train_config.yaml                  # Hyperparameters (30 epochs, 640 imgsz)
│
├── checkpoints/
│   ├── pretrained/                        # Pretrained COCO baseline weights
│   ├── exports/                           # Exported ONNX models for Jetson Nano
│   └── {model}_{dataset}/                 # Fine-tuned checkpoints
│
├── results/
│   ├── task_001_pretrained_eval.md        # Pretrained zero-shot evaluation
│   ├── task_002_finetuned_eval.md         # Fine-tuned evaluation metrics
│   ├── summary_pretrained_vs_finetuned.md # Comparison & gain tables
│   ├── task_003_inference.md              # Multi-resolution latency & FPS
│   └── model_profiles_finetuned.md        # FLOPs, parameters, and memory profiling
│
├── models/
│   ├── export_onnx.py                     # Export PyTorch weights to ONNX
│   ├── model_registry.py                  # Model zoo loader
│   └── profile_model.py                   # Parameter & FLOPs profiler
│
├── edge_inference/
│   ├── inference_trt.py                   # Jetson TensorRT runner
│   ├── patch_onnx_trt8.py                 # Dynamic-grid compatibility rewrite
│   ├── fold_static_pads.py                # Legacy YOLOv3 compatibility rewrite
│   └── generate_report.py                 # Edge report generator
│
├── scripts/
│   ├── setup.sh                           # Environment setup
│   ├── run_test.sh                        # Task 1 runner
│   ├── run_train.sh                       # Task 2 fine-tuning runner
│   ├── run_inference.sh                   # Task 3 inference runner
│   ├── run_rtx3060_inference.sh           # RTX 3060 runner
│   ├── run_edge.sh                        # Jetson Nano deployment
│   └── run_post_training.sh               # Post-training automation
│
├── test.py                                # Task 1 evaluation entrypoint
├── train.py                               # Task 2 training entrypoint
└── inference.py                           # Task 3 benchmarking
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
# Or evaluate all 84 model-dataset combinations:
bash scripts/run_test.sh
```

### 3. Fine-Tuning 30 Epochs (Task 2)
```bash
python train.py --model yolov8n --dataset survivor --epochs 30
# Or launch full benchmark suite:
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
The edge workflow uses the Nano's pre-installed TensorRT 8.0 runtime, stages one
model/engine at a time under `/data`, and installs no packages. The default run
benchmarks one representative model per dataset on 50 images at all three sizes:
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

