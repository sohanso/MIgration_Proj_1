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
  enable_nat_gateway      = true
  single_nat_gateway      = true
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

## VPC PEERING CONNECTION ##

resource "aws_vpc_peering_connection" "peering_mg" {
  peer_owner_id = var.peer_owner_id
  peer_vpc_id   = module.vpc-on-prem.vpc_id
  vpc_id        = module.vpc.vpc_id
  auto_accept   = true
  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "Main-peering"
    Project = "Migration-1"
  }
}
resource "aws_vpc_peering_connection_accepter" "peer_accept" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_mg.id
  auto_accept               = true
  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "Main-peering-accepter"
  }
}

data "aws_route_tables" "rts" {
  vpc_id = module.vpc.vpc_id
}

resource "aws_route" "r" {
  count                     = length(data.aws_route_tables.rts.ids)
  route_table_id            = tolist(data.aws_route_tables.rts.ids)[count.index]
  destination_cidr_block    = var.on-prem-vpc-cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_mg.id
}

data "aws_route_tables" "onprem_rts" {
  vpc_id = module.vpc-on-prem.vpc_id
}

resource "aws_route" "onprem_r" {
  count                     = length(data.aws_route_tables.onprem_rts.ids)
  route_table_id            = tolist(data.aws_route_tables.onprem_rts.ids)[count.index]
  destination_cidr_block    = var.cloud-vpc-cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_mg.id
}
