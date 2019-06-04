# --------------------------------
# AWS VPC configuration

module "multiple-volumes-aws-vpc" {
  #source = "mazgi/simple-vpc/aws"
  source = "../../"

  basename = "multiple-volumes"

  cidr_blocks_allow_ssh = [
    "192.0.2.0/24",              # Your specific IP address range
    var.current_external_ipaddr, # Get local machine external IP address via direnv and `curl ifconfig.io`
  ]
}

# --------------------------------
# Amazon EFS configuration

resource "aws_efs_file_system" "generalPurpose-bursting" {
  performance_mode = "generalPurpose" # default
  throughput_mode  = "bursting"       # default

  tags = {
    Name = "multiple-volumes-generalPurpose-bursting"
  }
}

resource "aws_efs_mount_target" "generalPurpose-bursting" {
  count = length(module.multiple-volumes-aws-vpc.aws_subnet.public)

  file_system_id = aws_efs_file_system.generalPurpose-bursting.id
  subnet_id      = module.multiple-volumes-aws-vpc.aws_subnet.public[count.index].id
  security_groups = [
    module.multiple-volumes-aws-vpc.aws_security_group.allow-any-from-vpc.id,
  ]
}

resource "aws_efs_file_system" "generalPurpose-provisioned" {
  performance_mode = "generalPurpose" # default
  throughput_mode  = "provisioned"
  # https://docs.aws.amazon.com/efs/latest/ug/performance.html#throughput-modes
  provisioned_throughput_in_mibps = 1024

  tags = {
    Name = "multiple-volumes-generalPurpose-provisioned"
  }
}

resource "aws_efs_mount_target" "generalPurpose-provisioned" {
  count = length(module.multiple-volumes-aws-vpc.aws_subnet.public)

  file_system_id = aws_efs_file_system.generalPurpose-provisioned.id
  subnet_id      = module.multiple-volumes-aws-vpc.aws_subnet.public[count.index].id
  security_groups = [
    module.multiple-volumes-aws-vpc.aws_security_group.allow-any-from-vpc.id,
  ]
}

resource "aws_efs_file_system" "maxIO-bursting" {
  performance_mode = "maxIO"
  throughput_mode  = "bursting" # default

  tags = {
    Name = "multiple-volumes-maxIO-bursting"
  }
}

resource "aws_efs_mount_target" "maxIO-bursting" {
  count = length(module.multiple-volumes-aws-vpc.aws_subnet.public)

  file_system_id = aws_efs_file_system.maxIO-bursting.id
  subnet_id      = module.multiple-volumes-aws-vpc.aws_subnet.public[count.index].id
  security_groups = [
    module.multiple-volumes-aws-vpc.aws_security_group.allow-any-from-vpc.id,
  ]
}

resource "aws_efs_file_system" "maxIO-provisioned" {
  performance_mode = "maxIO"
  throughput_mode  = "provisioned"
  # https://docs.aws.amazon.com/efs/latest/ug/performance.html#throughput-modes
  provisioned_throughput_in_mibps = 1024

  tags = {
    Name = "multiple-volumes-maxIO-provisioned"
  }
}

resource "aws_efs_mount_target" "maxIO-provisioned" {
  count = length(module.multiple-volumes-aws-vpc.aws_subnet.public)

  file_system_id = aws_efs_file_system.maxIO-provisioned.id
  subnet_id      = module.multiple-volumes-aws-vpc.aws_subnet.public[count.index].id
  security_groups = [
    module.multiple-volumes-aws-vpc.aws_security_group.allow-any-from-vpc.id,
  ]
}

# --------------------------------
# AWS EC2 instance configuration

data "aws_ami" "multiple-volumes-ami-ubuntu-18" {
  owners      = ["099720109477"] # 099720109477 = Canonical
  most_recent = true

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "multiple-volumes-operation-pubkey" {
  key_name   = "multiple-volumes-operation-pubkey"
  public_key = file(var.pubkey_file_path)
}

resource "aws_instance" "multiple-volumes-instance" {
  count = length(module.multiple-volumes-aws-vpc.aws_subnet.public)

  ami = data.aws_ami.multiple-volumes-ami-ubuntu-18.id
  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html?shortFooter=true#ec2-nitro-instances
  instance_type = "i3en.large"

  subnet_id = module.multiple-volumes-aws-vpc.aws_subnet.public[count.index].id

  vpc_security_group_ids = [
    module.multiple-volumes-aws-vpc.aws_security_group.allow-any-from-vpc.id,
    module.multiple-volumes-aws-vpc.aws_security_group.allow-ssh-from-specific-ranges.id,
  ]

  key_name = aws_key_pair.multiple-volumes-operation-pubkey.key_name

  # Example: set your public keys from GitHub
  #user_data = <<-EOF
  ##!/bin/bash -eu
  #mkdir -p /home/ubuntu/.ssh
  #curl -L github.com/mazgi.keys > /home/ubuntu/.ssh/authorized_keys2
  #EOF

  root_block_device {
    volume_size = 100
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = 100
  }

  ebs_block_device {
    device_name = "/dev/sdc"
    volume_type = "io1"
    # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html#EBSVolumeTypes_piops
    volume_size = 1280
    iops        = 64000
  }

  tags = {
    Name = format("multiple-volumes-instance-%02d", count.index + 1)
  }
}
