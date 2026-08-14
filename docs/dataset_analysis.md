# Dataset Analysis Report

> Generated: 2026-08-06 08:33:36

For authoritative raw download URLs, derived-dataset provenance, and the
portable repo-local placement, see [`dataset_sources.md`](dataset_sources.md).

## INFRA Dataset

- **Path**: `/workspace/datasets/turbid_water/_derived/ultralytics/infra`
- **Classes**: 2 — crack, corrosion

### train

- **Images**: 17322
- **Total bounding boxes**: 27239
- **Avg boxes/image**: 1.57

| Class ID | Class Name | Count | % |
|----------|-----------|-------|---|
| 0 | crack | 27095 | 99.5% |
| 1 | corrosion | 144 | 0.5% |

**Bounding Box Stats (normalized):**
- Width:  min=0.0047, max=1.0000, avg=0.4530
- Height: min=0.0047, max=1.0000, avg=0.4599

**Image Resolution (sampled 50 images):**
- Width:  min=640, max=640, avg=640
- Height: min=640, max=640, avg=640

### val

- **Images**: 940
- **Total bounding boxes**: 1406
- **Avg boxes/image**: 1.50

| Class ID | Class Name | Count | % |
|----------|-----------|-------|---|
| 0 | crack | 1357 | 96.5% |
| 1 | corrosion | 49 | 3.5% |

**Bounding Box Stats (normalized):**
- Width:  min=0.0094, max=1.0000, avg=0.4693
- Height: min=0.0078, max=1.0000, avg=0.4726

**Image Resolution (sampled 50 images):**
- Width:  min=474, max=800, avg=640
- Height: min=316, max=640, avg=633

---

## SURVIVOR Dataset

- **Path**: `/workspace/datasets/turbid_water/_derived/ultralytics/survivor`
- **Classes**: 1 — person

### train

- **Images**: 871
- **Total bounding boxes**: 1275
- **Avg boxes/image**: 1.46

| Class ID | Class Name | Count | % |
|----------|-----------|-------|---|
| 0 | person | 1275 | 100.0% |

**Bounding Box Stats (normalized):**
- Width:  min=0.0236, max=0.9047, avg=0.2698
- Height: min=0.0458, max=1.0000, avg=0.3470

**Image Resolution (sampled 50 images):**
- Width:  min=480, max=1280, avg=730
- Height: min=448, max=720, avg=508

### val

- **Images**: 218
- **Total bounding boxes**: 333
- **Avg boxes/image**: 1.53

| Class ID | Class Name | Count | % |
|----------|-----------|-------|---|
| 0 | person | 333 | 100.0% |

**Bounding Box Stats (normalized):**
- Width:  min=0.0236, max=0.9047, avg=0.2540
- Height: min=0.0667, max=1.0000, avg=0.3281

**Image Resolution (sampled 50 images):**
- Width:  min=640, max=1280, avg=746
- Height: min=480, max=720, avg=514

---

## COMBINED Dataset

- **Path**: `/workspace/datasets/turbid_water/_derived/yolo_underwater_detector`
- **Classes**: 19 — holothurian, echinus, scallop, starfish, fish, small_fish, crab, shrimp, jellyfish, bio, cloth, fishing, metal, paper, plastic, rov, rubber, unknown, wood

### train

- **Images**: 22358
- **Total bounding boxes**: 98075
- **Avg boxes/image**: 4.39

| Class ID | Class Name | Count | % |
|----------|-----------|-------|---|
| 0 | holothurian | 6808 | 6.9% |
| 1 | echinus | 42954 | 43.8% |
| 2 | scallop | 1707 | 1.7% |
| 3 | starfish | 18075 | 18.4% |
| 4 | fish | 2673 | 2.7% |
| 5 | small_fish | 7780 | 7.9% |
| 6 | crab | 8523 | 8.7% |
| 7 | shrimp | 415 | 0.4% |
| 8 | jellyfish | 520 | 0.5% |
| 9 | bio | 1951 | 2.0% |
| 10 | cloth | 5 | 0.0% |
| 11 | fishing | 12 | 0.0% |
| 12 | metal | 48 | 0.0% |
| 13 | paper | 11 | 0.0% |
| 14 | plastic | 4580 | 4.7% |
| 15 | rov | 1797 | 1.8% |
| 16 | rubber | 15 | 0.0% |
| 17 | unknown | 147 | 0.1% |
| 18 | wood | 54 | 0.1% |

**Bounding Box Stats (normalized):**
- Width:  min=0.0005, max=0.9979, avg=0.0915
- Height: min=0.0130, max=0.9972, avg=0.1222

**Image Resolution (sampled 50 images):**
- Width:  min=480, max=3840, avg=1128
- Height: min=270, max=2160, avg=654

### val

- **Images**: 3169
- **Total bounding boxes**: 14775
- **Avg boxes/image**: 4.66

| Class ID | Class Name | Count | % |
|----------|-----------|-------|---|
| 0 | holothurian | 1079 | 7.3% |
| 1 | echinus | 7201 | 48.7% |
| 2 | scallop | 217 | 1.5% |
| 3 | starfish | 2700 | 18.3% |
| 4 | fish | 311 | 2.1% |
| 5 | small_fish | 1030 | 7.0% |
| 6 | crab | 1018 | 6.9% |
| 7 | shrimp | 76 | 0.5% |
| 8 | jellyfish | 55 | 0.4% |
| 9 | bio | 70 | 0.5% |
| 10 | cloth | 0 | 0.0% |
| 11 | fishing | 0 | 0.0% |
| 12 | metal | 24 | 0.2% |
| 13 | paper | 0 | 0.0% |
| 14 | plastic | 853 | 5.8% |
| 15 | rov | 141 | 1.0% |
| 16 | rubber | 0 | 0.0% |
| 17 | unknown | 0 | 0.0% |
| 18 | wood | 0 | 0.0% |

**Bounding Box Stats (normalized):**
- Width:  min=0.0086, max=0.9979, avg=0.0856
- Height: min=0.0130, max=0.9972, avg=0.1180

**Image Resolution (sampled 50 images):**
- Width:  min=480, max=3840, avg=1034
- Height: min=270, max=2160, avg=604

### test

- **Images**: 3494
- **Total bounding boxes**: 15265
- **Avg boxes/image**: 4.37

| Class ID | Class Name | Count | % |
|----------|-----------|-------|---|
| 0 | holothurian | 1079 | 7.1% |
| 1 | echinus | 7201 | 47.2% |
| 2 | scallop | 217 | 1.4% |
| 3 | starfish | 2708 | 17.7% |
| 4 | fish | 317 | 2.1% |
| 5 | small_fish | 812 | 5.3% |
| 6 | crab | 1092 | 7.2% |
| 7 | shrimp | 57 | 0.4% |
| 8 | jellyfish | 62 | 0.4% |
| 9 | bio | 396 | 2.6% |
| 10 | cloth | 1 | 0.0% |
| 11 | fishing | 1 | 0.0% |
| 12 | metal | 11 | 0.1% |
| 13 | paper | 3 | 0.0% |
| 14 | plastic | 937 | 6.1% |
| 15 | rov | 335 | 2.2% |
| 16 | rubber | 1 | 0.0% |
| 17 | unknown | 25 | 0.2% |
| 18 | wood | 10 | 0.1% |

**Bounding Box Stats (normalized):**
- Width:  min=0.0086, max=0.9979, avg=0.0970
- Height: min=0.0139, max=0.9972, avg=0.1280

**Image Resolution (sampled 50 images):**
- Width:  min=480, max=3840, avg=1258
- Height: min=270, max=2160, avg=720

---
