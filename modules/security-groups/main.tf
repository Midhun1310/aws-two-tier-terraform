# CloudFront origin-facing prefix list prevents direct ALB access from bypassing WAF.
data "aws_ec2_managed_prefix_list" "cloudfront_origin" {
  count = var.cloudfront_only ? 1 : 0
  name  = "com.amazonaws.global.cloudfront.origin-facing"
}

# ALB is public by default, or CloudFront-only when the CDN module is enabled.
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Allow public HTTP and HTTPS traffic to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from internet or CloudFront origin"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = var.cloudfront_only ? [] : ["0.0.0.0/0"]
    prefix_list_ids = var.cloudfront_only ? [data.aws_ec2_managed_prefix_list.cloudfront_origin[0].id] : []
  }

  ingress {
    description     = "HTTPS from CloudFront or the internet"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = var.cloudfront_only ? [] : ["0.0.0.0/0"]
    prefix_list_ids = var.cloudfront_only ? [data.aws_ec2_managed_prefix_list.cloudfront_origin[0].id] : []
  }

  egress {
    description = "Forward to web tier"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = { Name = "${var.name_prefix}-alb-sg" }
}

# Web tier: only reachable from the load balancer.
resource "aws_security_group" "web" {
  name        = "${var.name_prefix}-web-sg"
  description = "Allow HTTP from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "PostgreSQL to database tier"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "HTTPS for package updates and AWS APIs through NAT"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}-web-sg" }
}

# Database tier: only reachable from the web tier.
resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-db-sg"
  description = "Allow PostgreSQL from the web tier only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from web tier"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  tags = { Name = "${var.name_prefix}-db-sg" }
}
