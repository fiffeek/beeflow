load("@rules_python//python:pip.bzl", "compile_pip_requirements")

# Generates requirements_lock.txt
# bazel run //:requirements.update
compile_pip_requirements(
    name = "requirements",
    extra_args = ["--allow-unsafe"],
    requirements_in = "requirements.txt",
    requirements_txt = "requirements_lock.txt",
)
