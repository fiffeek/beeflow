module "sqs_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "dag-parsing-sqs"
  context = module.this
}

resource "aws_sqs_queue" "dag_parsing_wait_list" {
  name                       = module.sqs_label.id
  tags                       = module.sqs_label.tags
  visibility_timeout_seconds = 80
  message_retention_seconds  = 600
}

data "aws_iam_policy_document" "allow_s3_notifications" {
  statement {
    effect = "Allow"
    actions = [
    "sqs:SendMessage"]

    principals {
      type = "Service"
      identifiers = [
      "s3.amazonaws.com"]
    }

    resources = [
    aws_sqs_queue.dag_parsing_wait_list.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values = [
      var.dags_code_bucket.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "allow_s3_notifications" {
  queue_url = aws_sqs_queue.dag_parsing_wait_list.id
  policy    = data.aws_iam_policy_document.allow_s3_notifications.json
}

resource "aws_s3_bucket_notification" "dags_changing_notifications" {
  bucket = var.dags_code_bucket.id

  queue {
    queue_arn = aws_sqs_queue.dag_parsing_wait_list.arn
    events = [
      "s3:ObjectCreated:*",
    "s3:ObjectRemoved:*"]
  }
}
