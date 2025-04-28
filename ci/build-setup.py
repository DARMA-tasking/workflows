"""This script generates setup scripts"""
import copy
import os
import sys
from typing import List, Union

from util import resolve_conf_deps
import yaml

class SetupBuilder:
    """Setup files generator class"""

    def __instructions(self, dep_id, args: Union[list, dict]) -> List[str]:
        """ Generate shell instructions to setup a dependency"""

        # basic command to run in setup script (bash)
        if dep_id == "cmd":
            assert isinstance(args, list)
            return [ f"{' '.join(args)}" ]

        call_args = []
        env = []

        # repeat instructions if args is an array of array
        if args is not None and len(args) > 0:
            if isinstance(args, list) and isinstance(args[0], list):
                instructions = []
                for (_, sub_args) in enumerate(args):
                    instructions.extend(self.__instructions(dep_id, sub_args))
                return instructions

            env = []
            if isinstance(args, dict):
                call_args = [ f"\"{a}\"" for a in args.get("args", [])]
                env = [ f"{k}=\"{v}\"" for k, v in args.get("env", {}).items()]
            else:
                call_args = [ f"\"{a}\"" for a in args]
                env = []

        cmd = f"./{dep_id}.sh"
        if len(call_args) > 0:
            cmd = f"{cmd} {' '.join(call_args)}"
        if len(env) > 0:
            cmd = f"{' '.join(env)} {cmd}"

        return [ cmd ]

    def build_specific_configuration(self):
        """Build setup script based on specitic setup configuration passed"""
        build_deps_yaml = os.environ.get("BUILD_DEPS")
        raw_config = yaml.safe_load(build_deps_yaml)

        config = resolve_conf_deps(copy.deepcopy(raw_config))

        setup_id = sys.argv[1]
        instructions = []

        for (dep_id, args) in config.items():
            instructions.extend(self.__instructions(dep_id, args))

        setup_script = ""
        with open(
                os.path.dirname(__file__) + "/setup-template.sh",
                'r',
                encoding="utf-8"
        ) as file:
            setup_script = file.read()
            setup_script = setup_script.replace("%ENVIRONMENT_LABEL%", setup_id)
            setup_script = setup_script.replace("%DEPS_INSTALL%", '\n'.join(instructions))

        setup_filename = f"setup-{setup_id}.sh"
        setup_filepath = os.path.join(os.path.dirname(__file__), setup_filename)

        with open(setup_filepath, "w+", encoding="utf-8") as f:
            f.write(setup_script)

SetupBuilder().build_specific_configuration()
