variable "vpc_sg" {
  type        = string
  description = "The Id of the VPC security group to attach to the RDS."
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs associated with the Lambda function."
}

variable "appconfig_application_name" {
  type        = string
  description = "The name of the AppConfig Application."
}

variable "appconfig_application_configuration_name" {
  type        = string
  description = "The name of the AppConfig Application Configuration."
}

variable "airflow_home" {
  type        = string
  description = "Airflow home directory."
}

variable "repository_url" {
  type        = string
  description = "The URL of the ECR repository."
}

variable "image_tag" {
  type        = string
  description = "The tag of the image to deploy."
}

variable "dags_code_bucket" {
  type = object({
    name = string
    arn  = string
    id   = string
  })
  description = "The name of the DAGs bucket."
}

variable "airflow_cloudwatch_logs_group_arn" {
  type        = string
  description = "The ARN for the Airflow logs in cloudwatch group"
}

variable "job_queue_name" {
  type = string
  description = "The name of the Batch worker job queue"
}

variable "job_definition_name" {
  type = string
  description = "The name of the Batch job definition"
}

variable "catcher_lambda" {
  type = object({
    repository_url = string
    image_tag = string
  })
  description = "Repository and tag for the batch executor catcher lambda"
}