#VPC
variable "instance-tenancy" {
  default = ""
}

variable "vpc-name" {
  default = ""
}

variable "region" {
  default = ""
}

variable "ig-name" {
  default = ""
}

variable "map_pub_ip" {
  default = ""
}
variable "public-subnets-name" {
  default = ""
}

variable "public-subnet-routes-name" {
  default = ""
}

variable "nat_count" {
  default = ""
}

variable "eip-name" {
  default = ""
}

variable "nat-name" {
  default = ""
}

variable "private-route-cidr" {
  default = ""
}

variable "private-route-name" {
  default = ""
}

variable "vpc-cidr" {
  default = ""
}

variable "vpc-public-subnet-cidr" {
  type = "list"
}

variable "vpc-private-subnet-cidr" {
  type = "list"
}

variable "private-subnet-name" {
  default = ""
}

data "aws_availability_zones" "azs" {}