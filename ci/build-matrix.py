"""This script generates CI matrix file(s)"""
import copy
import os
import json
import re

from typing import Union
from util import resolve_conf
import yaml


class MatrixBuilder:
    """A class to generate matrix files for either Github Workflows or Azure Pipelines"""

    def generate(self):
        """Generate a matrix of runners and inner environments to be used by CI pipelines"""

        raw_config: dict = {}
        with open(os.path.dirname(__file__) + '/config.yaml', 'r', encoding="utf-8") as file:
            raw_config = yaml.safe_load(file)
        config = resolve_conf(copy.deepcopy(raw_config))

        for runner_type in ["github", "azure"]:
            runners = [runner for runner in config.get("runners")
                if runner.get("type") == runner_type]

            matrix: Union[dict,list] = []
            for runner in runners:
                matrix_item = {
                    "label": runner.get("label"),
                    ("runs-on" if runner_type == "github" else "vmImage"): runner.get("runs-on")
                }

                # xor
                assert( (runner.get("setup") is not None) != (runner.get("image") is not None))

                if runner.get("setup") is not None:
                    setup = config.get("setup").get(runner.get("setup"))

                    if setup is None:
                        raise RuntimeError(f"Setup not found {runner.get('setup')}")
                    matrix_item["setup"] = runner.get("setup")
                    matrix_item["name"] = runner.get("setup")

                elif runner.get("image") is not None:
                    image_name = (runner.get("image", {}).get("repository", "") + ":"
                                + runner.get("image", {}).get("tag", ""))
                    image = config.get("images").get(image_name)

                    if image is None:
                        raise RuntimeError(f"Image not found {runner.get('image')}")

                    setup = config.get("setup").get(image.get("setup"))
                    if setup is None:
                        raise RuntimeError(f"Setup not found {runner.get('setup')}")

                    matrix_item["image"] = image.get("repository") + ":" + image.get("tag")

                    if matrix_item["label"] is None:
                        matrix_item["label"] = image.get("label")

                    matrix_item["name"] = image.get("tag")

                if matrix_item["label"] is None:
                    matrix_item["label"] = setup.get("label")

                matrix.append(matrix_item)

            if runner_type == "azure":
                matrix = { re.sub('[^0-9a-zA-Z]+', '-', v.get("name")):v for v in matrix }

            data = json.dumps({
                "_comment": "This file has been generated. Please do not edit",
                "matrix": matrix}, indent=2)
            with open(
                os.path.dirname(__file__) + f"/shared/matrix/{runner_type}.json",
                'w+',
                encoding="utf-8"
            ) as file:
                file.write(data)

MatrixBuilder().generate()
