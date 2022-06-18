setup-venv:
	./pants export ::

update-lock-files:
	./pants generate-lockfiles

clear-cache:
	sudo rm -rf .terragrunt-cache-aws

trousers:
	./pants tailor
	./pants fmt ::
	./pants lint ::
	./pants check ::
