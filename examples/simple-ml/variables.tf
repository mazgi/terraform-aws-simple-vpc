variable "aws_account_id" {
  type = "string"
}

variable "current_external_ipaddr" {
  type    = "string"
  default = "127.0.0.1/32" # Overwritten via direnv.
}

variable "pubkey_file_path" {
  type    = "string"
  default = "~/.ssh/id_rsa.pub"
}
