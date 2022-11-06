module "beeflow_events_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "events"
  context = module.this
}

module "beeflow_events" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "1.14.2"

  bus_name = var.beeflow_main_event_bus_name

  attach_sqs_policy = true
  sqs_target_arns = [
    var.scheduler_sqs.arn,
    var.lambda_executor_sqs.arn,
    var.dag_schedule_updater_sqs.arn,
    var.batch_executor_sqs.arn,
  ]

  rules = {
    dag-created = {
      description = "Capture DAG creation data"
      event_pattern = jsonencode({
        "detail" : {
          "event_type" : [
          "dag_created"]
        }
      })
      enabled = true
    }
    dag-updated = {
      description = "Capture DAG update data"
      event_pattern = jsonencode({
        "detail" : {
          "event_type" : [
          "dag_updated"]
        }
      })
      enabled = true
    }
    task-queued-lambda = {
      description = "Capture task queued event for the lambda executor"
      event_pattern = jsonencode({
        "detail" : {
          "event_type" : [
          "task_instance_queued"],
          "queue" : [
          "lambda"]
        }
      })
      enabled = true
    }
    task-queued-batch = {
      description = "Capture task queued event for the batch executor"
      event_pattern = jsonencode({
        "detail" : {
          "event_type" : [
          "task_instance_queued"],
          "queue" : [
          "batch"]
        }
      })
      enabled = true
    }
    task-failed = {
      description = "Capture task failed events"
      event_pattern = jsonencode({
        "detail" : {
          "event_type" : [
          "task_instance_failed"]
        }
      })
      enabled = true
    }
    task-succeeded = {
      description = "Capture task succeeded events"
      event_pattern = jsonencode({
        "detail" : {
          "event_type" : [
          "task_instance_success"]
        }
      })
      enabled = true
    }
    task-skipped = {
      description = "Capture task skipped events"
      event_pattern = jsonencode({
        "detail" : {
          "event_type" : [
          "task_instance_skipped"]
        }
      })
      enabled = true
    }
    task-up-for-retry = {
      description = "Capture task up for retry events"
      event_pattern = jsonencode({
        "detail" : {
          "event_type" : [
          "task_instance_up_for_retry"]
        }
      })
      enabled = true
    }
    task-transient-states = {
      description = "Capture task transient events"
      event_pattern = jsonencode({
        "detail" : {
          "event_type" : [
            "task_instance_upstream_failed",
          "task_instance_unknown"]
        }
      })
      enabled = true
    }
    dag-run-failed = {
      description = "Capture dag run failed events"
      event_pattern = jsonencode({
        "detail" : {
          "event_type" : [
          "dag_run_failed"]
        }
      })
      enabled = true
    }
    dag-run-succeeded = {
      description = "Capture dag run succeeded events"
      event_pattern = jsonencode({
        "detail" : {
          "event_type" : [
          "dag_run_success"]
        }
      })
      enabled = true
    }
  }

  targets = {
    dag-created = [
      {
        name             = "send-dag-created-orders-to-scheduler"
        arn              = var.scheduler_sqs.arn
        message_group_id = var.scheduler_sqs.message_group_id
      },
      {
        name = "send-dag-created-orders-to-schedule-updater"
        arn  = var.dag_schedule_updater_sqs.arn
      },
    ]
    dag-updated = [
      {
        name             = "send-dag-updated-events-to-scheduler"
        arn              = var.scheduler_sqs.arn
        message_group_id = var.scheduler_sqs.message_group_id
      },
      {
        name = "send-dag-updated-events-to-schedule-updater"
        arn  = var.dag_schedule_updater_sqs.arn
      },
    ]
    task-queued-lambda = [
      {
        name = "send-task-queued-events-to-lambda-executor"
        arn  = var.lambda_executor_sqs.arn
      },
    ]
    task-queued-batch = [
      {
        name = "send-task-queued-events-to-batch-executor"
        arn  = var.batch_executor_sqs.arn
      },
    ]
    task-failed = [
      {
        name             = "send-task-failed-events-to-scheduler"
        arn              = var.scheduler_sqs.arn
        message_group_id = var.scheduler_sqs.message_group_id
      },
    ]
    task-succeeded = [
      {
        name             = "send-task-success-events-to-scheduler"
        arn              = var.scheduler_sqs.arn
        message_group_id = var.scheduler_sqs.message_group_id
      },
    ]
    task-skipped = [
      {
        name             = "send-task-skipped-events-to-scheduler"
        arn              = var.scheduler_sqs.arn
        message_group_id = var.scheduler_sqs.message_group_id
      },
    ]
    task-up-for-retry = [
      {
        name             = "send-task-up-for-retry-events-to-scheduler"
        arn              = var.scheduler_sqs.arn
        message_group_id = var.scheduler_sqs.message_group_id
      },
    ]
    task-transient-states = [
      {
        name             = "send-task-transient-events-to-scheduler"
        arn              = var.scheduler_sqs.arn
        message_group_id = var.scheduler_sqs.message_group_id
      },
    ]
    dag-run-failed = [
      {
        name             = "send-dag-run-failed-events-to-scheduler"
        arn              = var.scheduler_sqs.arn
        message_group_id = var.scheduler_sqs.message_group_id
      },
    ]
    dag-run-succeeded = [
      {
        name             = "send-dag-run-success-events-to-scheduler"
        arn              = var.scheduler_sqs.arn
        message_group_id = var.scheduler_sqs.message_group_id
      },
    ]
  }

  tags = module.beeflow_events_label.tags
}
