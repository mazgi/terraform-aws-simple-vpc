# --------------------------------
# Security Groups
#
# naming: {ALLOW,DENY}-PROTOCOL-{FROM,TO}-LOCATION

resource "aws_security_group" "allow-any-from-vpc" {
  name   = "allow-any-from-vpc"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "${var.cidr_block_vpc}",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group" "allow-ssh-from-specific-ranges" {
  name   = "allow-ssh-from-specific-ranges"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["${var.cidr_blocks_allow_ssh}"]
  }
}

resource "aws_security_group" "allow-http-from-specific-ranges" {
  name   = "allow-http-from-specific-ranges"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["${var.cidr_blocks_allow_http}"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["${var.cidr_blocks_allow_http}"]
  }
}
