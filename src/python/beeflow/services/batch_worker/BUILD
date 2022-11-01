python_sources(
    name = "package",
    dependencies = ["src/python/beeflow/packages/config:config"],
)

pex_binary(
    name = "bin",
    dependencies = [":package"],
    entry_point = "batch_worker.py",
)

docker_image(
    name = "docker",
    dependencies = [":bin"],
)
