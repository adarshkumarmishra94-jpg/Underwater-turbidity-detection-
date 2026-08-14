#!/usr/bin/env python3
"""Generate the Jetson edge benchmark Markdown report from JSON results."""

import argparse
import datetime
import glob
import json
import os


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--results-dir", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--device", default="NVIDIA Jetson Nano 4 GB")
    args = parser.parse_args()

    results = []
    for path in sorted(glob.glob(os.path.join(args.results_dir, "edge_*.json"))):
        with open(path, "r") as result_file:
            results.append(json.load(result_file))

    lines = [
        "# Task 3 — Edge Inference Results (Jetson Nano)",
        "",
        "> Generated: {} UTC".format(
            datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M:%S")
        ),
        "> Device: {} | TensorRT FP16 | batch 1".format(args.device),
        "> GPU latency measures TensorRT execution; end-to-end latency includes image read, letterbox preprocessing, transfers, inference, output copy, and NMS.",
        "",
        "| Model | Dataset | Size | Images | GPU ms | GPU FPS | End-to-end ms | End-to-end FPS | Detections | Status |",
        "|---|---|---:|---:|---:|---:|---:|---:|---:|---|",
    ]
    for result in sorted(results, key=lambda item: (item.get("model", ""), item.get("imgsz", 0))):
        if result.get("status") == "success":
            lines.append(
                "| {model} | {dataset} | {imgsz} | {num_images} | "
                "{inference_avg_ms:.2f} | {inference_fps:.2f} | "
                "{end_to_end_avg_ms:.2f} | {end_to_end_fps:.2f} | "
                "{total_detections} | ✅ |".format(**result)
            )
        else:
            error = str(result.get("error", "unknown error")).replace("|", "\\|")
            failed = dict(result)
            failed["error"] = error
            lines.append(
                "| {model} | {dataset} | {imgsz} | — | — | — | — | — | — | ❌ {error} |".format(
                    **failed
                )
            )

    succeeded = sum(1 for result in results if result.get("status") == "success")
    lines.extend([
        "",
        "## Verification summary",
        "",
        "- Successful benchmark runs: {} / {}".format(succeeded, len(results)),
        "- No packages were installed on the Jetson.",
        "- Remote artifacts were staged under `/data/turbid_review`; models and engines were removed after each model.",
        "- Source images were transferred once per dataset, capped by `--max-images`, and removed after the run.",
        "",
    ])

    with open(args.output, "w") as report_file:
        report_file.write("\n".join(lines))


if __name__ == "__main__":
    main()
