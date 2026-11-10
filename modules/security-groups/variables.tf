variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC in which to create the security groups."
  type        = string
}

variable "db_port" {
  description = "Database port."
  type        = number
  default     = 5432
}

variable "cloudfront_only" {
  description = "Restrict ALB ingress to the CloudFront origin-facing managed prefix list."
  type        = bool
  default     = false
}
