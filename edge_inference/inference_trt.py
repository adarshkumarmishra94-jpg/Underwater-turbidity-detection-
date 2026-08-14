#!/usr/bin/env python3
"""Package-free TensorRT inference benchmark for Jetson Nano.

Requires only the JetPack-provided TensorRT, CUDA runtime, OpenCV and NumPy.
The script is deliberately compatible with Python 3.6 / JetPack 4.6.
"""

from __future__ import print_function

import argparse
import ctypes
import glob
import json
import os
import statistics
import time

import cv2
import numpy as np
import tensorrt as trt


CUDA_MEMCPY_HOST_TO_DEVICE = 1
CUDA_MEMCPY_DEVICE_TO_HOST = 2
LOGGER = trt.Logger(trt.Logger.WARNING)


class CudaRuntime(object):
    def __init__(self):
        self.lib = ctypes.CDLL("libcudart.so")
        self.lib.cudaMalloc.argtypes = [ctypes.POINTER(ctypes.c_void_p), ctypes.c_size_t]
        self.lib.cudaFree.argtypes = [ctypes.c_void_p]
        self.lib.cudaMemcpy.argtypes = [
            ctypes.c_void_p, ctypes.c_void_p, ctypes.c_size_t, ctypes.c_int
        ]
        self.lib.cudaDeviceSynchronize.argtypes = []

    def check(self, code, operation):
        if code != 0:
            raise RuntimeError("{} failed with CUDA error {}".format(operation, code))

    def malloc(self, nbytes):
        pointer = ctypes.c_void_p()
        self.check(self.lib.cudaMalloc(ctypes.byref(pointer), nbytes), "cudaMalloc")
        return pointer

    def free(self, pointer):
        if pointer:
            self.check(self.lib.cudaFree(pointer), "cudaFree")

    def copy_to_device(self, pointer, array):
        self.check(
            self.lib.cudaMemcpy(
                pointer,
                ctypes.c_void_p(array.ctypes.data),
                array.nbytes,
                CUDA_MEMCPY_HOST_TO_DEVICE,
            ),
            "cudaMemcpy(H2D)",
        )

    def copy_to_host(self, array, pointer):
        self.check(
            self.lib.cudaMemcpy(
                ctypes.c_void_p(array.ctypes.data),
                pointer,
                array.nbytes,
                CUDA_MEMCPY_DEVICE_TO_HOST,
            ),
            "cudaMemcpy(D2H)",
        )

    def synchronize(self):
        self.check(self.lib.cudaDeviceSynchronize(), "cudaDeviceSynchronize")


def volume(shape):
    result = 1
    for value in shape:
        result *= int(value)
    return result


def list_images(image_dir):
    images = []
    for extension in ("jpg", "jpeg", "png", "bmp"):
        images.extend(glob.glob(os.path.join(image_dir, "*." + extension)))
        images.extend(glob.glob(os.path.join(image_dir, "*." + extension.upper())))
    return sorted(set(images))


def letterbox(image, size):
    height, width = image.shape[:2]
    scale = min(float(size) / width, float(size) / height)
    resized_width = max(1, int(round(width * scale)))
    resized_height = max(1, int(round(height * scale)))
    interpolation = cv2.INTER_LINEAR if scale > 1.0 else cv2.INTER_AREA
    resized = cv2.resize(image, (resized_width, resized_height), interpolation=interpolation)
    canvas = np.full((size, size, 3), 114, dtype=np.uint8)
    left = (size - resized_width) // 2
    top = (size - resized_height) // 2
    canvas[top:top + resized_height, left:left + resized_width] = resized
    rgb = cv2.cvtColor(canvas, cv2.COLOR_BGR2RGB)
    tensor = np.ascontiguousarray(rgb.transpose(2, 0, 1), dtype=np.float32)
    tensor *= (1.0 / 255.0)
    return tensor[np.newaxis, :]


def nms(boxes, scores, threshold):
    if len(boxes) == 0:
        return []
    x1, y1, x2, y2 = boxes.T
    areas = np.maximum(0.0, x2 - x1) * np.maximum(0.0, y2 - y1)
    order = scores.argsort()[::-1]
    keep = []
    while order.size:
        current = int(order[0])
        keep.append(current)
        if order.size == 1:
            break
        remaining = order[1:]
        xx1 = np.maximum(x1[current], x1[remaining])
        yy1 = np.maximum(y1[current], y1[remaining])
        xx2 = np.minimum(x2[current], x2[remaining])
        yy2 = np.minimum(y2[current], y2[remaining])
        intersection = np.maximum(0.0, xx2 - xx1) * np.maximum(0.0, yy2 - yy1)
        union = areas[current] + areas[remaining] - intersection
        overlap = intersection / np.maximum(union, 1e-7)
        order = remaining[overlap <= threshold]
    return keep


