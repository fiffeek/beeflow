resource "aws_sqs_queue_policy" "scheduler" {
  queue_url = var.scheduler_sqs.id
  policy    = data.aws_iam_policy_document.scheduler.json
}

data "aws_iam_policy_document" "scheduler" {
  statement {
    sid     = "events-policy"
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
