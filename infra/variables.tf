variable "region_aws" {
  type = string
}

variable "ssh_key" {
  type = string
}

variable "instance_size" {
  type = string
}

variable "instance_ami" {
  type = string
}

variable "security_group" {
  type = string
}

variable "group_name" {
  type = string
}

variable "group_max_size" {
  type = number
}

variable "group_min_size" {
  type = number
}

variable "is_prod" {
  type = bool
}