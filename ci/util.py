"""Utility methods
"""

import copy
from typing import Union

import yaml


# < YAML custom tags
def yaml_list_extend_loader(loader, node):
    """Loads a YAML sequence node defining a list to extend and the elements to add"""
    if not isinstance(node, yaml.SequenceNode):
        raise RuntimeError("!extend only applicable to sequences")
    params = loader.construct_sequence(node)
    if not isinstance(params[0], list):
        raise RuntimeError("!extend first argument must be a list")

    l: list = copy.deepcopy(params[0])
    if len(params) > 1:
        for p in params[1:]:
            if not isinstance(p, list):
                l.extend([p])
            else:
                l.extend(p)
    return l

# Required for safe_load
yaml.SafeLoader.add_constructor("!extend", yaml_list_extend_loader)
# > YAML custom tags

def resolve_conf(config: Union[dict,list]) -> dict:
    """Update configuration to ease its processing:
    - Turn images list into a dict (images indexed by `repo:tag`)
    - Add some required missing keys with default values
    """
    if config.get("images") is None:
        config["images"] = []

    if config.get("runners") is None:
        config["runners"] = []

    if config.get("setup") is None:
        config["setup"] = {}

    for (_setup_id, setup) in config.get("setup").items():
        if setup.get("deps") is None:
            setup["deps"] = {}

        for dep_id, args in setup["deps"].items():
            # no args
            if args is None:
                setup["deps"][dep_id] = []
            # single arg
            elif not isinstance(args, list) and not isinstance(args, dict):
                setup["deps"][dep_id] = [ args ]

    # Index Docker images by their full name
    config["images"] = dict((image.get("repository") + ":" + image.get("tag"), image)
                for image in config.get("images"))

    return config
