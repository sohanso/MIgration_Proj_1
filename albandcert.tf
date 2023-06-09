
# A record ##
resource "aws_route53_record" "record_a" {
  zone_id = data.aws_route53_zone.sohan-mglab.zone_id
  name    = ""
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

## TLS CERTIFICATE ##       
resource "aws_acm_certificate" "mglab-cert" {
  domain_name       = "sohan-mglab.aws.crlabs.cloud"
  validation_method = "DNS"
  tags = {
    Project = "Migration-1"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "record_cert" {
  for_each = {
    for dvo in aws_acm_certificate.mglab-cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.sohan-mglab.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.mglab-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.record_cert : record.fqdn]
}


## ALB Security Group ##
resource "aws_security_group" "alb_sg" {
  name        = "app-load-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.open-to-public]
  }
  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.open-to-public, var.on-prem-vpc-cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "Migration-1"
  }
}

## PgAdmin Security Group ##
resource "aws_security_group" "pgadmin_sg" {
  name        = "pgadmin_server_sg"
  description = "Allow ALB inbound traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "ALB connection from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # cidr_blocks      = ["10.0.0.0/20"]
    security_groups = [aws_security_group.alb_sg.id]
  }
  ingress {
    description = "ssh connection"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cloud-vpc-cidr, var.on-prem-vpc-cidr]
  }
  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cloud-vpc-cidr, var.on-prem-vpc-cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Project = "Migration-1"
  }
}


# APPLICATION LOAD BALANCER ##
resource "aws_lb" "alb" {
  name               = "mg-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets
  # access_logs {
  #   bucket  = "migration-1-tfstate"
  #   prefix  = "alb-logs"
  #   enabled = true
  # }

  tags = {
    Project = "Migration-1"
  }
}

TARGET GROUP AND LISTENER ##

resource "aws_lb_target_group" "alb_tg" {
  name     = "targetgroup-of-alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    enabled             = true
    healthy_threshold   = 5
    unhealthy_threshold = 2
    interval            = 30
    path                = "/"
    port                = 80
    protocol            = "HTTP"
  }
}


resource "aws_lb_listener" "listener_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.mglab-cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
  #   default_action {
  #     type = "fixed-response"

  #     fixed_response {
  #       content_type = "text/plain"
  #       message_body = "Fixed response content"
  #       status_code  = "200"
  #     }
}


resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      status_code = "HTTP_301"
      port        = "443"
      protocol    = "HTTPS"
    }
  }
}

resource "aws_lb_listener_certificate" "alb_listener_cert" {
  listener_arn    = aws_lb_listener.listener_https.arn
  certificate_arn = aws_acm_certificate.mglab-cert.arn
}


## BastionHost Security Group ##
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_public server_sg"
  description = "Allow bastion inbound traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "ssh connection"
    from_port   = 20
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.open-to-public, var.on-prem-vpc-cidr, var.cloud-vpc-cidr ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Project = "Migration-1"
  }
}

