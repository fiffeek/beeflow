import itertools


def flatten(nested_list):
    return list(itertools.chain(*nested_list))
