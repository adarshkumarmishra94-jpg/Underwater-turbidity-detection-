# Project Progress — Turbid Review

> **Last Updated**: 2026-08-12
> **Status**: ✅ Benchmark and representative Jetson validation complete; IEEE paper v1 drafted

---

## 🏆 Executive Summary

| Phase / Task | Description | Runs | Status | Primary Artifacts |
|:---|:---|:---:|:---:|:---|
| **Phase 0: Setup** | Conda env, datasets, WandB, scripts | — | **COMPLETE ✅** | `docs/dataset_analysis.md`, `configs/` |
| **Phase 1: Task 1** | Pretrained Zero-Shot Evaluation | 84 / 84 | **COMPLETE ✅** | [`results/task_001_pretrained_eval.md`](file:///workspace/projects/vision/turbid_review/results/task_001_pretrained_eval.md) |
| **Phase 2: Task 2** | Fine-Tuning 28 YOLO Models (30 epochs) | 84 / 84 | **COMPLETE ✅** | [`results/summary_pretrained_vs_finetuned.md`](file:///workspace/projects/vision/turbid_review/results/summary_pretrained_vs_finetuned.md) |
| **Phase 3: Task 3a** | Multi-Resolution Latency/FPS (224, 480, 640) | 252 / 252 | **COMPLETE ✅** | [`results/task_003_inference.md`](file:///workspace/projects/vision/turbid_review/results/task_003_inference.md) |
| **Phase 3: Task 3b** | Model Profiling (FLOPs, Params, Memory) | 84 / 84 | **COMPLETE ✅** | [`results/model_profiles_finetuned.md`](file:///workspace/projects/vision/turbid_review/results/model_profiles_finetuned.md) |
| **Phase 3: Task 3c** | ONNX Export with Graph Optimization | 84 / 84 | **COMPLETE ✅** | [`checkpoints/exports/`](file:///workspace/projects/vision/turbid_review/checkpoints/exports/) |
| **Phase 3: Task 3d** | Jetson Nano TensorRT Edge Inference | 9 / 9 | **COMPLETE ✅** | [`results/task_003_edge_inference.md`](results/task_003_edge_inference.md) |
| **Phase 3: Task 3e** | RTX 3060 Reproduction | 0 / 252 | **RUNNER READY ⏳** | [`scripts/run_rtx3060_inference.sh`](scripts/run_rtx3060_inference.sh) |
| **Phase 4: Paper v1** | Anonymous IEEE conference first draft | 5 / 7 pages | **COMPLETE ✅** | [`paper_v1/paper_v1.pdf`](paper_v1/paper_v1.pdf) |

---

## 📊 Dataset-Level Performance Highlights

```
Dataset       Runs    Pretrained mAP50    Fine-Tuned mAP50    Absolute Gain    Fine-Tuned mAP50-95
──────────────────────────────────────────────────────────────────────────────────────────────────
INFRA          26          0.0085              0.6048            +0.5964               0.4405
SURVIVOR       28          0.3612              0.9035            +0.5422               0.7057
COMBINED       25          0.0146              0.7422            +0.7277               0.5700
```

Primary aggregates exclude five archived fine-tuning records that did not
report the complete 30-epoch schedule.

---

## 🥇 Top Performing YOLO Models per Dataset

### 1. `COMBINED` Dataset (19 Underwater Biological & Man-Made Classes)
- **Top 1**: **`yolov9s`** — **`mAP50 = 0.7668`** (+75.2 pp) | `mAP50-95 = 0.5849`
- **Top 2**: **`yolov5xu`** — **`mAP50 = 0.7599`** (+74.1 pp) | `mAP50-95 = 0.6020`
- **Top 3**: **`yolov8l`** — **`mAP50 = 0.7584`** (+74.4 pp) | `mAP50-95 = 0.5978`
- **Top 4**: **`yolov9e`** — **`mAP50 = 0.7565`** (+74.9 pp) | `mAP50-95 = 0.5997`
- **Top 5**: **`yolov10m`** — **`mAP50 = 0.7564`** (+74.7 pp) | `mAP50-95 = 0.5929`

### 2. `INFRA` Dataset (Underwater Infrastructure Inspection: Cracks & Corrosion)
- **Top 1**: **`yolov8l`** — **`mAP50 = 0.6731`** (+66.5 pp) | `mAP50-95 = 0.4816`
- **Top 2**: **`yolov8m`** — **`mAP50 = 0.6498`** (+64.4 pp) | `mAP50-95 = 0.4790`
- **Top 3**: **`yolo11m`** — **`mAP50 = 0.6385`** (+62.4 pp) | `mAP50-95 = 0.4661`

### 3. `SURVIVOR` Dataset (Maritime Search & Rescue: Underwater Person Detection)
- **Top 1**: **`yolov3-tinyu`** — **`mAP50 = 0.9714`** (+78.3 pp) | `mAP50-95 = 0.7872`
- **Top 2**: **`yolov8s`** — **`mAP50 = 0.9621`** (+66.0 pp) | `mAP50-95 = 0.7839`
- **Top 3**: **`yolov8n`** — **`mAP50 = 0.9564`** (+68.1 pp) | `mAP50-95 = 0.7835`

---

## ⚡ A100 Multi-Resolution Inference Summary

| Dataset | Mean FPS @ 224×224 | Mean FPS @ 480×480 | Mean FPS @ 640×640 |
|:---|---:|---:|---:|
| **`INFRA`** | 56.94 | 52.91 | 51.90 |
| **`SURVIVOR`** | 56.56 | 52.20 | 51.58 |
| **`COMBINED`** | 40.33 | 38.36 | 36.82 |

---

## 📦 Edge Deployment on Jetson Nano
All **84 ONNX models** are exported in [`checkpoints/exports/`](file:///workspace/projects/vision/turbid_review/checkpoints/exports/).
Representative TensorRT FP16 inference was validated on the connected 4 GB
Jetson Nano using 50 images per point:

| Model / Dataset | GPU FPS @ 224 | GPU FPS @ 480 | GPU FPS @ 640 | End-to-end FPS @ 640 |
|---|---:|---:|---:|---:|
| `yolov8n_infra` | 56.47 | 35.66 | 18.40 | 11.69 |
| `yolov3-tinyu_survivor` | 39.12 | 23.65 | 13.93 | 9.74 |
| `yolo11n_combined` | 64.91 | 33.71 | 18.22 | 8.58 |

Re-run the storage-aware default suite with:
```bash
JETSON_PASSWORD='<password>' bash /workspace/projects/vision/turbid_review/scripts/run_edge.sh
```

## 📥 Portable Dataset Handoff

Authoritative raw-source/download URLs, the derived-dataset warning, exact
validation counts, and the standard clone-local placement are documented in
[`docs/dataset_sources.md`](docs/dataset_sources.md). The RTX 3060 runner now
defaults to those paths and validates 940 INFRA, 218 SURVIVOR, and 3,169
COMBINED validation images before starting.

## 📝 IEEE Conference Paper v1

The first anonymous paper draft is complete under [`paper_v1/`](paper_v1/):

- title: *Transfer Behavior and Accuracy--Efficiency Frontiers of YOLO
  Detectors in Turbid Water*;
- five IEEE two-column pages, within the seven-page limit;
- 12 verified literature entries;
- modular source plus a generated, fully inlined `submission.tex`;
- Matplotlib result plots and one explicitly marked conceptual image generated
  with `image_gen`;
- validated PDFs and `paper_v1_submission_sources.zip`.

Run `make package` inside `paper_v1/` to rebuild the standalone PDF, execute
anonymity/page/citation/source-consistency checks, and recreate the source ZIP.
