## CLOUD VPC/SUBNET ##

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = var.cloud-vpc-name
  cidr   = var.cloud-vpc-cidr

  azs                     = local.availability-zones
  private_subnets         = [for i, v in local.availability-zones : cidrsubnet(local.private_subnet_cidr, 2, i)]
  database_subnets        = [for i, v in local.availability-zones : cidrsubnet(local.database_subnet_cidr, 2, i)]
  public_subnets          = [for i, v in local.availability-zones : cidrsubnet(local.public_subnet_cidr, 2, i)]
  map_public_ip_on_launch = true
  enable_nat_gateway      = false
  single_nat_gateway      = false
  one_nat_gateway_per_az  = false

  tags = {
    Project = "Migration-1"
  }
}

## ON-PREM VPC/SUBNET - SIMULATING ON PREM INFRA##

module "vpc-on-prem" {
  source = "terraform-aws-modules/vpc/aws"
  name   = var.on-prem-vpc-name
  cidr   = var.on-prem-vpc-cidr

  azs                     = local.availability-zones-on-prem
  private_subnets         = [for i, v in local.availability-zones : cidrsubnet(local.private_subnet_cidr_onprem, 2, i)]
  database_subnets        = [for i, v in local.availability-zones : cidrsubnet(local.database_subnet_cidr_onprem, 2, i)]
  public_subnets          = [for i, v in local.availability-zones : cidrsubnet(local.public_subnet_cidr_onprem, 2, i)]
  map_public_ip_on_launch = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    Project = "Migration-1"
  }
}