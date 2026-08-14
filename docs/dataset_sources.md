# Dataset Sources and Placement

The benchmark uses three **derived** YOLO datasets. Dataset files are excluded
from Git, so a fresh clone must receive the prepared validation images before
inference can run.

## Corrected paper-v2 layout

The manuscript uses source-grouped derivatives with these verified counts:

| Dataset | Train | Validation | Test |
|---|---:|---:|---:|
| INFRA | 16,436 | 1,826 | -- |
| SURVIVOR | 870 | 219 | -- |
| COMBINED | 22,039 | 2,755 | 3,116 |

Place prepared derivatives at a stable dataset root and update the `path`
entry in [`configs/datasets/infra_v2.yaml`](../configs/datasets/infra_v2.yaml),
[`configs/datasets/survivor_v2.yaml`](../configs/datasets/survivor_v2.yaml), and
[`configs/datasets/combined_v2.yaml`](../configs/datasets/combined_v2.yaml).
Each prepared directory follows:

```text
prepared_dataset/
├── images/{train,val,test}/
└── labels/{train,val,test}/
```

The `test` directory is required only when declared in the corresponding YAML.
Use `paper_v2/scripts/audit_datasets.py` after placement and do not compare
accuracy unless source groups, exact duplicates, labels, and class support have
been checked. Downloading the raw sources listed below does not reproduce these
derived partitions automatically.

## Legacy layout for the portable inference runner

Place the exact prepared validation splits under the cloned repository:

```text
turbid_review/
└── datasets/
    ├── infra/images/val/       # 940 images
    ├── survivor/images/val/    # 218 images
    └── combined/images/val/    # 3,169 images
```

Labels are not required for latency/FPS inference. They are required for model
evaluation or retraining and should be placed in the matching
`datasets/<name>/labels/{train,val,test}` directories.

After placing the data, run:

```bash
bash scripts/run_rtx3060_inference.sh --max-images 10
```

The runner checks all three directories and their exact validation-image counts
before loading a model. External paths remain supported through
`--infra-images`, `--survivor-images`, and `--combined-images`.

## Important reproducibility note

INFRA, SURVIVOR, and COMBINED are not direct renames of a single downloadable
dataset. They were merged, filtered, converted to YOLO detection labels, class
remapped, split, and (for SURVIVOR) augmented. Downloading the upstream sources
below does **not** by itself reproduce the exact benchmark split.

For results directly comparable with this repository, obtain the prepared
three-folder benchmark data from the project owner and verify the counts above.
The public links below document provenance and provide the raw source material.

## INFRA sources

INFRA derives the normalized classes `crack` and `corrosion` from these
Roboflow Universe exports:

| Raw source | Exact version/download page |
|---|---|
| Corrosion Detection in Subsea Pipelines, v1 | <https://universe.roboflow.com/corrosion-detection-zvmog/corrosion-detection-in-subsea-pipelines/dataset/1> |
| UnderWater Bot, v1 | <https://universe.roboflow.com/sudharsan-oxysw/underwater-bot/dataset/1> |
| Underwater Crack Detection, v1 | <https://universe.roboflow.com/hemavarshinir/underwater-crack-detection-no54i/dataset/1> |

Select the YOLOv8 export format when downloading from Roboflow. The benchmark
then merges/remaps the source categories into `crack` and `corrosion`; do not
point the runner at any one raw export and treat it as the prepared INFRA split.

## SURVIVOR source

SURVIVOR has one class, `person`. It was derived from the human-diver (`HD`)
category in SUIM: semantic masks were converted to YOLO detection boxes,
filtered, and augmented. Paper v2 assigns all variants of an original SUIM
source image to the same split.

- Official University of Minnesota dataset page:
  <https://irvlab.cs.umn.edu/resources/suim-dataset>
- Official SUIM Google Drive download:
  <https://drive.google.com/file/d/1uEnlqKrlt6lITc_i80NTtb7iHGcO47sU/view?usp=sharing>
- Authors' source repository:
  <https://github.com/xahidbuffon/SUIM>

## COMBINED sources

COMBINED uses 19 normalized classes from Brackish, DUO, and Trash-ICRA19. The
table below records the earlier derived layout used by the portable systems
runner; paper v2 uses the corrected source-grouped counts given above.

| Source | Train | Validation | Test | Official source/download |
|---|---:|---:|---:|---|
| Brackish | 9,967 | 1,238 | 1,239 | <https://www.kaggle.com/datasets/aalborguniversity/brackish-dataset> |
| DUO | 6,671 | 1,111 | 1,111 | <https://drive.google.com/file/d/1w-bWevH7jFs7A1bIBlAOvXOxe2OFSHHs/view?usp=sharing> |
| Trash-ICRA19 | 5,720 | 820 | 1,144 | <https://conservancy.umn.edu/handle/11299/214366> |

Provenance pages:

- Brackish, Aalborg University research portal:
  <https://vbn.aau.dk/en/datasets/the-brackish-dataset/>
- DUO authors' repository (also lists a Baidu mirror, key `4bfl`):
  <https://github.com/chongweiliu/DUO>
- Trash-ICRA19, University of Minnesota IRVLab:
  <https://irvlab.cs.umn.edu/resources/trash-icra19>

The benchmark exporter includes empty images, converts/remaps annotations to a
common 19-class taxonomy, removes duplicate labels, and preserves the source
split composition shown above. Raw source directories therefore cannot replace
`datasets/combined/images/val` without that preparation.

## Storage advice

The dataset directories may be symlinks to another disk. This is useful on a
small system and is supported by the RTX runner:

```bash
mkdir -p datasets
ln -s /large_disk/turbid_datasets/infra datasets/infra
ln -s /large_disk/turbid_datasets/survivor datasets/survivor
ln -s /large_disk/turbid_datasets/combined datasets/combined
```

Do not copy the full training/test data to the Jetson Nano for the representative
edge benchmark. [`scripts/run_edge.sh`](../scripts/run_edge.sh) stages only the
small image sample and one model/engine at a time under `/data`.
