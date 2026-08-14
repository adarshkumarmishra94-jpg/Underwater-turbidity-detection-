# CLAUDE.md — Project Rules & Conventions

## Project: Turbid Review — YOLO Benchmark on Underwater Detection

### Environment
- **Container OS**: Linux
- **GPU**: NVIDIA A100-SXM4-40GB (40 GB VRAM)
- **RAM**: 1024 GB
- **CPU**: 256 cores
- **Conda env**: `vision` (activate with `conda activate vision`)
- **Python**: Use only packages installed in `vision` env; install missing ones via `conda run -n vision pip install <pkg>`
- **Edge device**: Jetson Nano accessible via `ssh jetson-nano` (IP: 10.0.16.72, user: nvidia)

### Datasets
- All datasets are at `/workspace/datasets/turbid_water/`
- Pre-processed YOLO-format datasets at `/workspace/datasets/turbid_water/_derived/ultralytics/`
  - `infra/` → crack (0), corrosion (1) — 17,322 train / 940 val
  - `survivor/` → person (0) — 871 train / 218 val
  - Combined at `_derived/yolo_underwater_detector/` → 19 classes — 22,358 train / 3,169 val / 3,494 test

### Secrets & API Keys
- Located at `/workspace/.secrets/api_keys.env`
- Source before running: `source /workspace/.secrets/api_keys.env`
- **WANDB_API_KEY**, **GITHUB_TOKEN**, **HF_TOKEN** are available

### Critical Rules
1. **Do NOT hallucinate** — be honest with numbers and findings
2. **Do NOT install packages on Jetson Nano** — all packages are pre-installed
3. **Do NOT use pip directly** — always use `conda run -n vision pip install <pkg>` for the container
4. **Track everything** with WandB (project: `turbid_review`, entity from env)
5. **All scripts run via bash** — create end-to-end bash scripts for test, train, inference, edge, profiling
6. **Use nohup** for longer training; log files should include timestamps (e.g., `train_yolov8n_20260806_080000.log`)
7. **Document everything** in `/docs/` and update `project_progress.md` as project moves
8. **Keep README.md updated** with latest status
9. **Push results** to `/results/task_XXX.md` files
10. **Create GitHub repo** as private using `gh repo create`

### Naming Conventions
- Log files: `{task}_{model}_{YYYYMMDD_HHMMSS}.log`
- Checkpoints: `{model}_{dataset}_{epoch}.pt`
- Results: `task_001_pretrained_eval.md`, `task_002_finetuned_eval.md`, `task_003_edge_inference.md`

### Git Workflow
- Commit after each major step
- Use descriptive commit messages
- Push regularly to the private `turbid_review` repo

### Jetson Nano Deployment
- SSH: `ssh jetson-nano`
- SCP model files to Jetson: `scp model.onnx jetson-nano:/home/nvidia/turbid_review/`
- Run inference scripts remotely: `ssh jetson-nano 'python3 /home/nvidia/turbid_review/inference_edge.py'`
- **Never install packages on Jetson** — use what's already installed
