variable "beeflow_main_event_bus_name" {
  type = string
  description = "The name of the main Beeflow event bus"
}

variable "scheduler_sqs" {
  type = object({
    arn = string,
    id = string,
  })
  description = "The ARN/id of the SQS that serves requests to the scheduler"
}

variable "lambda_executor_sqs" {
  type = object({
    arn = string,
    id = string,
  })
  description = "The ARN/id of the SQS that serves requests to the lambda executor"
}

variable "batch_executor_sqs" {
  type = object({
    arn = string,
    id = string,
  })
  description = "The ARN/id of the SQS that serves requests to the Batch executor"
}

variable "dag_schedule_updater_sqs" {
  type = object({
    arn = string,
    id = string,
  })
  description = "The ARN/id of the SQS that serves requests to the DAG schedule updater"
}
