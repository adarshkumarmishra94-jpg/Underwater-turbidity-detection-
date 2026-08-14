# Task 3 — Edge Inference Results (Jetson Nano)

> Generated: 2026-08-12 07:13:10 UTC
> Device: NVIDIA Jetson Nano 4 GB | TensorRT FP16 | batch 1
> GPU latency measures TensorRT execution; end-to-end latency includes image read, letterbox preprocessing, transfers, inference, output copy, and NMS.

| Model | Dataset | Size | Images | GPU ms | GPU FPS | End-to-end ms | End-to-end FPS | Detections | Status |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| yolo11n_combined | combined | 224 | 50 | 15.41 | 64.91 | 67.61 | 14.79 | 65 | ✅ |
| yolo11n_combined | combined | 480 | 50 | 29.66 | 33.71 | 77.43 | 12.91 | 48 | ✅ |
| yolo11n_combined | combined | 640 | 50 | 54.88 | 18.22 | 116.55 | 8.58 | 51 | ✅ |
| yolov3-tinyu_survivor | survivor | 224 | 50 | 25.56 | 39.12 | 54.17 | 18.46 | 57 | ✅ |
| yolov3-tinyu_survivor | survivor | 480 | 50 | 42.29 | 23.65 | 81.91 | 12.21 | 82 | ✅ |
| yolov3-tinyu_survivor | survivor | 640 | 50 | 71.78 | 13.93 | 102.64 | 9.74 | 84 | ✅ |
| yolov8n_infra | infra | 224 | 50 | 17.71 | 56.47 | 45.89 | 21.79 | 50 | ✅ |
| yolov8n_infra | infra | 480 | 50 | 28.04 | 35.66 | 54.33 | 18.41 | 74 | ✅ |
| yolov8n_infra | infra | 640 | 50 | 54.35 | 18.40 | 85.55 | 11.69 | 72 | ✅ |

## Verification summary

- Successful benchmark runs: 9 / 9
- No packages were installed on the Jetson.
- Remote artifacts were staged under `/data/turbid_review`; models and engines were removed after each model.
- Source images were transferred once per dataset, capped by `--max-images`, and removed after the run.
