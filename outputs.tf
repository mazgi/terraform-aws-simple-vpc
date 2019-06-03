output "aws_vpc" {
  value = {
    main = aws_vpc.main,
  }
}

output "aws_nat_gateway" {
  value = {
    main = aws_nat_gateway.main,
  }
}

output "aws_subnet" {
  value = {
    public  = aws_subnet.public,
    private = aws_subnet.private,
  }
}

output "aws_security_group" {
  value = {
    allow-any-from-vpc              = aws_security_group.allow-any-from-vpc,
    allow-ssh-from-specific-ranges  = aws_security_group.allow-ssh-from-specific-ranges,
    allow-http-from-specific-ranges = aws_security_group.allow-http-from-specific-ranges,
  }
}
