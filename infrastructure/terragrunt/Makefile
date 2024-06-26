terragrunt-fmt:
	docker-compose run --rm terragrunt_aws terragrunt hclfmt

apply_airflow-appconfig:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/airflow-appconfig && terragrunt apply"

apply_migrations-runner:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/migrations-runner && terragrunt apply"

apply_api-to-cli-forwarder:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/api-to-cli-forwarder && terragrunt apply"

apply_dag-parsing:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/dag-parsing && terragrunt apply"

apply_metadata-database:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/metadata-database && terragrunt apply"

apply_vpc:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/vpc && terragrunt apply"

apply_ecr-repositories:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/ecr-repositories && terragrunt apply"

apply_dag-schedule-updater:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/dag-schedule-updater && terragrunt apply"

apply_buckets:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/buckets && terragrunt apply"

apply_testing-buckets:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/testing-buckets && terragrunt apply"

apply_testing-lambda-worker-iam:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/testing-lambda-worker-iam && terragrunt apply"

apply_webserver:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/webserver && terragrunt apply"

destroy_webserver:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/webserver && terragrunt destroy"

apply_cdc-forwarder:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/cdc-forwarder && terragrunt apply"

apply_dms-forwarder:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/dms && terragrunt apply"
	docker-compose run --rm terragrunt_aws bash -c "cd dev/dms-cdc-forwarder && terragrunt apply"

apply_dms:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/dms && terragrunt apply"

apply_dms-cdc-forwarder:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/dms-cdc-forwarder && terragrunt apply"

destroy_dms:
	echo "Disables CDC to reduce costs for testing!"
	docker-compose run --rm terragrunt_aws bash -c "cd dev/dms-cdc-forwarder && terragrunt destroy"
	docker-compose run --rm terragrunt_aws bash -c "cd dev/dms && terragrunt destroy"

apply_eventbridge:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/eventbridge && terragrunt apply"

apply_jump-host:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/jump-host && terragrunt apply"

apply_lambda-executor:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/lambda-executor && terragrunt apply"

apply_lambda-worker:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/lambda-worker && terragrunt apply"

apply_batch-executor:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/batch-executor && terragrunt apply"

apply_batch-worker:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/batch-worker && terragrunt apply"

apply_scheduler:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/scheduler && terragrunt apply"

apply_cloudwatch-logs:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/cloudwatch-logs && terragrunt apply"

apply_testing-mwaa:
	docker-compose run --rm terragrunt_aws bash -c "cd dev/testing-mwaa && terragrunt apply"

plan_all:
	docker-compose run --rm terragrunt_aws bash -c "cd dev && terragrunt run-all plan"

apply_all:
	docker-compose run --rm terragrunt_aws bash -c "cd dev && terragrunt run-all apply"

destroy_all:
	docker-compose run --rm terragrunt_aws bash -c "cd dev && terragrunt run-all destroy"

clear-cache:
	sudo rm -rf ../../.terragrunt-cache-aws
