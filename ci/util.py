"""Utility methods
"""

from typing import Union

def resolve_conf(data: Union[dict,list], root: Union[dict,list] = None) -> dict:
    """Replace parameters variables '@parameter_name' by the corresponding
    parameter value recursively.
    """

    if root is None:
        root = data

    if isinstance(data, list):
        for i, item in enumerate(data):
            data[i] = resolve_conf(item, root)
    else:
        if isinstance(data, dict):
            for item in data:
                if isinstance(data.get(item), str) and data.get(item).startswith('@'):
                    ref_name = data.get(item)[1:]

                    ref_path = ref_name.split(".", 1)
                    ref_group_key = "parameters"
                    if len(ref_path) == 2 and ref_path[0] in root.keys():
                        ref_group_key = ref_path[0]
                        ref_name = ref_path[1]
                    ref_group = root.get(ref_group_key)

                    if not ref_name in ref_group.keys() or ref_group is None:
                        raise ValueError(f"Reference not found at {ref_path} !")
                    data[item] = ref_group.get(ref_name)
                else:
                    if isinstance(data[item], dict) or isinstance(data[item], list):
                        data[item] = resolve_conf(data[item], root)
    return data