def detection_count(output, confidence, iou):
    values = np.asarray(output)
    if values.ndim == 3:
        values = values[0]

    # YOLOv10 end-to-end export: N rows of x1, y1, x2, y2, score, class.
    if values.ndim == 2 and values.shape[1] == 6:
        return int(np.count_nonzero(values[:, 4] >= confidence))

    # Standard Ultralytics export: (4 + classes, anchors).
    if values.ndim != 2 or values.shape[0] < 5:
        raise RuntimeError("Unsupported YOLO output shape: {}".format(values.shape))
    predictions = values.T
    class_scores = predictions[:, 4:]
    class_ids = np.argmax(class_scores, axis=1)
    scores = class_scores[np.arange(class_scores.shape[0]), class_ids]
    selected = scores >= confidence
    if not np.any(selected):
        return 0

    xywh = predictions[selected, :4]
    selected_scores = scores[selected]
    selected_classes = class_ids[selected]
    boxes = np.empty_like(xywh)
    boxes[:, 0] = xywh[:, 0] - xywh[:, 2] / 2.0
    boxes[:, 1] = xywh[:, 1] - xywh[:, 3] / 2.0
    boxes[:, 2] = xywh[:, 0] + xywh[:, 2] / 2.0
    boxes[:, 3] = xywh[:, 1] + xywh[:, 3] / 2.0

    count = 0
    for class_id in np.unique(selected_classes):
        class_mask = selected_classes == class_id
        count += len(nms(boxes[class_mask], selected_scores[class_mask], iou))
    return int(count)


class TensorRTSession(object):
    def __init__(self, engine_path, image_size):
        trt.init_libnvinfer_plugins(LOGGER, "")
        with open(engine_path, "rb") as engine_file:
            serialized = engine_file.read()
        self.runtime = trt.Runtime(LOGGER)
        self.engine = self.runtime.deserialize_cuda_engine(serialized)
        if self.engine is None:
            raise RuntimeError("Could not deserialize TensorRT engine")
        self.context = self.engine.create_execution_context()
        if self.context is None:
            raise RuntimeError("Could not create TensorRT execution context")

        self.input_indices = [
            index for index in range(self.engine.num_bindings)
            if self.engine.binding_is_input(index)
        ]
        self.output_indices = [
            index for index in range(self.engine.num_bindings)
            if not self.engine.binding_is_input(index)
        ]
        if len(self.input_indices) != 1 or len(self.output_indices) != 1:
            raise RuntimeError("Expected one input and one output binding")

        self.input_index = self.input_indices[0]
        self.output_index = self.output_indices[0]
        requested_shape = (1, 3, image_size, image_size)
        if not self.context.set_binding_shape(self.input_index, requested_shape):
            actual = tuple(self.engine.get_binding_shape(self.input_index))
            if actual != requested_shape:
                raise RuntimeError(
                    "Engine input {} does not accept {}".format(actual, requested_shape)
                )
        if not self.context.all_binding_shapes_specified:
            raise RuntimeError("TensorRT binding shapes are not fully specified")

        self.input_shape = tuple(self.context.get_binding_shape(self.input_index))
        self.output_shape = tuple(self.context.get_binding_shape(self.output_index))
        self.input_dtype = trt.nptype(self.engine.get_binding_dtype(self.input_index))
        self.output_dtype = trt.nptype(self.engine.get_binding_dtype(self.output_index))
        self.output = np.empty(self.output_shape, dtype=self.output_dtype)
        self.cuda = CudaRuntime()
        self.device_input = self.cuda.malloc(volume(self.input_shape) * self.input_dtype().nbytes)
        self.device_output = self.cuda.malloc(self.output.nbytes)
        self.bindings = [0] * self.engine.num_bindings
        self.bindings[self.input_index] = int(self.device_input.value)
        self.bindings[self.output_index] = int(self.device_output.value)

    def infer(self, tensor):
        if tensor.dtype != self.input_dtype:
            tensor = tensor.astype(self.input_dtype)
        tensor = np.ascontiguousarray(tensor)
        self.cuda.copy_to_device(self.device_input, tensor)
        started = time.perf_counter()
        if not self.context.execute_v2(self.bindings):
            raise RuntimeError("TensorRT execute_v2 returned false")
        self.cuda.synchronize()
        inference_ms = (time.perf_counter() - started) * 1000.0
        self.cuda.copy_to_host(self.output, self.device_output)
        return self.output, inference_ms

    def close(self):
        self.cuda.free(self.device_input)
        self.cuda.free(self.device_output)
        self.device_input = None
        self.device_output = None


