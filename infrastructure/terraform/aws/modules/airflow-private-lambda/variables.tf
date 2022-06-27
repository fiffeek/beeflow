variable "is_lambda_packaged" {
  type        = bool
  description = "Determines whether the lambda is packaged or not. If it is, the spec is under `lambda_packaged_spec`"
}

variable "lambda_packaged_spec" {
  type = object({
    package_absolute_path       = string,
    package_filename            = string,
    lambda_code_bucket_name     = string,
    pants_lambda_entrypoint     = string,
    pants_lambda_python_version = string
  })
  default = {
    package_absolute_path       = null
    package_filename            = null
    lambda_code_bucket_name     = null
    pants_lambda_entrypoint     = null
    pants_lambda_python_version = null
  }
}

variable "is_lambda_dockerized" {
  type        = bool
  description = "Determines whether the lambda is dockerized or not. If it is, the spec is under `lambda_dockerized_spec`."
}

variable "lambda_dockerized_spec" {
  type = object({
    repository_url = string,
    image_tag      = string
  })
  default = {
    repository_url = null
    image_tag      = null
  }
}

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

variable "spec" {
  type = object({
    timeout : number,
    memory_size : number,
    reserved_concurrent_executions : number,
    additional_environment_variables : map(string)
  })
  description = "The lambda meta spec."
}
