resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = { Name = "${var.name_prefix}-db-subnet-group" }
}

resource "aws_db_parameter_group" "this" {
  name_prefix = "${var.name_prefix}-pg-"
  family      = "postgres16"
  description = "Slow-query logging for ${var.name_prefix}"
  parameter {
    name         = "log_min_duration_statement"
    value        = "1000"
    apply_method = "pending-reboot"
  }

  # Require encrypted client connections to PostgreSQL.
  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }
  lifecycle { create_before_destroy = true }
}

resource "aws_db_instance" "this" {

  identifier = "${var.name_prefix}-postgres"

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  # RDS generates the password and stores it in Secrets Manager,
  # so no credentials appear in code, variables or committed files.
  manage_master_user_password = true

  db_subnet_group_name                = aws_db_subnet_group.this.name
  vpc_security_group_ids              = [var.db_sg_id]
  publicly_accessible                 = false
  multi_az                            = var.multi_az
  iam_database_authentication_enabled = var.enable_iam_authentication
  performance_insights_enabled        = var.enable_performance_insights
  parameter_group_name                = aws_db_parameter_group.this.name
  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]

  backup_retention_period    = var.backup_retention_days
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name_prefix}-postgres-final"

  tags = { Name = "${var.name_prefix}-postgres" }
}
