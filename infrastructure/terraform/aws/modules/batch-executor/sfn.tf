module "sfn_wrapper_label" {
  source = "cloudposse/label/null"
  version = "0.25.0"
  attributes = [
    "wrapper",
    "sfn"]
  context = module.this
}


module "batch_executor_wrapper" {
  source = "terraform-aws-modules/step-functions/aws"
  version = "2.7.1"

  name = module.sfn_wrapper_label.id
  tags = module.sfn_wrapper_label.tags

  definition = jsonencode(
  {
    "StartAt": "BATCH_JOB",
    "States": {
      "BATCH_JOB": {
        "Type": "Task",
        "Resource": "arn:aws:states:::batch:submitJob.sync",
        "Parameters": {
          "JobDefinition": var.job_definition_name,
          "JobName": "AirflowBatchWorkerExecuteTask",
          "JobQueue": var.job_queue_name,
          "Parameters": {
            "serialized.$": "$.${local.input_field_name}"
          }
          "ContainerOverrides": {
            "Command": [
              "--event",
              "Ref::serialized"]
          }
        },
        "End": true
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
    batch_WaitForTaskToken = {
      batch = true,
    }
  }

  type = "STANDARD"
}
