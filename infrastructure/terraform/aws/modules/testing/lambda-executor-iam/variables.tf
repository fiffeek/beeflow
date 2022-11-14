variable "metadata_dumps_bucket" {
  type = object({
    id  = string,
    arn = string
  })
  description = "The metadata dumps bucket"
}

variable "lambda_executor_role_name" {
  type        = string
  description = "The role name for the lambda executor"
}
