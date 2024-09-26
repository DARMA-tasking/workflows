"""Utility methods
"""

from typing import Union

def resolve_item_params(item, root: Union[dict,list] = None):
    if isinstance(item, str) and item.startswith('@'):
        ref_name = item[1:]
        ref_path = ref_name.split(".", 1)
        ref_group_key = "parameters"
        if len(ref_path) == 2 and ref_path[0] in root.keys():
            ref_group_key = ref_path[0]
            ref_name = ref_path[1]
        ref_group = root.get(ref_group_key)

        if ref_group is None or not ref_name in ref_group.keys() or ref_group is None:
            raise ValueError(f"Reference {item} not found !")

        return ref_group.get(ref_name)
    return item

def resolve_params(data: Union[dict,list], root: Union[dict,list] = None) -> dict:
    """Replace parameters variables '@parameter_name' by the corresponding
    parameter value recursively.
    """

    if root is None:
        root = data

    if isinstance(data, list):
        for i, item in enumerate(data):
            if isinstance(item, dict) or isinstance(item, list):
                data[i] = resolve_params(item, root)
            else:
                data[i] = resolve_item_params(item, root)
    else:
        if isinstance(data, dict):
            for item in data:
                if isinstance(data[item], dict) or isinstance(data[item], list):
                    data[item] = resolve_params(data[item], root)
                else:
                    data[item] = resolve_item_params(data[item], root)
    return data

def resolve_conf(config: Union[dict,list]) -> dict:
    config = resolve_params(config)

    # Index Docker images by their full name
    config["images"] = dict((image.get("repository") + ":" + image.get("tag"), image)
                for image in config.get("images"))

    return config
