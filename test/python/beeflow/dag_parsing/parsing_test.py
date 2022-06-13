import pytest

from beeflow.dag_parsing.parsing import parse


def test_simple_parse():
    assert parse(1, 2) == 3
