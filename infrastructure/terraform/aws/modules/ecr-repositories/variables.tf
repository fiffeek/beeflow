variable "migrations_runner" {
  type        = string
  description = "Name of the migrations runner ECR repository."
}

variable "dag_parsing_processor" {
  type        = string
  description = "Name of the DAG parsing processor ECR repository."
}

variable "scheduler" {
  type = string
  description = "Name of the scheduler ECR repository."
}

variable "lambda_executor" {
  type = string
  description = "Name of the lambda executor ECR repository."
}

variable "dag_schedule_updater" {
  type = string
  description = "Name of the dag schedule updater ECR repository."
}

variable "webserver" {
  type = string
  description = "Name of the webserver ECR repository."
}

variable "batch_executor" {
  type = string
  description = "Name of the batch executor ECR repository."
}
