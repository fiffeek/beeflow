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

variable "airflow_logs_bucket_arn" {
  type        = string
  description = "The ARN of the airflow logs bucket"
}
