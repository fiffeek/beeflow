module "sfn_wrapper_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  attributes = [
    "wrapper",
  "sfn"]
  context = module.this
}

module "lambda_executor_wrapper" {
  source  = "terraform-aws-modules/step-functions/aws"
  version = "2.7.1"

  name = module.sfn_wrapper_label.id
  tags = module.sfn_wrapper_label.tags

  definition = jsonencode(
    {
      "StartAt" : "EXECUTE_AIRFLOW_TASK",
      "States" : {
        "EXECUTE_AIRFLOW_TASK" : {
          "Type" : "Task",
          "Resource" : var.lambda_worker_arn,
          "InputPath" : "$.${local.input_field_name}",
          "Catch" : [
            {
              "ErrorEquals" : [
              "States.ALL"],
              "Next" : "MARK_TASK_AS_FAILED",
              "ResultPath" : "$.error"
          }],
          "End" : true
        },
        "MARK_TASK_AS_FAILED" : {
          "Type" : "Task",
          "Resource" : module.catcher_lambda.arn,
          "End" : true
        }
      }
    }
  )

  service_integrations = {
    lambda = {
      lambda = [module.catcher_lambda.arn, var.lambda_worker_arn]
    }
  }

  type = "STANDARD"
}
