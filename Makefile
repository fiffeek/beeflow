setup-venv:
	./pants export ::

update-lock-files:
	./pants generate-lockfiles

clear-cache:
	sudo rm -rf .terragrunt-cache-aws

all:
	./pants tailor
	./pants fmt ::
	./pants lint ::
	./pants check ::

lab:
	./pants run //notebooks/lab.py:python-jupyter_main -- --notebook-dir notebooks

dev/run/migrations:
	aws lambda invoke \
		--function-name beeflow-dev-migrations-runner \
		--payload '{}' \
		response.json
