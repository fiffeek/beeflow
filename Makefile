update_lock:
	bazel run //3rdparty/python:requirements.update

update_gazelle_manifests:
	bazel run //:gazelle_python_manifest.update

update_pip_dependencies: update_lock update_gazelle_manifests
	echo "OK"
