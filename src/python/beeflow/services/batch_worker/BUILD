python_sources(
    name="package",
    dependencies=[
        "src/python/beeflow/packages/config:config"
    ]
)

pex_binary(
    name="bin",
    entry_point="batch_worker.py",
    dependencies=[":package"]
)

docker_image(
    name="docker",
    dependencies = [":bin"],
)
