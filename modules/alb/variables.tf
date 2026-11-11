variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets for the load balancer."
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security group for the load balancer."
  type        = string
}

variable "certificate_arn" {
  description = "Optional ACM certificate ARN for HTTPS listener."
  type        = string
  default     = ""
}

variable "deletion_protection" {
  description = "Enable ALB deletion protection."
  type        = bool
  default     = true
}
