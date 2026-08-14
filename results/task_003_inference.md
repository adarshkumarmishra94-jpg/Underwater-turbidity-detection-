# Task 3 — Inference Benchmark Results (Multi-Size)

> Generated: 2026-08-11 06:53:10
> Device: NVIDIA A100-SXM4-40GB
> Image Sizes: 224×224, 480×480, 640×640
> Conf: 0.25 | IoU: 0.45

## Image Size: 224×224

| Model | Dataset | Images | Avg Latency (ms) | Median (ms) | Min (ms) | Max (ms) | FPS | Detections | Status |
|-------|---------|--------|------------------|-------------|----------|----------|-----|------------|--------|
| yolo11l_combined | combined | 3169 | 33.0 | 30.7 | 17.5 | 90.3 | 30.3 | 7909 | ✅ |
| yolo11l_infra | infra | 940 | 25.7 | 21.6 | 18.4 | 72.9 | 38.9 | 1038 | ✅ |
| yolo11l_survivor | survivor | 218 | 24.8 | 21.6 | 18.4 | 47.0 | 40.3 | 176 | ✅ |
| yolo11m_combined | combined | 3169 | 27.5 | 24.4 | 12.3 | 82.8 | 36.4 | 7066 | ✅ |
| yolo11m_infra | infra | 940 | 19.6 | 15.8 | 13.1 | 59.5 | 50.9 | 1034 | ✅ |
| yolo11m_survivor | survivor | 218 | 19.9 | 16.1 | 13.1 | 37.1 | 50.3 | 208 | ✅ |
| yolo11n_combined | combined | 3169 | 24.0 | 20.9 | 9.7 | 80.1 | 41.6 | 4772 | ✅ |
| yolo11n_infra | infra | 940 | 16.4 | 13.2 | 10.7 | 62.5 | 60.9 | 968 | ✅ |
| yolo11n_survivor | survivor | 218 | 17.3 | 13.4 | 10.6 | 39.2 | 57.7 | 219 | ✅ |
| yolo11s_combined | combined | 3169 | 24.9 | 22.0 | 10.1 | 81.6 | 40.1 | 7647 | ✅ |
| yolo11s_infra | infra | 940 | 17.4 | 13.4 | 10.7 | 57.7 | 57.3 | 1012 | ✅ |
| yolo11s_survivor | survivor | 218 | 17.1 | 13.3 | 10.8 | 35.9 | 58.3 | 218 | ✅ |
| yolo11x_combined | combined | 3169 | 32.4 | 31.0 | 17.9 | 75.8 | 30.9 | 8868 | ✅ |
| yolo11x_infra | infra | 940 | 26.3 | 22.0 | 18.9 | 67.9 | 38.1 | 1129 | ✅ |
| yolo11x_survivor | survivor | 218 | 25.5 | 21.9 | 18.8 | 46.8 | 39.3 | 183 | ✅ |
| yolov10b_combined | combined | 3169 | 24.6 | 22.4 | 11.8 | 71.5 | 40.6 | 7174 | ✅ |
| yolov10b_infra | infra | 940 | 18.3 | 15.3 | 12.8 | 45.0 | 54.6 | 1163 | ✅ |
| yolov10b_survivor | survivor | 218 | 18.5 | 16.4 | 13.0 | 38.3 | 54.1 | 152 | ✅ |
| yolov10l_combined | combined | 3169 | 26.9 | 24.6 | 14.1 | 68.6 | 37.2 | 8321 | ✅ |
| yolov10l_infra | infra | 940 | 20.1 | 17.6 | 14.8 | 32.5 | 49.7 | 876 | ✅ |
| yolov10l_survivor | survivor | 218 | 20.3 | 17.8 | 15.1 | 38.7 | 49.3 | 183 | ✅ |
| yolov10m_combined | combined | 3169 | 24.2 | 22.1 | 11.6 | 66.9 | 41.4 | 7549 | ✅ |
| yolov10m_infra | infra | 940 | 17.4 | 14.9 | 12.3 | 51.5 | 57.4 | 1192 | ✅ |
| yolov10m_survivor | survivor | 218 | 18.2 | 15.8 | 12.4 | 38.1 | 55.0 | 131 | ✅ |
| yolov10n_combined | combined | 3169 | 21.8 | 19.4 | 8.9 | 61.0 | 45.9 | 6017 | ✅ |
| yolov10n_infra | infra | 940 | 14.9 | 12.1 | 9.7 | 37.2 | 67.3 | 959 | ✅ |
| yolov10n_survivor | survivor | 218 | 16.1 | 13.7 | 10.0 | 34.6 | 62.2 | 220 | ✅ |
| yolov10s_combined | combined | 3169 | 22.2 | 19.9 | 9.3 | 71.1 | 45.1 | 7554 | ✅ |
| yolov10s_infra | infra | 940 | 15.2 | 12.6 | 10.4 | 31.2 | 65.9 | 971 | ✅ |
| yolov10s_survivor | survivor | 218 | 16.6 | 14.4 | 10.3 | 35.9 | 60.2 | 179 | ✅ |
| yolov10x_combined | combined | 3169 | 27.8 | 25.4 | 14.7 | 68.2 | 35.9 | 7746 | ✅ |
| yolov10x_infra | infra | 940 | 21.0 | 18.4 | 15.6 | 66.5 | 47.5 | 1100 | ✅ |
| yolov10x_survivor | survivor | 218 | 21.1 | 18.8 | 15.6 | 40.9 | 47.4 | 120 | ✅ |
| yolov3-tinyu_combined | combined | 3169 | 17.1 | 15.6 | 4.3 | 62.1 | 58.4 | 5143 | ✅ |
| yolov3-tinyu_infra | infra | 940 | 11.0 | 7.6 | 5.2 | 37.9 | 91.2 | 1001 | ✅ |
| yolov3-tinyu_survivor | survivor | 218 | 10.3 | 7.5 | 4.9 | 25.3 | 96.6 | 204 | ✅ |
| yolov3u_combined | combined | 3169 | 23.9 | 22.0 | 9.8 | 68.1 | 41.8 | 8147 | ✅ |
| yolov3u_infra | infra | 940 | 18.1 | 13.5 | 10.9 | 33.4 | 55.1 | 1117 | ✅ |
| yolov3u_survivor | survivor | 218 | 16.9 | 13.3 | 10.3 | 39.8 | 59.3 | 197 | ✅ |
| yolov5lu_combined | combined | 3169 | 26.2 | 24.5 | 12.3 | 70.9 | 38.2 | 8607 | ✅ |
| yolov5lu_infra | infra | 940 | 20.0 | 16.0 | 13.1 | 42.3 | 50.1 | 1054 | ✅ |
| yolov5lu_survivor | survivor | 218 | 19.2 | 16.0 | 12.9 | 35.2 | 52.0 | 180 | ✅ |
| yolov5mu_combined | combined | 3169 | 25.3 | 22.3 | 10.2 | 82.5 | 39.5 | 8070 | ✅ |
| yolov5mu_infra | infra | 940 | 18.2 | 14.1 | 11.1 | 46.4 | 55.0 | 1014 | ✅ |
| yolov5mu_survivor | survivor | 218 | 17.7 | 14.1 | 11.4 | 36.4 | 56.4 | 207 | ✅ |
| yolov5nu_combined | combined | 3169 | 22.8 | 20.0 | 8.4 | 83.2 | 43.9 | 5912 | ✅ |
| yolov5nu_infra | infra | 940 | 15.5 | 11.9 | 9.2 | 38.1 | 64.6 | 966 | ✅ |
| yolov5nu_survivor | survivor | 218 | 14.5 | 11.3 | 9.3 | 33.0 | 69.0 | 199 | ✅ |
| yolov5su_combined | combined | 3169 | 23.4 | 20.4 | 8.2 | 81.5 | 42.6 | 7993 | ✅ |
| yolov5su_infra | infra | 940 | 15.4 | 11.9 | 9.3 | 35.8 | 64.9 | 973 | ✅ |
| yolov5su_survivor | survivor | 218 | 16.6 | 13.0 | 9.5 | 34.4 | 60.4 | 229 | ✅ |
| yolov5xu_combined | combined | 3169 | 28.9 | 26.8 | 14.2 | 84.6 | 34.6 | 8631 | ✅ |
| yolov5xu_infra | infra | 940 | 22.0 | 17.9 | 14.9 | 62.1 | 45.5 | 1040 | ✅ |
| yolov5xu_survivor | survivor | 218 | 21.7 | 17.9 | 15.0 | 39.7 | 46.1 | 208 | ✅ |
| yolov8l_combined | combined | 3169 | 25.8 | 23.9 | 11.5 | 80.5 | 38.8 | 7932 | ✅ |
| yolov8l_infra | infra | 940 | 13.2 | 13.1 | 11.4 | 39.4 | 75.5 | 1070 | ✅ |
| yolov8l_survivor | survivor | 218 | 13.1 | 12.7 | 11.4 | 20.6 | 76.1 | 197 | ✅ |
| yolov8m_combined | combined | 3169 | 18.6 | 18.1 | 9.3 | 66.2 | 53.8 | 7792 | ✅ |
| yolov8m_infra | infra | 940 | 15.3 | 12.6 | 10.1 | 34.5 | 65.5 | 1006 | ✅ |
| yolov8m_survivor | survivor | 218 | 15.4 | 12.8 | 10.4 | 36.4 | 65.0 | 195 | ✅ |
| yolov8n_combined | combined | 3169 | 19.5 | 18.0 | 7.6 | 78.3 | 51.3 | 6355 | ✅ |
| yolov8n_infra | infra | 940 | 13.0 | 10.6 | 8.4 | 37.5 | 77.0 | 965 | ✅ |
| yolov8n_survivor | survivor | 218 | 12.4 | 10.3 | 8.4 | 33.2 | 80.8 | 195 | ✅ |
| yolov8s_combined | combined | 3169 | 19.8 | 18.2 | 7.8 | 77.7 | 50.6 | 7457 | ✅ |
| yolov8s_infra | infra | 940 | 11.2 | 10.5 | 8.6 | 37.5 | 89.3 | 1007 | ✅ |
| yolov8s_survivor | survivor | 218 | 13.0 | 10.7 | 8.4 | 37.2 | 77.0 | 222 | ✅ |
| yolov8x_combined | combined | 3169 | 24.1 | 22.2 | 11.4 | 81.8 | 41.5 | 7643 | ✅ |
| yolov8x_infra | infra | 940 | 17.8 | 14.9 | 12.2 | 38.1 | 56.1 | 1060 | ✅ |
| yolov8x_survivor | survivor | 218 | 17.3 | 14.5 | 12.1 | 37.7 | 57.8 | 224 | ✅ |
| yolov9c_combined | combined | 3169 | 26.5 | 25.4 | 14.7 | 92.8 | 37.7 | 7412 | ✅ |
| yolov9c_infra | infra | 940 | 19.3 | 17.8 | 15.6 | 46.4 | 51.7 | 937 | ✅ |
| yolov9c_survivor | survivor | 218 | 20.3 | 18.0 | 15.7 | 45.1 | 49.2 | 209 | ✅ |
| yolov9e_combined | combined | 3169 | 38.8 | 37.4 | 25.5 | 79.2 | 25.8 | 7258 | ✅ |
| yolov9e_infra | infra | 940 | 31.3 | 28.8 | 26.7 | 46.6 | 31.9 | 1047 | ✅ |
| yolov9e_survivor | survivor | 218 | 31.5 | 28.8 | 26.1 | 51.0 | 31.7 | 186 | ✅ |
| yolov9m_combined | combined | 3169 | 27.2 | 25.2 | 14.5 | 92.3 | 36.8 | 7278 | ✅ |
| yolov9m_infra | infra | 940 | 20.6 | 17.7 | 14.9 | 63.9 | 48.6 | 1054 | ✅ |
| yolov9m_survivor | survivor | 218 | 20.7 | 17.4 | 15.2 | 40.0 | 48.4 | 254 | ✅ |
| yolov9s_combined | combined | 3169 | 29.7 | 28.3 | 17.4 | 77.7 | 33.7 | 5857 | ✅ |
| yolov9s_infra | infra | 940 | 24.3 | 21.5 | 18.6 | 55.0 | 41.2 | 989 | ✅ |
| yolov9s_survivor | survivor | 218 | 24.4 | 21.4 | 18.5 | 43.6 | 41.0 | 243 | ✅ |
| yolov9t_combined | combined | 3169 | 28.8 | 27.8 | 16.8 | 71.0 | 34.8 | 5216 | ✅ |
| yolov9t_infra | infra | 940 | 23.5 | 20.7 | 17.7 | 60.0 | 42.6 | 1017 | ✅ |
| yolov9t_survivor | survivor | 218 | 23.4 | 20.6 | 17.8 | 42.9 | 42.8 | 235 | ✅ |

