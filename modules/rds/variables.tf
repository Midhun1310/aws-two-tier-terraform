variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for the DB subnet group."
  type        = list(string)
}

variable "db_sg_id" {
  description = "Security group to attach to the database."
  type        = string
}

variable "db_name" {
  description = "Initial database name."
  type        = string
}

variable "db_username" {
  description = "Master username."
  type        = string
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "allocated_storage" {
  description = "Storage in GiB."
  type        = number
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment."
  type        = bool
}

variable "deletion_protection" {
  description = "Enable deletion protection. If true, a final snapshot is taken on destroy."
  type        = bool
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot when deleting the database."
  type        = bool
}

variable "backup_retention_days" {
  description = "Automated backup retention period in days."
  type        = number
}
