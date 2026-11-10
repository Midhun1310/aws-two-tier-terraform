output "db_endpoint" {
  description = "Database connection endpoint (host:port)."
  value       = aws_db_instance.this.endpoint
}

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret with the master credentials."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