---

## Image Size: 480×480

| Model | Dataset | Images | Avg Latency (ms) | Median (ms) | Min (ms) | Max (ms) | FPS | Detections | Status |
|-------|---------|--------|------------------|-------------|----------|----------|-----|------------|--------|
| yolo11l_combined | combined | 3169 | 34.2 | 31.1 | 17.8 | 88.8 | 29.2 | 14815 | ✅ |
| yolo11l_infra | infra | 940 | 27.2 | 22.6 | 19.5 | 78.4 | 36.7 | 1249 | ✅ |
| yolo11l_survivor | survivor | 218 | 27.5 | 23.9 | 19.7 | 60.4 | 36.4 | 314 | ✅ |
| yolo11m_combined | combined | 3169 | 28.5 | 25.4 | 12.2 | 87.9 | 35.1 | 12894 | ✅ |
| yolo11m_infra | infra | 940 | 20.9 | 16.9 | 14.2 | 32.1 | 47.7 | 1263 | ✅ |
| yolo11m_survivor | survivor | 218 | 20.7 | 16.6 | 13.9 | 40.4 | 48.3 | 321 | ✅ |
| yolo11n_combined | combined | 3169 | 25.4 | 22.3 | 9.9 | 79.7 | 39.4 | 11239 | ✅ |
| yolo11n_infra | infra | 940 | 17.5 | 13.9 | 11.6 | 64.0 | 57.1 | 1205 | ✅ |
| yolo11n_survivor | survivor | 218 | 18.7 | 13.9 | 11.4 | 43.9 | 53.6 | 315 | ✅ |
| yolo11s_combined | combined | 3169 | 26.1 | 22.9 | 10.2 | 79.9 | 38.3 | 14637 | ✅ |
| yolo11s_infra | infra | 940 | 18.9 | 14.7 | 11.5 | 34.7 | 52.9 | 1253 | ✅ |
| yolo11s_survivor | survivor | 218 | 18.9 | 14.3 | 11.7 | 38.4 | 52.9 | 312 | ✅ |
| yolo11x_combined | combined | 3169 | 33.3 | 31.0 | 18.1 | 79.2 | 30.1 | 15007 | ✅ |
| yolo11x_infra | infra | 940 | 26.1 | 22.7 | 19.8 | 69.1 | 38.4 | 1230 | ✅ |
| yolo11x_survivor | survivor | 218 | 27.8 | 24.2 | 19.5 | 74.9 | 36.0 | 324 | ✅ |
| yolov10b_combined | combined | 3169 | 24.9 | 22.7 | 12.1 | 66.1 | 40.1 | 14573 | ✅ |
| yolov10b_infra | infra | 940 | 18.8 | 16.2 | 13.7 | 30.6 | 53.2 | 1276 | ✅ |
| yolov10b_survivor | survivor | 218 | 19.6 | 17.7 | 13.6 | 38.9 | 51.2 | 318 | ✅ |
| yolov10l_combined | combined | 3169 | 27.6 | 25.6 | 14.2 | 65.9 | 36.2 | 14425 | ✅ |
| yolov10l_infra | infra | 940 | 21.6 | 18.7 | 15.9 | 46.2 | 46.4 | 1161 | ✅ |
| yolov10l_survivor | survivor | 218 | 22.1 | 19.4 | 15.7 | 39.5 | 45.3 | 341 | ✅ |
| yolov10m_combined | combined | 3169 | 24.8 | 22.5 | 11.5 | 65.5 | 40.4 | 14598 | ✅ |
| yolov10m_infra | infra | 940 | 18.7 | 16.0 | 13.6 | 41.4 | 53.5 | 1245 | ✅ |
| yolov10m_survivor | survivor | 218 | 18.9 | 16.0 | 13.3 | 51.7 | 53.0 | 317 | ✅ |
| yolov10n_combined | combined | 3169 | 22.4 | 20.5 | 9.2 | 67.8 | 44.6 | 13785 | ✅ |
| yolov10n_infra | infra | 940 | 16.1 | 13.3 | 11.0 | 28.8 | 62.3 | 1135 | ✅ |
| yolov10n_survivor | survivor | 218 | 16.8 | 13.2 | 10.7 | 34.9 | 59.5 | 328 | ✅ |
| yolov10s_combined | combined | 3169 | 22.6 | 20.8 | 9.4 | 63.9 | 44.3 | 14463 | ✅ |
| yolov10s_infra | infra | 940 | 16.6 | 13.6 | 11.1 | 30.0 | 60.4 | 1164 | ✅ |
| yolov10s_survivor | survivor | 218 | 17.2 | 13.9 | 10.9 | 35.0 | 58.2 | 316 | ✅ |
| yolov10x_combined | combined | 3169 | 29.8 | 26.2 | 14.7 | 85.3 | 33.6 | 14845 | ✅ |
| yolov10x_infra | infra | 940 | 22.0 | 19.4 | 16.2 | 60.2 | 45.4 | 1266 | ✅ |
| yolov10x_survivor | survivor | 218 | 22.3 | 18.9 | 16.6 | 51.7 | 44.8 | 294 | ✅ |
| yolov3-tinyu_combined | combined | 3169 | 18.7 | 16.7 | 4.7 | 60.5 | 53.5 | 13051 | ✅ |
| yolov3-tinyu_infra | infra | 940 | 12.0 | 8.6 | 6.0 | 25.3 | 83.4 | 1234 | ✅ |
| yolov3-tinyu_survivor | survivor | 218 | 11.6 | 8.2 | 6.0 | 27.6 | 86.3 | 324 | ✅ |
| yolov3u_combined | combined | 3169 | 26.2 | 22.9 | 10.3 | 70.7 | 38.2 | 14799 | ✅ |
| yolov3u_infra | infra | 940 | 21.0 | 14.9 | 11.3 | 46.0 | 47.6 | 1303 | ✅ |
| yolov3u_survivor | survivor | 218 | 20.0 | 14.2 | 11.8 | 44.5 | 50.0 | 323 | ✅ |
| yolov5lu_combined | combined | 3169 | 27.4 | 25.3 | 12.4 | 70.3 | 36.5 | 14751 | ✅ |
| yolov5lu_infra | infra | 940 | 21.4 | 16.9 | 14.1 | 41.4 | 46.8 | 1291 | ✅ |
| yolov5lu_survivor | survivor | 218 | 20.9 | 16.3 | 13.8 | 41.6 | 48.0 | 318 | ✅ |
| yolov5mu_combined | combined | 3169 | 26.7 | 23.1 | 10.3 | 86.6 | 37.4 | 14709 | ✅ |
| yolov5mu_infra | infra | 940 | 19.5 | 15.0 | 12.5 | 39.6 | 51.2 | 1256 | ✅ |
| yolov5mu_survivor | survivor | 218 | 19.5 | 14.6 | 12.2 | 41.1 | 51.2 | 319 | ✅ |
| yolov5nu_combined | combined | 3169 | 24.3 | 21.2 | 8.5 | 79.5 | 41.1 | 13777 | ✅ |
| yolov5nu_infra | infra | 940 | 16.6 | 12.9 | 10.1 | 33.5 | 60.2 | 1193 | ✅ |
| yolov5nu_survivor | survivor | 218 | 16.5 | 12.5 | 10.2 | 35.5 | 60.6 | 307 | ✅ |
| yolov5su_combined | combined | 3169 | 24.4 | 21.1 | 8.7 | 85.4 | 41.1 | 14512 | ✅ |
| yolov5su_infra | infra | 940 | 16.8 | 13.1 | 10.3 | 36.9 | 59.6 | 1243 | ✅ |
| yolov5su_survivor | survivor | 218 | 17.3 | 13.1 | 10.1 | 40.0 | 57.8 | 330 | ✅ |
| yolov5xu_combined | combined | 3169 | 30.9 | 27.4 | 14.4 | 91.0 | 32.4 | 14924 | ✅ |
| yolov5xu_infra | infra | 940 | 24.5 | 19.0 | 16.1 | 64.6 | 40.8 | 1251 | ✅ |
| yolov5xu_survivor | survivor | 218 | 23.6 | 18.2 | 15.7 | 46.5 | 42.3 | 324 | ✅ |
| yolov8l_combined | combined | 3169 | 26.9 | 24.2 | 11.5 | 82.3 | 37.1 | 14669 | ✅ |
| yolov8l_infra | infra | 940 | 14.2 | 14.1 | 12.4 | 38.9 | 70.4 | 1304 | ✅ |
| yolov8l_survivor | survivor | 218 | 13.8 | 13.4 | 12.6 | 21.3 | 72.3 | 324 | ✅ |
| yolov8m_combined | combined | 3169 | 20.4 | 19.6 | 9.7 | 81.9 | 49.1 | 14642 | ✅ |
| yolov8m_infra | infra | 940 | 16.4 | 13.6 | 10.9 | 41.0 | 61.0 | 1276 | ✅ |
| yolov8m_survivor | survivor | 218 | 16.5 | 13.6 | 11.3 | 36.9 | 60.5 | 321 | ✅ |
| yolov8n_combined | combined | 3169 | 20.8 | 19.1 | 7.9 | 76.4 | 48.1 | 14092 | ✅ |
| yolov8n_infra | infra | 940 | 14.1 | 11.7 | 9.6 | 31.0 | 70.9 | 1213 | ✅ |
| yolov8n_survivor | survivor | 218 | 14.2 | 11.5 | 9.5 | 37.1 | 70.3 | 311 | ✅ |
| yolov8s_combined | combined | 3169 | 21.0 | 19.2 | 8.0 | 78.3 | 47.6 | 14366 | ✅ |
| yolov8s_infra | infra | 940 | 12.7 | 11.5 | 9.3 | 34.4 | 78.9 | 1245 | ✅ |
| yolov8s_survivor | survivor | 218 | 14.0 | 11.5 | 9.7 | 33.3 | 71.4 | 332 | ✅ |
| yolov8x_combined | combined | 3169 | 25.7 | 23.4 | 11.7 | 83.9 | 38.9 | 14625 | ✅ |
| yolov8x_infra | infra | 940 | 19.6 | 16.0 | 13.1 | 45.2 | 50.9 | 1293 | ✅ |
| yolov8x_survivor | survivor | 218 | 19.2 | 15.3 | 13.2 | 41.3 | 52.0 | 341 | ✅ |
| yolov9c_combined | combined | 3169 | 28.3 | 26.7 | 14.9 | 74.0 | 35.3 | 14870 | ✅ |
| yolov9c_infra | infra | 940 | 21.0 | 19.0 | 16.6 | 38.0 | 47.6 | 1280 | ✅ |
| yolov9c_survivor | survivor | 218 | 22.2 | 18.9 | 16.8 | 40.7 | 45.0 | 340 | ✅ |
| yolov9e_combined | combined | 3169 | 39.7 | 37.6 | 25.8 | 95.1 | 25.2 | 14852 | ✅ |
| yolov9e_infra | infra | 940 | 33.9 | 30.5 | 27.3 | 64.6 | 29.5 | 1289 | ✅ |
| yolov9e_survivor | survivor | 218 | 33.7 | 30.0 | 27.3 | 50.5 | 29.7 | 322 | ✅ |
| yolov9m_combined | combined | 3169 | 27.6 | 26.2 | 14.5 | 73.5 | 36.2 | 15092 | ✅ |
| yolov9m_infra | infra | 940 | 20.6 | 18.3 | 16.3 | 55.2 | 48.6 | 1279 | ✅ |
| yolov9m_survivor | survivor | 218 | 22.0 | 18.6 | 15.9 | 53.3 | 45.5 | 342 | ✅ |
| yolov9s_combined | combined | 3169 | 30.7 | 29.4 | 17.8 | 78.9 | 32.6 | 14687 | ✅ |
| yolov9s_infra | infra | 940 | 25.3 | 22.2 | 19.9 | 54.4 | 39.5 | 1255 | ✅ |
| yolov9s_survivor | survivor | 218 | 25.4 | 22.4 | 19.5 | 52.8 | 39.3 | 330 | ✅ |
| yolov9t_combined | combined | 3169 | 30.7 | 28.9 | 17.2 | 70.9 | 32.6 | 14195 | ✅ |
| yolov9t_infra | infra | 940 | 24.7 | 21.6 | 19.1 | 62.8 | 40.5 | 1225 | ✅ |
| yolov9t_survivor | survivor | 218 | 24.8 | 21.5 | 18.7 | 58.3 | 40.3 | 326 | ✅ |

