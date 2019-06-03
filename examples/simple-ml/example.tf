# --------------------------------
# AWS VPC configuration

module "simple-ml-aws-vpc" {
  #source = "mazgi/simple-vpc/aws"
  source = "../../"

  basename = "simple-ml"

  cidr_blocks_allow_ssh = [
    "192.0.2.0/24",              # Your specific IP address range
    var.current_external_ipaddr, # Get local machine external IP address via direnv and `curl ifconfig.io`
  ]
}

# --------------------------------
# Addtional security groups for Jupyter Notebook

resource "aws_security_group" "allow-jupyternotebook-from-specific-ranges" {
  name   = "allow-jupyternotebook-from-specific-ranges"
  vpc_id = module.simple-ml-aws-vpc.aws_vpc.main.id

  ingress {
    from_port = 8888
    to_port   = 8888
    protocol  = "tcp"

    cidr_blocks = [
      "192.0.2.0/24",              # Your specific IP address range
      var.current_external_ipaddr, # Get local machine external IP address via direnv and `curl ifconfig.io`
    ]
  }
}

# --------------------------------
# AWS EC2 instance configuration

data "aws_ami" "simple-ml-ami-dl-ubuntu" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name = "name"

    values = [
      "Deep Learning AMI (Ubuntu) *",
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "simple-ml-operation-pubkey" {
  key_name   = "simple-ml-operation-pubkey"
  public_key = file(var.pubkey_file_path)
}

resource "aws_instance" "simple-ml-gpu-instance-1" {
  ami           = data.aws_ami.simple-ml-ami-dl-ubuntu.id
  instance_type = "p3.2xlarge"

  subnet_id = module.simple-ml-aws-vpc.aws_subnet.public[1].id

  vpc_security_group_ids = [
    module.simple-ml-aws-vpc.aws_security_group.allow-any-from-vpc.id,
    module.simple-ml-aws-vpc.aws_security_group.allow-ssh-from-specific-ranges.id,
    aws_security_group.allow-jupyternotebook-from-specific-ranges.id,
  ]

  root_block_device {
    volume_size = "250"
  }

  key_name = aws_key_pair.simple-ml-operation-pubkey.key_name

  # Example: set your public keys from GitHub
  #user_data = <<-EOF
  ##!/bin/bash -eu
  #mkdir -p /home/ubuntu/.ssh
  #curl -L github.com/mazgi.keys > /home/ubuntu/.ssh/authorized_keys2
  #EOF

  tags = {
    Name = "simple-ml-gpu-instance-1"
  }
}
