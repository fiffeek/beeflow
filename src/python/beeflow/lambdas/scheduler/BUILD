python_sources(
    skip_black = True,
    skip_docformatter = True,
    skip_flake8 = True,
    skip_isort = True,
    skip_mypy = True,
)

python_awslambda(
    name = "package",
    dependencies = ["src/python/beeflow/packages/config:config"],
    handler = "scheduler_runner.py:handler",
    runtime = "python3.9",
)

docker_image(
    name = "docker",
    dependencies = [":package"],
)
