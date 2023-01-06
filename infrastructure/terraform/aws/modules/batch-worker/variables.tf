variable "vpc_sg" {
  type        = string
  description = "The Id of the VPC security group to attach to the RDS."
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs associated with the Lambda function."
}

variable "task_timeout" {
  type        = number
  description = "The timeout of an Airflow task. Equivalent to a max duration"
}

variable "repository_url" {
  type        = string
  description = "The URL of the ECR repository."
}

variable "image_tag" {
  type        = string
  description = "The tag of the image to deploy."
}

variable "batch_job_retries" {
  type        = number
  description = "The number of internal Batch job retries."
}

variable "airflow_cloudwatch_logs_group_arn" {
  type        = string
  description = "The ARN for the Airflow logs in cloudwatch group"
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

variable "dags_code_bucket" {
  type = object({
    name = string
    arn  = string
    id   = string
  })
  description = "The name of the DAGs bucket."
}

variable "airflow_logs_bucket_arn" {
  type        = string
  description = "The ARN of the airflow logs bucket"
}
