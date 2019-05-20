output "aws_vpc.main" {
  value = "${map(
    "id", aws_vpc.main.id,
    "arn", aws_vpc.main.arn,
  )}"
}

output "aws_nat_gateway.main" {
  value = "${
    zipmap(aws_nat_gateway.main.*.public_ip, aws_nat_gateway.main.*.subnet_id)
  }"
}

output "aws_subnet.public.*.cidr_block" {
  value = "${
    zipmap(aws_subnet.public.*.cidr_block, aws_subnet.public.*.id)
  }"
}

output "aws_subnet.private.*.cidr_block" {
  value = "${
    zipmap(aws_subnet.private.*.cidr_block, aws_subnet.private.*.id)
  }"
}

output "aws_security_group.allow-any-from-vpc.id" {
  value = "${aws_security_group.allow-any-from-vpc.id}"
}

output "aws_security_group.allow-ssh-from-specific-ranges.id" {
  value = "${aws_security_group.allow-ssh-from-specific-ranges.id}"
}

output "aws_security_group.allow-http-from-specific-ranges.id" {
  value = "${aws_security_group.allow-http-from-specific-ranges.id}"
}
