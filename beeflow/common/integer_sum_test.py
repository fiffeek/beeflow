import unittest

from beeflow.common.integer_sum import integer_sum


class TestOne(unittest.TestCase):
    """Unittest class for one module"""

    def test_one(self):
        assert integer_sum(1, 2) == 3


if __name__ == "__main__":
    unittest.main()
