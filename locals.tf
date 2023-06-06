locals {
  availability-zones          = slice(data.aws_availability_zones.available.names, 0, var.number-of-azs)
  public_subnet_cidr          = cidrsubnet(var.cloud-vpc-cidr, 4, 0)
  private_subnet_cidr         = cidrsubnet(var.cloud-vpc-cidr, 3, 1)
  database_subnet_cidr        = cidrsubnet(var.cloud-vpc-cidr, 5, 2)
  availability-zones-on-prem  = slice(data.aws_availability_zones.available.names, 0, var.number-of-azs-on-prem)
  public_subnet_cidr_onprem   = cidrsubnet(var.on-prem-vpc-cidr, 4, 0)
  private_subnet_cidr_onprem  = cidrsubnet(var.on-prem-vpc-cidr, 3, 1)
  database_subnet_cidr_onprem = cidrsubnet(var.on-prem-vpc-cidr, 5, 2)
  region                      = "eu-central-1"
  mysql_root_password         = "Admin@1234"
  db_subnet_group_name = "cloud-vpc"
  dms_private_ip = "10.0.1.13"

}
