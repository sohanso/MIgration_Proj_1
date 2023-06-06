variable "cloud-vpc-cidr" {
  description = "Variable to declare VPC CIDR range"
  type        = string
}

variable "cloud-vpc-name" {
  description = " Name of cloud VPC"
  type        = string
}

variable "number-of-azs" {
  description = " Number of azs"
}

variable "on-prem-vpc-cidr" {
  description = " Variable to declare VPC CIDR range"
}
variable "open-to-public" {
  description = " open to public VPC CIDR range"
}

variable "on-prem-vpc-name" {
  description = " Name of cloud VPC"
  type        = string
}
variable "number-of-azs-on-prem" {
  description = " Number of azs"
}

variable "ami_id_for_asg" {
  description = "id of ami"
}
variable "ami_for_appserver" {
  description = "id of ami"
}
variable "ami_for_dbserver" {
  description = "id of ami"
}
variable "rds_engine" {
  description = "engine for rds"
}
variable "rds_engine_ver" {
  description = "version of rds engine"
}
variable "rds_name" {
  description = "name of rds "
}
variable "rds_username" {
  description = "user name of rds "
}
variable "rds_password" {
  description = "password name of rds "
}

variable "restore_to_point_in_time" {
  description = "nested block: NestingList, min items: 0, max items: 1"
  type = set(object(
    {
      restore_time                  = string
      source_db_instance_identifier = string
      source_dbi_resource_id        = string
      use_latest_restorable_time    = bool
    }
  ))
  default = []
}

variable "peer_owner_id" {
  description = "name of rds "
}
# variable "dms_private_ip" {
#   description = "name of rds "
# }