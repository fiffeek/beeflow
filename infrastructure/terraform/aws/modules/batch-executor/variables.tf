variable "vpc_sg" {
  type        = string
  description = "The Id of the VPC security group to attach to the RDS."
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs associated with the Lambda function."
}

variable "configuration_bucket_name" {
  type        = string
  description = "The name of the bucket with the Airflow configuration files"
}

variable "configuration_bucket_arn" {
  type        = string
  description = "The ARN of the bucket with the Airflow configuration files"
}

variable "configuration_bucket_airflow_config_key" {
  type        = string
  description = "The key of the Airflow configuration in the Airflow configuration bucket"
}

variable "airflow_home" {
  type        = string
  description = "Airflow home directory."
}

variable "batch_executor_package_absolute_path" {
  type        = string
  description = "Absolute path to the Batch Executor lambda package"
}

variable "batch_executor_package_filename" {
  type        = string
  description = "Filename of the Batch Executor lambda package"
}

variable "pants_lambda_entrypoint" {
  type        = string
  description = "Lambda entrypoint for pants generated packaged."
}

variable "pants_lambda_python_version" {
  type        = string
  description = "The version of python that Pants built the package with."
}

variable "lambda_code_bucket_name" {
  type        = string
  description = "Name of the lambda code bucket."
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
  type        = string
  description = "The name of the Batch worker job queue"
}

variable "job_definition_name" {
  type        = string
  description = "The name of the Batch job definition"
}

variable "catcher_lambda" {
  type = object({
    repository_url = string
    image_tag      = string
  })
  description = "Repository and tag for the batch executor catcher lambda"
}

variable "airflow_logs_bucket_arn" {
  type        = string
  description = "The ARN of the airflow logs bucket"
}
