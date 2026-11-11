variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "azs" {
  description = "Availability zones to use."
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2 && length(distinct(var.azs)) == length(var.azs)
    error_message = "At least two unique Availability Zones must be supplied."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets, one per AZ."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.azs)
    error_message = "Provide exactly one public subnet CIDR per Availability Zone."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets, one per AZ."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.azs)
    error_message = "Provide exactly one private subnet CIDR per Availability Zone."
  }
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway for all private subnets."
  type        = bool
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch."
  type        = bool
  default     = false
}
