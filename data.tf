data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_route53_zone" "sohan-mglab" {
  name         = "sohan-mglab.aws.crlabs.cloud"
  private_zone = false
}