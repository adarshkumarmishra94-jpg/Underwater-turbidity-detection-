# RTX 3060 Inference Handoff

## Exact script

Run [`scripts/run_rtx3060_inference.sh`](../scripts/run_rtx3060_inference.sh).
It benchmarks all 84 fine-tuned models at 224, 480, and 640 pixels, producing
252 model-resolution measurements without overwriting the A100 report.

## Required local data

A Git clone does not include the ignored model binaries or datasets. Before
running, the RTX 3060 machine needs:

- All 84 flat `.pt` files from `final_checkpoints/finetuned/` (about 4.8 GB).
- The INFRA validation images.
- The SURVIVOR validation images.
- The COMBINED validation images.
- A Python environment where PyTorch detects the RTX 3060 and the repository
  requirements are installed.

The exact public source/download URLs, derivation warning, expected counts, and
placement tree are in [`dataset_sources.md`](dataset_sources.md). With the
prepared splits placed at the default repo-local paths, the runner needs no
dataset arguments:

```text
datasets/infra/images/val       (940 images)
datasets/survivor/images/val    (218 images)
datasets/combined/images/val  (3,169 images)
```

Activate that environment before running the script. If its interpreter is not
named `python3`, set it explicitly, for example
`PYTHON_BIN=/path/to/venv/bin/python`.

Only the fine-tuned PyTorch weights are needed. The 8.8 GB ONNX export folder
is not needed for the RTX 3060 benchmark.

## Commands

First run a small smoke test:

```bash
bash scripts/run_rtx3060_inference.sh --max-images 10
```

After the smoke test succeeds, run the full benchmark by removing
`--max-images 10`:

```bash
bash scripts/run_rtx3060_inference.sh
```

For an unattended run:

```bash
nohup bash scripts/run_rtx3060_inference.sh > rtx3060_launcher.log 2>&1 &
```

If checkpoints or datasets are stored outside the clone, pass the explicit
`--checkpoints-dir`, `--infra-images`, `--survivor-images`, and
`--combined-images` paths shown by `--help`.

## Outputs

- Markdown: `results/task_003_inference_rtx3060.md`
- Raw JSON: `results/task_003_inference_rtx3060.json`
- Timestamped log: `logs/inference_rtx3060_YYYYMMDD_HHMMSS.log`

The script aborts before benchmarking if it does not find exactly 84
fine-tuned checkpoints, CUDA is unavailable, or the detected GPU name does not
contain `3060`. It also requires the exact validation counts: 940 INFRA, 218
SURVIVOR, and 3,169 COMBINED images.
