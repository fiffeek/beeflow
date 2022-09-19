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
    var.scheduler_sqs.arn
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
  }

  targets = {
    dag-created = [
      {
        name = "send-dag-created-orders-to-scheduler"
        arn = var.scheduler_sqs.arn
      },
    ]
  }

  tags = module.beeflow_events_label.tags
}
