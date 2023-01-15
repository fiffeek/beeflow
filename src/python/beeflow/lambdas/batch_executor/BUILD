python_sources()

python_awslambda(
    name = "package",
    dependencies = ["src/python/beeflow/packages/config:config"],
    handler = "batch_executor.py:handler",
    runtime = "python3.9",
)
