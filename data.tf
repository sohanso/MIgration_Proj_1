data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_route53_zone" "sohan-mglab" {
  name         = "sohan-mglab.aws.crlabs.cloud"
  private_zone = false
}

# data "aws_ami" "mg_ami" {
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["Amazon ECS Optimized Amazon Linux 2 AMI v2022-ca85e686-bca1-4f75-89a6-9e220891a969"]
#   }
#   owners = ["679593333241"]
# }
