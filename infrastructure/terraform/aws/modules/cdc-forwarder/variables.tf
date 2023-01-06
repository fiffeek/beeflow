variable "lambda_code_bucket_name" {
  type        = string
  description = "Name of the lambda code bucket."
}

variable "vpc_sg" {
  type        = string
  description = "The Id of the VPC security group to attach to the lambda."
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

variable "package_absolute_path" {
  type        = string
  description = "Absolute path to the CDC input forwarder lambda package."
}

variable "package_filename" {
  type        = string
  description = "Filename of the CDC input forwarder lambda package."
}

variable "beeflow_main_event_bus_name" {
  type        = string
  description = "The name of the main Beeflow event bus."
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy to."
}

variable "airflow_cloudwatch_logs_group_arn" {
  type        = string
  description = "The ARN for the Airflow logs in cloudwatch group"
}

variable "airflow_logs_bucket_arn" {
  type        = string
  description = "The ARN of the airflow logs bucket"
}

