locals {
  environment_variables = {
    BEEFLOW__APP_CONFIG_NAME = var.appconfig_application_configuration_name,
    BEEFLOW__APPLICATION = var.appconfig_application_name,
    POWERTOOLS_SERVICE_NAME = module.this.id,
    POWERTOOLS_LOGGER_LOG_EVENT = "true"
    AIRFLOW_HOME = var.airflow_home,
    AIRFLOW_CONN_AWS_DEFAULT = "aws://"
    BEEFLOW__ENVIRONMENT = module.this.environment,
    PYTHONUNBUFFERED = "1"
  }
  transformed_env_vars = [
  for key, value in local.environment_variables : {
    name: key
    value: value
  }
  ]
}

module "worker" {
  source = "terraform-aws-modules/batch/aws"
  version = "1.2.1"

  instance_iam_role_name = "${module.this.id}-ecs-instance"
  instance_iam_role_path = "/batch/"
  instance_iam_role_description = "IAM instance role/profile for AWS Batch ECS instance(s)"
  service_iam_role_additional_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
  instance_iam_role_tags = module.this.tags

  service_iam_role_name = "${module.this.id}-batch"
  service_iam_role_path = "/batch/"
  service_iam_role_description = "IAM service role for AWS Batch"
  service_iam_role_tags = module.this.tags

  compute_environments = {
    a_fargate = {
      name_prefix = "fargate"

      compute_resources = {
        type = "FARGATE"
        max_vcpus = 1

        security_group_ids = [
          var.vpc_sg]
        subnets = var.subnet_ids
      }
    }
  }

  job_queues = {
    queue = {
      name = "BatchWorkerQueue"
      state = "ENABLED"
      priority = 1
      # FIFO for the time being
      create_scheduling_policy = false

      tags = {
        JobQueue = "Priority job queue with 1 prio"
      }
    }
  }

  job_definitions = {
    airflow_task = {
      name = "AirflowTask"
      propagate_tags = true
      platform_capabilities = [
        "FARGATE"]

      container_properties = jsonencode({
        command = [
          "/bin/batch_worker"]
        image = "${var.repository_url}:${var.image_tag}"
        fargatePlatformConfiguration = {
          platformVersion = "LATEST"
        },
        environment = local.transformed_env_vars
        resourceRequirements = [
          {
            type = "VCPU",
            value = "0.25"
          },
          {
            type = "MEMORY",
            value = "512"
          }
        ],
        executionRoleArn = aws_iam_role.ecs_task_execution_role.arn
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group = aws_cloudwatch_log_group.this.id
            awslogs-region = data.aws_region.current.name
            awslogs-stream-prefix = module.this.id
          }
        }
      })

      attempt_duration_seconds = var.task_timeout
      retry_strategy = {
        attempts = var.batch_job_retries
        evaluate_on_exit = {
          retry_error = {
            action = "RETRY"
            on_exit_code = 1
          }
          exit_success = {
            action = "EXIT"
            on_exit_code = 0
          }
        }
      }

      tags = module.this.tags
    }
  }

  tags = module.this.tags
}
