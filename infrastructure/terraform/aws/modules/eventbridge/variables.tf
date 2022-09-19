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
