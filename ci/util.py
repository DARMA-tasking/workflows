"""Utility methods
"""

from typing import Union

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
            if not isinstance(args, list):
                setup["deps"][dep_id] = [ args ]

        # flatten package dependencies
        if setup["deps"].get("packages") is not None:
            flattened_args = []
            for (_, arg) in enumerate(setup["deps"].get("packages")):
                if isinstance(arg, list):
                    flattened_args.extend(arg)
                else:
                    flattened_args.append(arg)
            setup["deps"]["packages"] = flattened_args   

    # Index Docker images by their full name
    config["images"] = dict((image.get("repository") + ":" + image.get("tag"), image)
                for image in config.get("images"))

    return config
