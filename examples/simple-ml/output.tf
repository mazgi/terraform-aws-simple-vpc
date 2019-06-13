output "aws_instance-simple-ml-gpu-instance" {
  value = {
    "public_dns" = aws_instance.simple-ml-gpu-instance.public_dns,
    "public_ip"  = aws_instance.simple-ml-gpu-instance.public_ip,
  }
}
