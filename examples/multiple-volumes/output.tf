output "aws_instance-multiple-volumes-instances" {
  value = {
    for instance in aws_instance.multiple-volumes-instance :
    instance.tags["Name"] => {
      "public_dns" = instance.public_dns,
      "public_ip"  = instance.public_ip,
      "subnet_id"  = instance.subnet_id,
    }
  }
}

output "aws_instance-multiple-volumes-efs-generalPurpose-bursting" {
  value = {
    for target in aws_efs_mount_target.generalPurpose-bursting :
    target.dns_name => target.subnet_id...
  }
}

output "aws_instance-multiple-volumes-efs-generalPurpose-provisioned" {
  value = {
    for target in aws_efs_mount_target.generalPurpose-provisioned :
    target.dns_name => target.subnet_id...
  }
}

output "aws_instance-multiple-volumes-efs-maxIO-bursting" {
  value = {
    for target in aws_efs_mount_target.maxIO-bursting :
    target.dns_name => target.subnet_id...
  }
}

output "aws_instance-multiple-volumes-efs-maxIO-provisioned" {
  value = {
    for target in aws_efs_mount_target.maxIO-provisioned :
    target.dns_name => target.subnet_id...
  }
}
