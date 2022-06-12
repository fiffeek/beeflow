load("@rules_python//python:defs.bzl", "py_library")

py_library(
    name = "dag_parsing",
    srcs = ["main.py"],
    imports = ["../.."],
    visibility = ["//:__subpackages__"],
    deps = [
        "//beeflow/common",
        "@pip_dependencies_apache_airflow//:pkg",
    ],
)
