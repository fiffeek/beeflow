variable "lambda_code_bucket_name" {
  type        = string
  description = "Name of the lambda code bucket."
}

variable "vpc_sg" {
  type        = string
  description = "The Id of the VPC security group to attach to the RDS."
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs associated with the Lambda function."
}

variable "pants_lambda_entrypoint" {
  type        = string
  description = "Lambda entrypoint for pants generated packaged."
}

variable "pants_lambda_python_version" {
  type        = string
  description = "The version of python that Pants built the package with."
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

variable "batch_size" {
  type        = number
  description = "The number of files that has to change for a batch to invoke the reload of the DAG files."
}

variable "maximum_batching_window_in_seconds" {
  type        = number
  description = "The number of seconds that has to pass for a reload of DAG files to kick in when # files changed < batch_size."
}

variable "dag_parsing_trigger_package_absolute_path" {
  type        = string
  description = "Absolute path to the DAG parsing trigger lambda package."
}

variable "dag_parsing_trigger_package_filename" {
  type        = string
  description = "Filename of the DAG parsing trigger lambda package."
}

variable "dag_parsing_processor_repository_url" {
  type        = string
  description = "The URL of the ECR repository."
}

variable "dag_parsing_processor_image_tag" {
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

variable "dag_files_arrival_queue_enabled" {
  type        = bool
  description = "Specifies whether to enable or disable the outgoing messages to SQS from the S3 bucket."
}

variable "airflow_logs_bucket_arn" {
  type        = string
  description = "The ARN of the airflow logs bucket"
}
