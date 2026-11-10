output "alb_sg_id" {
  description = "Security group ID for the load balancer."
  value       = aws_security_group.alb.id
}

output "web_sg_id" {
  description = "Security group ID for the web tier."
  value       = aws_security_group.web.id
}

output "db_sg_id" {
  description = "Security group ID for the database."
  value       = aws_security_group.db.id
}
