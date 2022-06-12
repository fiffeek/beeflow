load("@rules_python//python:defs.bzl", "py_binary", "py_library", "py_test")

py_library(
    name = "common",
    srcs = [
        "__init__.py",
        "integer_sum.py",
    ],
    imports = ["../.."],
    visibility = ["//:__subpackages__"],
)

py_test(
    name = "common_test",
    srcs = [
        "__test__.py",
        "common_test.py",
        "integer_sum_test.py",
    ],
    imports = ["../.."],
    main = "__test__.py",
    deps = [":common"],
)

py_binary(
    name = "common_bin",
    srcs = ["__main__.py"],
    imports = ["../.."],
    main = "__main__.py",
    visibility = ["//:__subpackages__"],
    deps = [":common"],
)
