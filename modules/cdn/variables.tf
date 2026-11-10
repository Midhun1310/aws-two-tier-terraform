variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "domain_name" {
  description = "Domain to serve. Must match an existing public Route 53 hosted zone."
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the load balancer used as CloudFront origin."
  type        = string
}
