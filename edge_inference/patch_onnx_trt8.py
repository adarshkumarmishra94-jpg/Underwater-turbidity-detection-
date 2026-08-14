#!/usr/bin/env python3
"""Make dynamic Ultralytics ONNX grids parseable by TensorRT 8.0.

TensorRT 8.0 supports dynamic ``Range`` only with INT32 inputs, while recent
PyTorch exporters emit floating-point ranges. This changes each Range to INT32
and casts its output back to the original type, preserving model semantics.
"""

import argparse

import numpy as np
import onnx
from onnx import TensorProto, helper, numpy_helper


def attribute(node, name):
    for item in node.attribute:
        if item.name == name:
            return item
    return None


def producer_type(producer, initializers, value_name):
    if producer is not None and producer.op_type == "Constant":
        value = attribute(producer, "value")
        if value is not None:
            return value.t.data_type
    if producer is not None and producer.op_type == "Cast":
        target = attribute(producer, "to")
        if target is not None:
            return target.i
    if value_name in initializers:
        return initializers[value_name].data_type
    return None


def replace_constant_with_int32(node):
    value = attribute(node, "value")
    if value is None:
        raise RuntimeError("Range Constant has no tensor value: {}".format(node.name))
    converted = numpy_helper.from_array(
        numpy_helper.to_array(value.t).astype(np.int32), name=value.t.name
    )
    value.t.CopyFrom(converted)


def patch_model(model):
    producers = {output: node for node in model.graph.node for output in node.output}
    initializers = {item.name: item for item in model.graph.initializer}
    range_nodes = [node for node in model.graph.node if node.op_type == "Range"]
    if not range_nodes:
        return 0

    original_types = {}
    for node in range_nodes:
        original_type = producer_type(producers.get(node.input[0]), initializers, node.input[0])
        if original_type is None:
            raise RuntimeError("Cannot determine Range type for {}".format(node.name))
        original_types[node.name] = original_type

        for input_name in node.input:
            producer = producers.get(input_name)
            if producer is not None and producer.op_type == "Constant":
                replace_constant_with_int32(producer)
            elif producer is not None and producer.op_type == "Cast":
                target = attribute(producer, "to")
                if target is None:
                    raise RuntimeError("Cast has no target type: {}".format(producer.name))
                target.i = TensorProto.INT32
            elif input_name in initializers:
                initializer = initializers[input_name]
                converted = numpy_helper.from_array(
                    numpy_helper.to_array(initializer).astype(np.int32), name=input_name
                )
                initializer.CopyFrom(converted)
            else:
                raise RuntimeError(
                    "Unsupported Range input producer for {}: {}".format(node.name, input_name)
                )

    rewritten = []
    for node in model.graph.node:
        rewritten.append(node)
        if node.op_type != "Range":
            continue
        original_output = node.output[0]
        int32_output = original_output + "_trt8_int32"
        node.output[0] = int32_output
        rewritten.append(
            helper.make_node(
                "Cast",
                inputs=[int32_output],
                outputs=[original_output],
                name=node.name + "_trt8_restore",
                to=original_types[node.name],
            )
        )

    del model.graph.node[:]
    model.graph.node.extend(rewritten)
    return len(range_nodes)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    parser.add_argument("output", nargs="?")
    args = parser.parse_args()
    output = args.output or args.input

    model = onnx.load(args.input)
    count = patch_model(model)
    onnx.checker.check_model(model)
    onnx.save(model, output)
    print("Patched {} dynamic Range nodes for TensorRT 8.0: {}".format(count, output))


if __name__ == "__main__":
    main()
