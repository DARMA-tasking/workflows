"""This script enable to build a docker image"""
import copy
import os
import sys

from util import resolve_conf
import yaml

class DockerBuilder:
    """Dockerfile generator class"""

    def build(self, args: list):
        """Build an image using a given docker configuration fro the config file"""

        raw_config: dict = {}
        with open(os.path.dirname(__file__) + "/config.yaml", 'r', encoding="utf-8") as file:
            raw_config = yaml.safe_load(file)

        config = resolve_conf(copy.deepcopy(raw_config))
        images = config.get("images")
        setup = config.get("setup")

        image_tag = None
        if len(args) > 0:
            image_tag = args[0]
            if image_tag not in images.keys():
                print(f"[error] Image not found {image_tag}.\n"
                      f"Available images:{(os.linesep + '- ')}"
                      f"{(os.linesep + '- ') . join(images.keys())}")
                raise SystemExit(1)
        else:
            # Step 1: list platforms and their configurations
            choices = {k: v for k, v in enumerate(images.keys())}
            print("Choose image: ")
            for i in choices:
                image = images.get(choices[i])
                setup_id = image.get("setup")
                current_setup = setup.get(setup_id)
                if current_setup is None:
                    raise RuntimeError(f"Invalid setup {setup_id}")
                lbl = current_setup.get("label", image.get("setup"))
                print(
                    f"\033[1m[{i}] {choices[i]}\033[0m\n"
                    f"    \033[3;34m{lbl}\033[0m"
                )
            choice = input("> ")

            image_tag = choices[int(choice)]

        image = images.get(image_tag)
        print("Selected image:")
        print("---------------------------")
        print(yaml.dump(image, default_flow_style=True))
        print("---------------------------")

        image_setup = setup.get(image.get("setup"))
        dockerfile = image.get("dockerfile")
        env = image_setup.get("env")

        args = {
            "ARCH": image.get("arch"),
            "BASE": image.get("base"),
            "SETUP_ID": image.get("setup")
        }
        # Env
        supported_env_keys = [
            # Compiler
            "CC", "CXX", "FC",
            # MPI
            "MPICH_CC", "MPICH_CXX",
            # Intel
            "CMPLR_ROOT", "INTEL_LICENSE_FILE", "ONEAPI_ROOT", "TBBROOT",
            "CMAKE_PREFIX_PATH", "CPATH", "INFOPATH", "LIBRARY_PATH", "LD_LIBRARY_PATH",
            # Path
            "PATH_PREFIX"
        ]
        for env_key in supported_env_keys:
            args[env_key] = env.get(env_key, '')

        invalid_keys = list(key for key in env if not key in supported_env_keys)
        if len(invalid_keys) > 0:
            raise RuntimeError(f"warning: env keys not supported: {invalid_keys}")

        space = ' '

        escaped_args = { k:f'"{v}"' for (k,v) in args.items()}

        cmd = ("docker build . "
                f" --tag {image_tag}"
                f" --file {os.path.dirname(__file__)}/docker/{dockerfile}"
                f" {space.join([f'--build-arg {k}={v}' for (k,v) in escaped_args.items()])}"
                f" --cache-from={image_tag}" # use previously built image as a cache layer.
                # " --no-cache"
                " --progress=plain"
            )
        print(cmd)
        status = os.system(cmd)
        exit(status)

        # ENHANCEMENT: option to push to Dockerhub

DockerBuilder().build(sys.argv[1:])
