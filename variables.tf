# ---------- General ----------
variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name, used as a prefix for resource names and tags."
  type        = string
  default     = "two-tier"
}

variable "environment" {
  description = "Environment name (for example dev, staging, prod)."
  type        = string
  default     = "dev"
}

# ---------- Network ----------
variable "availability_zones" {
  description = "Explicit AZ names for stable subnet placement; verify these names in your AWS account."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
  validation {
    condition     = length(var.availability_zones) >= 2 && length(distinct(var.availability_zones)) == length(var.availability_zones)
    error_message = "Provide at least two unique Availability Zones."
  }
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch; incurs log ingestion/storage charges."
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets (one per availability zone)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets (one per availability zone)."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway (cheaper) instead of one per AZ (highly available)."
  type        = bool
  default     = true
}

# ---------- Web tier ----------
variable "instance_type" {
  description = "EC2 instance type for the web tier."
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Minimum number of web instances."
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of web instances."
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Initial number of web instances."
  type        = number
  default     = 2
}

# ---------- Database tier ----------
variable "db_name" {
  description = "Name of the initial PostgreSQL database."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for the database. The password is generated and stored in AWS Secrets Manager."
  type        = string
  default     = "dbadmin"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the database in GiB."
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "16"
}

variable "db_multi_az" {
  description = "Deploy the database across two availability zones for failover."
  type        = bool
  default     = false
}

variable "db_deletion_protection" {
  description = "Protect the database from accidental deletion."
  type        = bool
  default     = true
}

variable "db_skip_final_snapshot" {
  description = "Skip the final RDS snapshot on destroy. Keep false except for disposable environments."
  type        = bool
  default     = false
}

variable "db_backup_retention_period" {
  description = "Automated RDS backup retention in days (0-35)."
  type        = number
  default     = 7
  validation {
    condition     = var.db_backup_retention_period >= 0 && var.db_backup_retention_period <= 35
    error_message = "RDS backup retention must be between 0 and 35 days."
  }
}

variable "alb_certificate_arn" {
  description = "ACM certificate ARN in the deployment region. Required for production HTTPS."
  type        = string
  default     = ""
  validation {
    condition     = var.environment != "prod" || var.enable_cdn || length(var.alb_certificate_arn) > 0
    error_message = "Production requires alb_certificate_arn so the ALB can serve HTTPS and redirect HTTP."
  }
}

variable "alb_deletion_protection" {
  description = "Enable deletion protection for the internet-facing ALB."
  type        = bool
  default     = true
}

variable "enable_performance_insights" {
  description = "Enable RDS Performance Insights; check instance-class pricing and availability."
  type        = bool
  default     = false
}

variable "enable_db_iam_authentication" {
  description = "Enable IAM DB authentication; application must generate RDS auth tokens."
  type        = bool
  default     = false
}

# ---------- CDN / DNS (optional) ----------
variable "enable_cdn" {
  description = "Create CloudFront, WAF, ACM certificate and Route 53 records. Requires an existing public hosted zone."
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain served through CloudFront. Must match an existing Route 53 public hosted zone. Required when enable_cdn is true."
  type        = string
  default     = ""

  validation {
    condition     = var.enable_cdn == false || length(var.domain_name) > 0
    error_message = "domain_name must be set when enable_cdn is true."
  }
}