def percentile(values, percent):
    return float(np.percentile(np.asarray(values, dtype=np.float64), percent))


def rounded_stats(values, prefix):
    return {
        prefix + "_avg_ms": round(statistics.mean(values), 3),
        prefix + "_median_ms": round(statistics.median(values), 3),
        prefix + "_p95_ms": round(percentile(values, 95), 3),
        prefix + "_min_ms": round(min(values), 3),
        prefix + "_max_ms": round(max(values), 3),
    }


def benchmark(args):
    images = list_images(args.images)[:args.max_images]
    if not images:
        raise RuntimeError("No images found in {}".format(args.images))

    session = TensorRTSession(args.engine, args.imgsz)
    try:
        first_image = cv2.imread(images[0], cv2.IMREAD_COLOR)
        if first_image is None:
            raise RuntimeError("Could not read {}".format(images[0]))
        warmup_tensor = letterbox(first_image, args.imgsz)
        for unused_index in range(args.warmup):
            session.infer(warmup_tensor)

        inference_latencies = []
        end_to_end_latencies = []
        total_detections = 0
        for image_path in images:
            pipeline_started = time.perf_counter()
            image = cv2.imread(image_path, cv2.IMREAD_COLOR)
            if image is None:
                raise RuntimeError("Could not read {}".format(image_path))
            tensor = letterbox(image, args.imgsz)
            output, inference_ms = session.infer(tensor)
            total_detections += detection_count(output, args.conf, args.iou)
            end_to_end_latencies.append((time.perf_counter() - pipeline_started) * 1000.0)
            inference_latencies.append(inference_ms)

        result = {
            "status": "success",
            "model": args.model_name,
            "dataset": args.dataset,
            "engine": os.path.basename(args.engine),
            "imgsz": args.imgsz,
            "precision": args.precision,
            "num_images": len(images),
            "warmup_runs": args.warmup,
            "confidence": args.conf,
            "iou": args.iou,
            "input_shape": list(session.input_shape),
            "output_shape": list(session.output_shape),
            "total_detections": total_detections,
            "avg_detections_per_image": round(float(total_detections) / len(images), 3),
        }
        result.update(rounded_stats(inference_latencies, "inference"))
        result.update(rounded_stats(end_to_end_latencies, "end_to_end"))
        result["inference_fps"] = round(1000.0 / result["inference_avg_ms"], 3)
        result["end_to_end_fps"] = round(1000.0 / result["end_to_end_avg_ms"], 3)
        return result
    finally:
        session.close()


def main():
    parser = argparse.ArgumentParser(description="TensorRT YOLO benchmark")
    parser.add_argument("--engine", required=True)
    parser.add_argument("--images", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--model-name", required=True)
    parser.add_argument("--dataset", required=True)
    parser.add_argument("--imgsz", required=True, type=int)
    parser.add_argument("--precision", default="fp16")
    parser.add_argument("--max-images", type=int, default=50)
    parser.add_argument("--warmup", type=int, default=5)
    parser.add_argument("--conf", type=float, default=0.25)
    parser.add_argument("--iou", type=float, default=0.45)
    args = parser.parse_args()

    result = {
        "status": "failed",
        "model": args.model_name,
        "dataset": args.dataset,
        "imgsz": args.imgsz,
        "precision": args.precision,
    }
    try:
        result = benchmark(args)
        print(
            "{} @ {}: {:.3f} ms / {:.2f} FPS inference; "
            "{:.3f} ms / {:.2f} FPS end-to-end; {} detections".format(
                args.model_name,
                args.imgsz,
                result["inference_avg_ms"],
                result["inference_fps"],
                result["end_to_end_avg_ms"],
                result["end_to_end_fps"],
                result["total_detections"],
            )
        )
    except Exception as error:
        result["error"] = "{}: {}".format(type(error).__name__, error)
        print("FAILED: {}".format(result["error"]))

    output_dir = os.path.dirname(os.path.abspath(args.output))
    if not os.path.isdir(output_dir):
        os.makedirs(output_dir)
    temporary = args.output + ".tmp"
    with open(temporary, "w") as result_file:
        json.dump(result, result_file, indent=2, sort_keys=True)
        result_file.write("\n")
    os.rename(temporary, args.output)
    return 0 if result.get("status") == "success" else 1


if __name__ == "__main__":
    raise SystemExit(main())
