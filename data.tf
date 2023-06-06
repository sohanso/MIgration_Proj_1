data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_route53_zone" "sohan-mglab" {
  name         = "sohan-mglab.aws.crlabs.cloud"
  private_zone = false
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_subnet" "public_subnet_1" {
  filter {
    name   = "tag:Name"
    values = ["on-prem-vpc-public-eu-central-1a"]
  }
}

data "aws_subnet" "private_subnet_1" {
  filter {
    name   = "tag:Name"
    values = ["on-prem-vpc-private-eu-central-1a"]
  }
}
data "aws_subnet" "db_subnet_1" {
  filter {
    name   = "tag:Name"
    values = ["cloud-vpc-db-eu-central-1a"]
  }
}

data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}


