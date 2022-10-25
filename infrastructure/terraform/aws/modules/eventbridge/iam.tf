resource "aws_sqs_queue_policy" "scheduler" {
  queue_url = var.scheduler_sqs.id
  policy    = data.aws_iam_policy_document.scheduler.json
}

data "aws_iam_policy_document" "scheduler" {
  statement {
    sid     = "scheduler-events-policy"
    actions = ["sqs:SendMessage"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      var.scheduler_sqs.arn
    ]
  }
}

resource "aws_sqs_queue_policy" "lambda_executor" {
  queue_url = var.lambda_executor_sqs.id
  policy    = data.aws_iam_policy_document.lambda_executor.json
}

data "aws_iam_policy_document" "lambda_executor" {
  statement {
    sid     = "lambda_executor-events-policy"
    actions = ["sqs:SendMessage"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      var.lambda_executor_sqs.arn
    ]
  }
}

resource "aws_sqs_queue_policy" "batch_executor" {
  queue_url = var.batch_executor_sqs.id
  policy    = data.aws_iam_policy_document.batch_executor.json
}

data "aws_iam_policy_document" "batch_executor" {
  statement {
    sid     = "batch_executor-events-policy"
    actions = ["sqs:SendMessage"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      var.batch_executor_sqs.arn
    ]
  }
}

resource "aws_sqs_queue_policy" "dag_schedule_updater" {
  queue_url = var.dag_schedule_updater_sqs.id
  policy    = data.aws_iam_policy_document.dag_schedule_updater.json
}

data "aws_iam_policy_document" "dag_schedule_updater" {
  statement {
    sid     = "dag_schedule_updater-events-policy"
    actions = ["sqs:SendMessage"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      var.dag_schedule_updater_sqs.arn
    ]
  }
}
