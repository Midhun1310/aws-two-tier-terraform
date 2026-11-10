variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile for the instances."
  type        = string
}

variable "web_sg_id" {
  description = "Security group for the instances."
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnets in which to launch instances."
  type        = list(string)
}

variable "target_group_arn" {
  description = "Target group to register instances with."
  type        = string
}

variable "asg_min_size" {
  description = "Minimum number of instances."
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances."
  type        = number
}

variable "asg_desired_capacity" {
  description = "Initial number of instances."
  type        = number
}