---

## Image Size: 640×640

| Model | Dataset | Images | Avg Latency (ms) | Median (ms) | Min (ms) | Max (ms) | FPS | Detections | Status |
|-------|---------|--------|------------------|-------------|----------|----------|-----|------------|--------|
| yolo11l_combined | combined | 3169 | 34.8 | 31.5 | 18.8 | 89.2 | 28.7 | 15185 | ✅ |
| yolo11l_infra | infra | 940 | 26.7 | 22.2 | 19.2 | 94.2 | 37.5 | 1337 | ✅ |
| yolo11l_survivor | survivor | 218 | 28.2 | 23.6 | 19.1 | 79.6 | 35.4 | 352 | ✅ |
| yolo11m_combined | combined | 3169 | 29.6 | 26.5 | 13.2 | 89.1 | 33.8 | 13344 | ✅ |
| yolo11m_infra | infra | 940 | 21.0 | 16.5 | 14.2 | 36.0 | 47.7 | 1310 | ✅ |
| yolo11m_survivor | survivor | 218 | 21.3 | 17.5 | 13.6 | 37.5 | 46.9 | 336 | ✅ |
| yolo11n_combined | combined | 3169 | 26.3 | 23.2 | 10.9 | 81.8 | 38.0 | 13216 | ✅ |
| yolo11n_infra | infra | 940 | 18.6 | 14.2 | 11.5 | 72.5 | 53.8 | 1265 | ✅ |
| yolo11n_survivor | survivor | 218 | 18.6 | 14.4 | 11.3 | 63.2 | 53.6 | 300 | ✅ |
| yolo11s_combined | combined | 3169 | 27.1 | 23.8 | 11.1 | 85.0 | 36.9 | 15094 | ✅ |
| yolo11s_infra | infra | 940 | 18.6 | 14.4 | 11.9 | 50.7 | 53.9 | 1299 | ✅ |
| yolo11s_survivor | survivor | 218 | 19.2 | 15.0 | 11.7 | 54.1 | 51.9 | 323 | ✅ |
| yolo11x_combined | combined | 3169 | 34.3 | 32.2 | 18.8 | 78.3 | 29.2 | 15449 | ✅ |
| yolo11x_infra | infra | 940 | 28.6 | 22.8 | 19.6 | 94.7 | 34.9 | 1291 | ✅ |
| yolo11x_survivor | survivor | 218 | 27.5 | 23.5 | 19.6 | 60.3 | 36.3 | 329 | ✅ |
| yolov10b_combined | combined | 3169 | 25.9 | 23.5 | 12.7 | 73.5 | 38.7 | 14848 | ✅ |
| yolov10b_infra | infra | 940 | 19.2 | 15.8 | 13.4 | 53.6 | 52.0 | 1312 | ✅ |
| yolov10b_survivor | survivor | 218 | 19.7 | 17.1 | 13.9 | 36.8 | 50.9 | 344 | ✅ |
| yolov10l_combined | combined | 3169 | 28.5 | 26.4 | 15.1 | 68.8 | 35.1 | 14649 | ✅ |
| yolov10l_infra | infra | 940 | 22.1 | 18.3 | 15.7 | 38.4 | 45.2 | 1160 | ✅ |
| yolov10l_survivor | survivor | 218 | 21.4 | 19.0 | 15.5 | 40.3 | 46.8 | 339 | ✅ |
| yolov10m_combined | combined | 3169 | 25.7 | 23.2 | 12.4 | 66.7 | 38.9 | 15058 | ✅ |
| yolov10m_infra | infra | 940 | 19.0 | 15.8 | 13.4 | 68.6 | 52.7 | 1361 | ✅ |
| yolov10m_survivor | survivor | 218 | 19.5 | 17.0 | 13.0 | 41.1 | 51.2 | 326 | ✅ |
| yolov10n_combined | combined | 3169 | 23.4 | 21.3 | 10.1 | 63.0 | 42.8 | 14573 | ✅ |
| yolov10n_infra | infra | 940 | 15.9 | 12.9 | 10.7 | 44.2 | 63.1 | 1210 | ✅ |
| yolov10n_survivor | survivor | 218 | 16.8 | 13.7 | 10.4 | 30.8 | 59.7 | 330 | ✅ |
| yolov10s_combined | combined | 3169 | 23.7 | 21.6 | 10.3 | 62.9 | 42.2 | 14925 | ✅ |
| yolov10s_infra | infra | 940 | 15.7 | 13.3 | 10.7 | 41.5 | 63.8 | 1186 | ✅ |
| yolov10s_survivor | survivor | 218 | 17.3 | 14.5 | 10.8 | 34.2 | 57.8 | 322 | ✅ |
| yolov10x_combined | combined | 3169 | 29.7 | 27.3 | 15.6 | 69.2 | 33.7 | 15186 | ✅ |
| yolov10x_infra | infra | 940 | 23.0 | 19.0 | 16.3 | 68.0 | 43.4 | 1321 | ✅ |
| yolov10x_survivor | survivor | 218 | 22.7 | 19.8 | 16.1 | 52.7 | 44.1 | 339 | ✅ |
| yolov3-tinyu_combined | combined | 3169 | 19.5 | 17.4 | 5.4 | 62.6 | 51.4 | 14312 | ✅ |
| yolov3-tinyu_infra | infra | 940 | 11.5 | 8.2 | 5.6 | 35.5 | 87.3 | 1458 | ✅ |
| yolov3-tinyu_survivor | survivor | 218 | 11.8 | 8.2 | 6.1 | 32.0 | 84.7 | 352 | ✅ |
| yolov3u_combined | combined | 3169 | 28.4 | 24.2 | 11.3 | 83.0 | 35.2 | 15009 | ✅ |
| yolov3u_infra | infra | 940 | 25.0 | 18.1 | 13.6 | 66.7 | 40.0 | 1343 | ✅ |
| yolov3u_survivor | survivor | 218 | 22.6 | 16.2 | 11.7 | 46.1 | 44.2 | 358 | ✅ |
| yolov5lu_combined | combined | 3169 | 28.5 | 26.4 | 13.2 | 69.6 | 35.1 | 14965 | ✅ |
| yolov5lu_infra | infra | 940 | 22.1 | 16.9 | 14.1 | 66.7 | 45.2 | 1329 | ✅ |
| yolov5lu_survivor | survivor | 218 | 21.2 | 16.8 | 13.7 | 41.7 | 47.2 | 326 | ✅ |
| yolov5mu_combined | combined | 3169 | 27.7 | 24.3 | 11.6 | 85.9 | 36.1 | 14995 | ✅ |
| yolov5mu_infra | infra | 940 | 19.4 | 14.7 | 12.2 | 59.6 | 51.7 | 1346 | ✅ |
| yolov5mu_survivor | survivor | 218 | 19.9 | 15.7 | 12.4 | 45.5 | 50.3 | 345 | ✅ |
| yolov5nu_combined | combined | 3169 | 25.3 | 22.0 | 9.2 | 79.9 | 39.5 | 14626 | ✅ |
| yolov5nu_infra | infra | 940 | 16.6 | 12.8 | 10.2 | 36.5 | 60.2 | 1262 | ✅ |
| yolov5nu_survivor | survivor | 218 | 16.5 | 12.6 | 10.0 | 36.0 | 60.7 | 322 | ✅ |
| yolov5su_combined | combined | 3169 | 25.4 | 21.9 | 9.3 | 84.4 | 39.4 | 14923 | ✅ |
| yolov5su_infra | infra | 940 | 16.9 | 13.0 | 10.3 | 35.6 | 59.1 | 1306 | ✅ |
| yolov5su_survivor | survivor | 218 | 17.6 | 13.7 | 10.1 | 34.8 | 56.9 | 332 | ✅ |
| yolov5xu_combined | combined | 3169 | 32.5 | 28.7 | 15.3 | 92.3 | 30.8 | 15168 | ✅ |
| yolov5xu_infra | infra | 940 | 26.0 | 19.2 | 16.2 | 63.6 | 38.4 | 1290 | ✅ |
| yolov5xu_survivor | survivor | 218 | 25.4 | 19.9 | 15.6 | 56.7 | 39.3 | 350 | ✅ |
| yolov8l_combined | combined | 3169 | 25.9 | 23.8 | 12.3 | 83.4 | 38.6 | 14988 | ✅ |
| yolov8l_infra | infra | 940 | 13.9 | 13.7 | 12.7 | 40.2 | 71.8 | 1364 | ✅ |
| yolov8l_survivor | survivor | 218 | 13.9 | 13.3 | 12.5 | 23.5 | 71.8 | 346 | ✅ |
| yolov8m_combined | combined | 3169 | 23.9 | 22.1 | 10.5 | 77.6 | 41.9 | 15030 | ✅ |
| yolov8m_infra | infra | 940 | 16.9 | 13.9 | 11.3 | 37.2 | 59.2 | 1341 | ✅ |
| yolov8m_survivor | survivor | 218 | 16.8 | 13.8 | 11.3 | 39.2 | 59.6 | 326 | ✅ |
| yolov8n_combined | combined | 3169 | 21.8 | 20.0 | 8.9 | 75.2 | 45.9 | 14793 | ✅ |
| yolov8n_infra | infra | 940 | 13.8 | 11.4 | 9.2 | 31.3 | 72.6 | 1284 | ✅ |
| yolov8n_survivor | survivor | 218 | 13.1 | 11.3 | 9.4 | 33.6 | 76.5 | 311 | ✅ |
| yolov8s_combined | combined | 3169 | 22.1 | 20.3 | 9.0 | 80.6 | 45.4 | 14860 | ✅ |
| yolov8s_infra | infra | 940 | 14.2 | 11.7 | 9.5 | 31.9 | 70.5 | 1288 | ✅ |
| yolov8s_survivor | survivor | 218 | 14.4 | 11.9 | 9.6 | 33.0 | 69.6 | 346 | ✅ |
| yolov8x_combined | combined | 3169 | 27.1 | 24.3 | 12.4 | 91.0 | 36.9 | 14884 | ✅ |
| yolov8x_infra | infra | 940 | 22.1 | 17.9 | 14.5 | 42.2 | 45.2 | 1356 | ✅ |
| yolov8x_survivor | survivor | 218 | 19.9 | 16.0 | 12.9 | 49.0 | 50.4 | 361 | ✅ |
| yolov9c_combined | combined | 3169 | 29.2 | 27.7 | 15.8 | 75.1 | 34.2 | 15156 | ✅ |
| yolov9c_infra | infra | 940 | 22.1 | 19.0 | 16.1 | 43.3 | 45.2 | 1372 | ✅ |
| yolov9c_survivor | survivor | 218 | 22.5 | 19.2 | 16.3 | 41.1 | 44.4 | 355 | ✅ |
| yolov9e_combined | combined | 3169 | 40.2 | 38.7 | 26.5 | 85.5 | 24.9 | 15114 | ✅ |
| yolov9e_infra | infra | 940 | 34.6 | 29.8 | 26.9 | 60.0 | 28.9 | 1320 | ✅ |
| yolov9e_survivor | survivor | 218 | 34.3 | 30.4 | 27.3 | 53.7 | 29.2 | 363 | ✅ |
| yolov9m_combined | combined | 3169 | 28.7 | 27.1 | 15.6 | 72.4 | 34.9 | 15275 | ✅ |
| yolov9m_infra | infra | 940 | 20.2 | 18.2 | 16.1 | 76.5 | 49.5 | 1317 | ✅ |
| yolov9m_survivor | survivor | 218 | 22.0 | 18.7 | 16.2 | 53.9 | 45.4 | 347 | ✅ |
| yolov9s_combined | combined | 3169 | 32.2 | 30.5 | 18.8 | 74.0 | 31.0 | 15150 | ✅ |
| yolov9s_infra | infra | 940 | 25.2 | 22.2 | 19.7 | 53.0 | 39.6 | 1317 | ✅ |
| yolov9s_survivor | survivor | 218 | 25.6 | 22.4 | 19.5 | 45.9 | 39.1 | 340 | ✅ |
| yolov9t_combined | combined | 3169 | 31.3 | 29.9 | 18.3 | 75.1 | 31.9 | 14940 | ✅ |
| yolov9t_infra | infra | 940 | 24.4 | 21.5 | 19.0 | 63.7 | 40.9 | 1284 | ✅ |
| yolov9t_survivor | survivor | 218 | 24.8 | 21.6 | 18.5 | 59.8 | 40.3 | 332 | ✅ |

