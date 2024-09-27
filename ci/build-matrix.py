import copy
import os
import json

from util import resolve_conf
import yaml


class MatrixGenerator:
    """MatrixGenerator to generate a matrix file for Github and Azure Pipelines"""

    def generate(self):
        """Generate a matrix of runners and inner environments to be used by CI pipelines"""

        raw_config: dict = {}
        with open(os.path.dirname(__file__) + '/config.yaml', 'r', encoding="utf-8") as file:
            raw_config = yaml.safe_load(file)
        config = resolve_conf(copy.deepcopy(raw_config))

        for runner_type in ["github", "azure-pipelines"]:
            runners = [runner for runner in config.get("runners")
                if runner.get("type") == runner_type]

            matrix = []
            for runner in runners:
                matrix_item = {
                    "label": runner.get("label"),
                    "runs-on": runner.get("runs-on")
                }

                if runner.get("setup") is not None:
                    setup = config.get("setup").get(runner.get("setup"))

                    if setup is None:
                        raise RuntimeError(f"Setup not found {runner.get('setup')}")

                    matrix_item["setup"] = runner.get("setup")

                if runner.get("image") is not None:
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

                if matrix_item["label"] is None:
                    matrix_item["label"] = setup.get("label")

                matrix.append(matrix_item)

            data = json.dumps({
                "_comment": "This file has been generated. Please do not edit",
                "matrix": matrix}, indent=2)
            with open(
                os.path.dirname(__file__) + f"/shared/matrix/{runner_type}.json",
                'w+',
                encoding="utf-8"
            ) as file:
                file.write(data)

MatrixGenerator().generate()