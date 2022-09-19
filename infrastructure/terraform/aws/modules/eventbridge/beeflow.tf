module "beeflow_events_label" {
  source = "cloudposse/label/null"
  version = "0.25.0"
  name = "events"
  context = module.this
}

module "beeflow_events" {
  source = "terraform-aws-modules/eventbridge/aws"
  version = "1.14.2"

  bus_name = var.beeflow_main_event_bus_name

  attach_sqs_policy = true
  sqs_target_arns = [
    var.scheduler_sqs.arn,
    var.lambda_executor_sqs.arn
  ]

  rules = {
    dag-created = {
      description = "Capture DAG creation data"
      event_pattern = jsonencode({
        "detail": {
          "event_type" : [
            "dag_created"]
        }
      })
      enabled = true
    }
    dag-updated = {
      description = "Capture DAG update data"
      event_pattern = jsonencode({
        "detail": {
          "event_type" : [
            "dag_updated"]
        }
      })
      enabled = true
    }
    task-queued = {
      description = "Capture task queued event"
      event_pattern = jsonencode({
        "detail": {
          "event_type" : [
            "task_instance_queued"]
        }
      })
      enabled = true
    }
  }

  targets = {
    dag-created = [
      {
        name = "send-dag-created-orders-to-scheduler"
        arn = var.scheduler_sqs.arn
      },
    ]
    dag-updated = [
      {
        name = "send-dag-updated-events-to-scheduler"
        arn = var.scheduler_sqs.arn
      },
    ]
    task-queued = [
      {
        name = "send-task-queued-events-to-lambda-executor"
        arn = var.lambda_executor_sqs.arn
      },
    ]
  }

  tags = module.beeflow_events_label.tags
}
