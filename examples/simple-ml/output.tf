output "aws_instance-simple-ml-instances" {
  value = {
    for instance in aws_instance.simple-ml-instance :
    instance.tags["Name"] => {
      "public_dns" = instance.public_dns,
      "public_ip"  = instance.public_ip,
    }
  }
}
