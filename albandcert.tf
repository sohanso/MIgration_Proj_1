
## A record ##
resource "aws_route53_record" "record_a" {
  zone_id = data.aws_route53_zone.sohan-mglab.zone_id
  name = "resolve-test"
  type    = "A"
  ttl     = "300"
  records = ["10.0.0.1"]
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

# resource "aws_lb_listener" "example" {

#   certificate_arn = aws_acm_certificate_validation.example.certificate_arn
# }

