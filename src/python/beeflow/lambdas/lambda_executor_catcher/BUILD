python_sources()

python_awslambda(
    name = "package",
    handler = "lambda_executor_catcher.py:handler",
    runtime = "python3.9",
)

docker_image(
    name = "docker",
    dependencies = [":package"],
)
