#checkov:skip=CKV2_AWS_28:CloudFront WAF is used when CDN is enabled. With CDN disabled, deploy a regional WAF before production exposure.
resource "aws_lb" "this" {
  name                       = "${var.name_prefix}-alb"
  load_balancer_type         = "application"
  internal                   = false
  subnets                    = var.public_subnet_ids
  security_groups            = [var.alb_sg_id]
  drop_invalid_header_fields = true
  enable_deletion_protection = var.deletion_protection
  idle_timeout               = 60

  depends_on = [aws_s3_bucket_policy.alb_logs]
  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    enabled = true
  }
  tags = { Name = "${var.name_prefix}-alb" }
}

resource "aws_s3_bucket" "alb_logs" {
  bucket_prefix = "${replace(var.name_prefix, "_", "-")}-alb-logs-"
  force_destroy = false
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket                  = aws_s3_bucket.alb_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    id     = "expire-alb-access-logs-after-90-days"
    status = "Enabled"
    expiration { days = 90 }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

data "aws_elb_service_account" "this" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "alb_logs" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.alb_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.this.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = data.aws_iam_policy_document.alb_logs.json
}

#checkov:skip=CKV_AWS_378:ALB-to-instance traffic stays inside the VPC and is restricted by the web-tier security group; TLS termination is at the ALB.
resource "aws_lb_target_group" "web" {
  name        = "${var.name_prefix}-web-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  deregistration_delay = 30

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    interval            = 20
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = { Name = "${var.name_prefix}-web-tg" }
}

# Without a certificate, HTTP is used for a low-cost demo. Supply an ACM
# certificate ARN to enable TLS termination and automatic HTTP redirection.
#checkov:skip=CKV_AWS_2:HTTP forwarding is used for the CloudFront-to-ALB origin hop when CDN is enabled; production without CDN must provide an ALB certificate.
#checkov:skip=CKV_AWS_103:TLS 1.2+ is configured on the HTTPS listener when direct ALB HTTPS is used; CloudFront terminates viewer TLS when CDN is enabled.
#checkov:skip=CKV2_AWS_20:Direct-ALB production uses the redirect listener; CloudFront production uses its HTTPS viewer policy and a restricted HTTP origin hop.
resource "aws_lb_listener" "http_forward" {
  count             = var.certificate_arn == "" ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  count             = var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  count             = var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
