python_sources()

python_awslambda(
    name = "package",
    dependencies = ["src/python/beeflow/packages/config:config"],
    handler = "main.py:handler",
    runtime = "python3.9",
)

docker_image(
    name = "docker",
    dependencies = [":package"],
)