---

## Summary — FPS Comparison Across Image Sizes

| Model | Dataset | FPS@224 | FPS@480 | FPS@640 |
|-------|---------|------|------|------|
| yolo11l_combined | combined | 30.3 | 29.2 | 28.7 |
| yolo11l_infra | infra | 38.9 | 36.7 | 37.5 |
| yolo11l_survivor | survivor | 40.3 | 36.4 | 35.4 |
| yolo11m_combined | combined | 36.4 | 35.1 | 33.8 |
| yolo11m_infra | infra | 50.9 | 47.7 | 47.7 |
| yolo11m_survivor | survivor | 50.3 | 48.3 | 46.9 |
| yolo11n_combined | combined | 41.6 | 39.4 | 38.0 |
| yolo11n_infra | infra | 60.9 | 57.1 | 53.8 |
| yolo11n_survivor | survivor | 57.7 | 53.6 | 53.6 |
| yolo11s_combined | combined | 40.1 | 38.3 | 36.9 |
| yolo11s_infra | infra | 57.3 | 52.9 | 53.9 |
| yolo11s_survivor | survivor | 58.3 | 52.9 | 51.9 |
| yolo11x_combined | combined | 30.9 | 30.1 | 29.2 |
| yolo11x_infra | infra | 38.1 | 38.4 | 34.9 |
| yolo11x_survivor | survivor | 39.3 | 36.0 | 36.3 |
| yolov10b_combined | combined | 40.6 | 40.1 | 38.7 |
| yolov10b_infra | infra | 54.6 | 53.2 | 52.0 |
| yolov10b_survivor | survivor | 54.1 | 51.2 | 50.9 |
| yolov10l_combined | combined | 37.2 | 36.2 | 35.1 |
| yolov10l_infra | infra | 49.7 | 46.4 | 45.2 |
| yolov10l_survivor | survivor | 49.3 | 45.3 | 46.8 |
| yolov10m_combined | combined | 41.4 | 40.4 | 38.9 |
| yolov10m_infra | infra | 57.4 | 53.5 | 52.7 |
| yolov10m_survivor | survivor | 55.0 | 53.0 | 51.2 |
| yolov10n_combined | combined | 45.9 | 44.6 | 42.8 |
| yolov10n_infra | infra | 67.3 | 62.3 | 63.1 |
| yolov10n_survivor | survivor | 62.2 | 59.5 | 59.7 |
| yolov10s_combined | combined | 45.1 | 44.3 | 42.2 |
| yolov10s_infra | infra | 65.9 | 60.4 | 63.8 |
| yolov10s_survivor | survivor | 60.2 | 58.2 | 57.8 |
| yolov10x_combined | combined | 35.9 | 33.6 | 33.7 |
| yolov10x_infra | infra | 47.5 | 45.4 | 43.4 |
| yolov10x_survivor | survivor | 47.4 | 44.8 | 44.1 |
| yolov3-tinyu_combined | combined | 58.4 | 53.5 | 51.4 |
| yolov3-tinyu_infra | infra | 91.2 | 83.4 | 87.3 |
| yolov3-tinyu_survivor | survivor | 96.6 | 86.3 | 84.7 |
| yolov3u_combined | combined | 41.8 | 38.2 | 35.2 |
| yolov3u_infra | infra | 55.1 | 47.6 | 40.0 |
| yolov3u_survivor | survivor | 59.3 | 50.0 | 44.2 |
| yolov5lu_combined | combined | 38.2 | 36.5 | 35.1 |
| yolov5lu_infra | infra | 50.1 | 46.8 | 45.2 |
| yolov5lu_survivor | survivor | 52.0 | 48.0 | 47.2 |
| yolov5mu_combined | combined | 39.5 | 37.4 | 36.1 |
| yolov5mu_infra | infra | 55.0 | 51.2 | 51.7 |
| yolov5mu_survivor | survivor | 56.4 | 51.2 | 50.3 |
| yolov5nu_combined | combined | 43.9 | 41.1 | 39.5 |
| yolov5nu_infra | infra | 64.6 | 60.2 | 60.2 |
| yolov5nu_survivor | survivor | 69.0 | 60.6 | 60.7 |
| yolov5su_combined | combined | 42.6 | 41.1 | 39.4 |
| yolov5su_infra | infra | 64.9 | 59.6 | 59.1 |
| yolov5su_survivor | survivor | 60.4 | 57.8 | 56.9 |
| yolov5xu_combined | combined | 34.6 | 32.4 | 30.8 |
| yolov5xu_infra | infra | 45.5 | 40.8 | 38.4 |
| yolov5xu_survivor | survivor | 46.1 | 42.3 | 39.3 |
| yolov8l_combined | combined | 38.8 | 37.1 | 38.6 |
| yolov8l_infra | infra | 75.5 | 70.4 | 71.8 |
| yolov8l_survivor | survivor | 76.1 | 72.3 | 71.8 |
| yolov8m_combined | combined | 53.8 | 49.1 | 41.9 |
| yolov8m_infra | infra | 65.5 | 61.0 | 59.2 |
| yolov8m_survivor | survivor | 65.0 | 60.5 | 59.6 |
| yolov8n_combined | combined | 51.3 | 48.1 | 45.9 |
| yolov8n_infra | infra | 77.0 | 70.9 | 72.6 |
| yolov8n_survivor | survivor | 80.8 | 70.3 | 76.5 |
| yolov8s_combined | combined | 50.6 | 47.6 | 45.4 |
| yolov8s_infra | infra | 89.3 | 78.9 | 70.5 |
| yolov8s_survivor | survivor | 77.0 | 71.4 | 69.6 |
| yolov8x_combined | combined | 41.5 | 38.9 | 36.9 |
| yolov8x_infra | infra | 56.1 | 50.9 | 45.2 |
| yolov8x_survivor | survivor | 57.8 | 52.0 | 50.4 |
| yolov9c_combined | combined | 37.7 | 35.3 | 34.2 |
| yolov9c_infra | infra | 51.7 | 47.6 | 45.2 |
| yolov9c_survivor | survivor | 49.2 | 45.0 | 44.4 |
| yolov9e_combined | combined | 25.8 | 25.2 | 24.9 |
| yolov9e_infra | infra | 31.9 | 29.5 | 28.9 |
| yolov9e_survivor | survivor | 31.7 | 29.7 | 29.2 |
| yolov9m_combined | combined | 36.8 | 36.2 | 34.9 |
| yolov9m_infra | infra | 48.6 | 48.6 | 49.5 |
| yolov9m_survivor | survivor | 48.4 | 45.5 | 45.4 |
| yolov9s_combined | combined | 33.7 | 32.6 | 31.0 |
| yolov9s_infra | infra | 41.2 | 39.5 | 39.6 |
| yolov9s_survivor | survivor | 41.0 | 39.3 | 39.1 |
| yolov9t_combined | combined | 34.8 | 32.6 | 31.9 |
| yolov9t_infra | infra | 42.6 | 40.5 | 40.9 |
| yolov9t_survivor | survivor | 42.8 | 40.3 | 40.3 |
