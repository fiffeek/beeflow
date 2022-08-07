terragrunt-fmt:
	docker-compose run --rm terragrunt_aws terragrunt hclfmt

apply_airflow-appconfig:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/airflow-appconfig && terragrunt apply"

apply_migrations-runner:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/migrations-runner && terragrunt apply"

apply_dag-parsing:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/dag-parsing && terragrunt apply"

apply_metadata-database:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/metadata-database && terragrunt apply"

apply_vpc:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/vpc && terragrunt apply"

apply_ecr-repositories:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/ecr-repositories && terragrunt apply"

apply_buckets:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/buckets && terragrunt apply"

apply_cdc-forwarder:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/cdc-forwarder && terragrunt apply"

apply_eventbridge:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/eventbridge && terragrunt apply"

apply_jump-host:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/jump-host && terragrunt apply"

plan_all:
	docker-compose run --rm terragrunt_aws bash -c "cd dev && terragrunt run-all plan"

apply_all:
	docker-compose run --rm terragrunt_aws bash -c "cd dev && terragrunt run-all apply"

destroy_all:
	docker-compose run --rm terragrunt_aws bash -c "cd dev && terragrunt run-all destroy"

clear-cache:
	sudo rm -rf ../../.terragrunt-cache-aws
