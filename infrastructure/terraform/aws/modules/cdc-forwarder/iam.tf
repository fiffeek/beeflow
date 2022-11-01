data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "push_events_to_eventbridge_access" {
  statement {
    sid = "PushEventBridgeEvents"
    actions = [
      "events:PutEvents",
    ]
    resources = [
    "arn:aws:events:${var.aws_region}:${data.aws_caller_identity.current.account_id}:event-bus/${var.beeflow_main_event_bus_name}"]
  }
}

module "push_events_to_eventbridge_access_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "eventbridge-push-access"
  context = module.this
}

resource "aws_iam_policy" "push_events_to_eventbridge_access" {
  name   = module.push_events_to_eventbridge_access_label.id
  policy = data.aws_iam_policy_document.push_events_to_eventbridge_access.json
}

resource "aws_iam_role_policy_attachment" "push_events_to_eventbridge_access" {
  role       = module.cdc_forwarder_lambda.role_name
  policy_arn = aws_iam_policy.push_events_to_eventbridge_access.arn
}
