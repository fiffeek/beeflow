variable "migrations_runner" {
  type        = string
  description = "Name of the migrations runner ECR repository."
}

variable "dag_parsing_processor" {
  type        = string
  description = "Name of the DAG parsing processor ECR repository."
}
