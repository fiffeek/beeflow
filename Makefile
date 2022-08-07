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

push-example-dags:
	aws s3 cp src/python/beeflow/examples/dags s3://beeflow-dev-dags-code-bucket --recursive

jump-host:
	sudo chmod 400 "beeflow-dev-jump-host-ssh" && sudo ssh -i "beeflow-dev-jump-host-ssh" ec2-user@ec2-3-133-9-120.us-east-2.compute.amazonaws.com

jump-host-db-tunnel:
	sudo ssh -i "beeflow-dev-jump-host-ssh" -N -L 8090:beeflow-dev-metadata-database.citrkj3bhdyr.us-east-2.rds.amazonaws.com:5432 ec2-user@ec2-3-133-9-120.us-east-2.compute.amazonaws.com -v
