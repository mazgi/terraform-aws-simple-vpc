variable "basename" {
  type = string
}

variable "domain_names" {
  type = list(string)

  default = [
    "simple-vpc.internal",
  ]
}

variable "cidr_block_vpc" {
  type    = string
  default = "10.0.0.0/16"
}

variable "cidr_blocks_public_subnets" {
  type = map(string)

  default = {
    "10.0.0.0/24" = "a"
    "10.0.1.0/24" = "b"
  }
}

variable "cidr_blocks_private_subnets" {
  type = map(string)

  default = {
    "10.0.8.0/24" = "a"
    "10.0.9.0/24" = "b"
  }
}

variable "cidr_blocks_allow_ssh" {
  type = list(string)

  default = [
    "127.0.0.0/8", # disabled
  ]
}

variable "cidr_blocks_allow_http" {
  type = list(string)

  default = [
    "0.0.0.0/0",
  ]
}
