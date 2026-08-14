# Pretrained vs. Fine-Tuned Benchmark Comparison Summary

> Corrected: 2026-08-12 | 84 archived checkpoint evaluations; 79 complete
> 30-epoch schedules used for the primary aggregate comparison

Five archived fine-tuning records report fewer than 30 epochs
(`yolo11l_combined`, `yolo11m_combined`, `yolo11s_combined`,
`yolov10l_infra`, and `yolov9c_infra`). They remain in the raw Task 2 result
file but are excluded here to avoid mixing incomplete schedules with the
controlled 30-epoch comparison. The earlier version of this summary reported
81 models and used an outdated 28-model COMBINED average.

## 📊 Dataset-Level Summary

| Dataset | Pretrained mAP50 | Fine-Tuned mAP50 | mAP50 Gain (pp) | Pretrained mAP50-95 | Fine-Tuned mAP50-95 | mAP50-95 Gain (pp) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|
| **COMBINED** (n=25) | 0.0146 | **0.7422** | **+72.8 pp** | 0.0079 | **0.5700** | **+56.2 pp** |
| **INFRA** (n=26) | 0.0085 | **0.6048** | **+59.6 pp** | 0.0039 | **0.4405** | **+43.7 pp** |
| **SURVIVOR** (n=28) | 0.3612 | **0.9035** | **+54.2 pp** | 0.2121 | **0.7058** | **+49.4 pp** |

## 🏆 Top Fine-Tuned Models per Dataset (by mAP50)

### COMBINED Dataset
| Model | Pretrained mAP50 | Fine-Tuned mAP50 | mAP50 Gain | Pretrained mAP50-95 | Fine-Tuned mAP50-95 |
|:---|:---:|:---:|:---:|:---:|:---:|
| **yolov9s** | 0.0148 | **0.7668** | +75.2 pp | 0.0080 | 0.5849 |
| **yolov5xu** | 0.0186 | **0.7599** | +74.1 pp | 0.0104 | 0.6020 |
| **yolov8l** | 0.0146 | **0.7584** | +74.4 pp | 0.0080 | 0.5978 |
| **yolov9e** | 0.0074 | **0.7565** | +74.9 pp | 0.0038 | 0.5997 |
| **yolov10m** | 0.0090 | **0.7564** | +74.7 pp | 0.0042 | 0.5929 |

### INFRA Dataset
| Model | Pretrained mAP50 | Fine-Tuned mAP50 | mAP50 Gain | Pretrained mAP50-95 | Fine-Tuned mAP50-95 |
|:---|:---:|:---:|:---:|:---:|:---:|
| **yolov8l** | 0.0084 | **0.6731** | +66.5 pp | 0.0046 | 0.4816 |
| **yolov8m** | 0.0062 | **0.6498** | +64.4 pp | 0.0022 | 0.4790 |
| **yolo11m** | 0.0144 | **0.6385** | +62.4 pp | 0.0074 | 0.4661 |
| **yolov8x** | 0.0047 | **0.6347** | +63.0 pp | 0.0030 | 0.4814 |
| **yolo11s** | 0.0082 | **0.6338** | +62.6 pp | 0.0044 | 0.4702 |

### SURVIVOR Dataset
| Model | Pretrained mAP50 | Fine-Tuned mAP50 | mAP50 Gain | Pretrained mAP50-95 | Fine-Tuned mAP50-95 |
|:---|:---:|:---:|:---:|:---:|:---:|
| **yolov3-tinyu** | 0.1886 | **0.9714** | +78.3 pp | 0.0899 | 0.7872 |
| **yolov8s** | 0.3020 | **0.9621** | +66.0 pp | 0.1817 | 0.7839 |
| **yolov8n** | 0.2757 | **0.9564** | +68.1 pp | 0.1653 | 0.7835 |
| **yolov5su** | 0.3571 | **0.9430** | +58.6 pp | 0.1846 | 0.7433 |
| **yolov5nu** | 0.2415 | **0.9379** | +69.6 pp | 0.1321 | 0.7625 |
