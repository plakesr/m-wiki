variable "name" {
  default     = ""
}


variable "tags" {
  type        = string
  default     = ""
}


variable "public_key" {
  default = ""
}

variable "instance_count" {
  type        = number
  default     = 1
}

variable "ami" {
  type        = string
}

variable "instance_type" {
  type        = string
}

variable "key_name" {
  type        = string
  default     = ""
}

variable "vpc_security_group_ids" {
  type        = list(string)
}


variable "subnet_id" {
  type        = string
  default     = ""
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
}

variable "associate_public_ip_address" {
  type        = bool
  default     = false
}

variable "private_ip" {
  type        = string
  default     = ""
}

variable "public_ip" {
  type        = string
  default     = ""
}

variable "user_data" {
  type        = string
  default     = ""
}

variable "key_aws" {
  type        = string
  default     = "dev-deployer"
}


data "aws_availability_zones" "azs" {}

