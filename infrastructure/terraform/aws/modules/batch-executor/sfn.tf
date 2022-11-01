module "sfn_wrapper_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  attributes = [
    "wrapper",
  "sfn"]
  context = module.this
}

module "batch_executor_wrapper" {
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
          "Resource" : "arn:aws:states:::batch:submitJob.sync",
          "Parameters" : {
            "JobDefinition" : var.job_definition_name,
            "JobName" : "AirflowBatchWorkerExecuteTask",
            "JobQueue" : var.job_queue_name,
            "Parameters" : {
              "serialized.$" : "$.${local.input_field_name}"
            }
            "ContainerOverrides" : {
              "Command" : [
                "--event",
              "Ref::serialized"]
            }
          },
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
    batch_Sync = {
      batch = true,
      events = [
      "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule/StepFunctionsGetEventsForBatchJobsRule"],
    }
    lambda = {
      lambda = [module.catcher_lambda.arn]
    }
    batch_WaitForTaskToken = {
      batch = true,
    }
  }

  type = "STANDARD"
}
