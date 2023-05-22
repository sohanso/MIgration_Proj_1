variable "cloud-vpc-cidr" {
  description = "Variable to declare VPC CIDR range"
  type        = string
  default     = "10.0.0.0/20"
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

