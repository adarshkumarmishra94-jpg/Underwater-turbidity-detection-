# Jetson Nano Deployment Guide

## Device Specifications

| Spec | Value |
|------|-------|
| **Device** | NVIDIA Jetson Nano |
| **RAM** | 4 GB (shared CPU+GPU) |
| **Storage (root)** | `/dev/mmcblk0p1` — 14 GB (12 GB used, 1.1 GB free at validation) |
| **Storage (data)** | `/dev/sda1` — 30 GB (22 GB used, 6.3 GB free at validation) |
| **SSH** | `nvidia@10.0.16.65` |
| **GPU** | 128-core Maxwell |
| **JetPack / CUDA** | JetPack 4.6 (L4T 32.6.1) / CUDA 10.2 |
| **Inference runtime** | TensorRT 8.0.1.6 (pre-installed) |

## Important Constraints

1. **DO NOT install any packages** on Jetson Nano — all packages are pre-installed
2. **DO NOT use pip** on Jetson
3. **Use `/data/turbid_review/`** for all data (mounted on `/dev/sda1` with 6.3 GB free at validation)
4. **Only 50 images** per inference run (storage constraint)
5. **One model and one engine at a time** — both are removed after each run
6. **Use TensorRT already supplied by JetPack**; ONNX Runtime and Ultralytics are not required on the Nano

## Directory Structure on Jetson

```
/data/turbid_review/
├── models/        # One transient ONNX + one transient TensorRT engine
├── images/        # At most 50 samples/dataset; removed at run end
├── results/       # Small build logs and reusable TensorRT timing cache
└── scripts/       # Lightweight TensorRT runner
```

## Workflow

### Run the representative edge suite

```bash
cd /workspace/projects/vision/turbid_review
JETSON_PASSWORD='<password>' bash scripts/run_edge.sh
```

The default suite benchmarks one edge-focused model per dataset at 224, 480,
and 640 pixels, with 50 images per point:

- `yolov8n_infra`
- `yolov3-tinyu_survivor`
- `yolo11n_combined`

Run a single model or explicitly opt into the expensive 84-model sweep:

```bash
JETSON_PASSWORD='<password>' bash scripts/run_edge.sh --model yolov8n_infra
JETSON_PASSWORD='<password>' bash scripts/run_edge.sh --all
```

Useful overrides:

```bash
JETSON_PASSWORD='<password>' bash scripts/run_edge.sh \
  --sizes 224,480 --max-images 20 --warmup 3
```

The script performs all of the following without installing anything:

1. Checks the existing TensorRT/OpenCV/NumPy runtime and disk/memory state.
2. Exports only the selected model, rather than re-exporting all 84 models.
3. Applies TensorRT 8.0 compatibility rewrites locally.
4. Transfers images once per dataset and a single ONNX model at a time.
5. Builds a hardware-specific FP16 engine on the Nano with a reusable timing cache.
6. Measures GPU-only and end-to-end latency, retrieves JSON, and deletes images/models/engines.

Modern models use one dynamic ONNX transfer for all three resolutions. Legacy
YOLOv3 models use fixed-shape ONNX exports because TensorRT 8.0 requires their
`Pad` inputs to be constant initializers.

## Verified results (2026-08-12)

The completed 9/9-run report is in
[`results/task_003_edge_inference.md`](../results/task_003_edge_inference.md).
Every point used 50 real validation images, FP16, batch size 1, and five warmups.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Out of memory | Select nano/tiny models, reduce size, or lower `--workspace` |
| Storage full | Confirm transient files under `/data/turbid_review`; never stage on `/` |
| SSH timeout | Check `ssh nvidia@10.0.16.65` and network reachability |
| Dynamic `Range` parse error | Run through `run_edge.sh`; it applies the INT32 rewrite |
| Dynamic `Pad` parse error | Run through `run_edge.sh`; it falls back to fixed-shape exports |
| Slow first run | Engine tactic selection is a one-time cost; the timing cache is retained |
