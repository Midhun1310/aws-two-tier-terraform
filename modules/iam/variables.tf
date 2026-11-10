variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the database credentials secret the instances may read."
  type        = string
}
