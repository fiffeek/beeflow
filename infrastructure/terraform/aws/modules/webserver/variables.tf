variable "vpc_sg" {
  type        = string
  description = "The Id of the VPC security group to attach to the AppRunner VPC connector."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs associated with the AppRunner VPC connector."
}

variable "port" {
  type = string
  description = "The webserver's port."
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

variable "airflow_cloudwatch_logs_group_arn" {
  type        = string
  description = "The ARN for the Airflow logs in cloudwatch group"
}
