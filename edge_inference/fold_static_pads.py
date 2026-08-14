#!/usr/bin/env python3
"""Fold static ONNX Pad inputs into initializers for TensorRT 8.0."""

import argparse
import copy
import os
import tempfile

import numpy as np
import onnx
import onnxruntime as ort
from onnx import TensorProto, helper, numpy_helper


def tensor_shape(value_info):
    shape = []
    for dimension in value_info.type.tensor_type.shape.dim:
        if not dimension.HasField("dim_value") or dimension.dim_value <= 0:
            raise RuntimeError("Model input must have a fixed shape")
        shape.append(dimension.dim_value)
    return tuple(shape)


def run_model(model_path, input_name, input_value):
    session = ort.InferenceSession(model_path, providers=["CPUExecutionProvider"])
    return session.run(None, {input_name: input_value})


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    parser.add_argument("output", nargs="?")
    args = parser.parse_args()
    output_path = args.output or args.input

    model = onnx.load(args.input)
    if len(model.graph.input) != 1:
        raise RuntimeError("Expected exactly one model input")
    model_input = model.graph.input[0]
    shape = tensor_shape(model_input)
    input_dtype = onnx.helper.tensor_dtype_to_np_dtype(
        model_input.type.tensor_type.elem_type
    )
    sample = np.zeros(shape, dtype=input_dtype)
    pad_nodes = [node for node in model.graph.node if node.op_type == "Pad"]
    if not pad_nodes:
        print("No Pad nodes found: {}".format(args.input))
        return

    debug_model = copy.deepcopy(model)
    debug_outputs = []
    existing_outputs = {item.name for item in debug_model.graph.output}
    for node in pad_nodes:
        for input_name in node.input[1:]:
            if input_name and input_name not in existing_outputs:
                debug_model.graph.output.append(
                    helper.make_tensor_value_info(input_name, TensorProto.UNDEFINED, None)
                )
                existing_outputs.add(input_name)
                debug_outputs.append(input_name)

    descriptor, debug_path = tempfile.mkstemp(suffix=".onnx")
    os.close(descriptor)
    try:
        onnx.save(debug_model, debug_path)
        session = ort.InferenceSession(debug_path, providers=["CPUExecutionProvider"])
        output_names = [item.name for item in session.get_outputs()]
        values = session.run(None, {model_input.name: sample})
        by_name = dict(zip(output_names, values))
        folded = {name: by_name[name] for name in debug_outputs}
        original_output_names = [item.name for item in model.graph.output]
        baseline_outputs = [by_name[name] for name in original_output_names]
    finally:
        os.unlink(debug_path)

    initializers = {item.name for item in model.graph.initializer}
    count = 0
    for node in pad_nodes:
        for index in range(1, len(node.input)):
            old_name = node.input[index]
            if not old_name:
                continue
            new_name = "{}_trt8_initializer_{}".format(node.name.replace("/", "_"), index)
            if new_name not in initializers:
                value = np.ascontiguousarray(folded[old_name])
                model.graph.initializer.append(numpy_helper.from_array(value, name=new_name))
                initializers.add(new_name)
            node.input[index] = new_name
        count += 1

    onnx.checker.check_model(model)
    onnx.save(model, output_path)

    # A final runtime load catches invalid rewrites before any network transfer.
    session = ort.InferenceSession(output_path, providers=["CPUExecutionProvider"])
    patched_outputs = session.run(None, {model_input.name: sample})
    if len(baseline_outputs) != len(patched_outputs):
        raise RuntimeError("Output count changed after folding Pad inputs")
    for before, after in zip(baseline_outputs, patched_outputs):
        if not np.allclose(before, after, rtol=1e-5, atol=1e-6):
            raise RuntimeError("Model output changed after folding Pad inputs")
    print("Folded {} static Pad nodes for TensorRT 8.0: {}".format(count, output_path))


if __name__ == "__main__":
    main()
