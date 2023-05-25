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

# variable "mysql_root_password" {
#   description = "mysql root password"
# }