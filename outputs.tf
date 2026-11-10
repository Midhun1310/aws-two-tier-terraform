output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "website_url" {
  description = "URL of the application."
  value       = var.enable_cdn ? "https://${var.domain_name}" : (var.alb_certificate_arn != "" ? "https://${module.alb.alb_dns_name}" : "http://${module.alb.alb_dns_name}")
}

output "db_endpoint" {
  description = "PostgreSQL endpoint (reachable only from the web tier)."
  value       = module.rds.db_endpoint
}

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the database credentials."
  value       = module.rds.db_secret_arn
}
