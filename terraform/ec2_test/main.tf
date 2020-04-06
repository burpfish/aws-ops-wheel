resource "aws_iam_instance_profile" "ec2_profile" {
  name = "profile"
  role = "${aws_iam_role.ec2_role.name}"
}

resource "aws_iam_role" "ec2_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_security_group" "allow_https" {
  name        = "allow_https"
  description = "Allow https outbound traffic"
  vpc_id      = "${var.vpc_config.vpc.id}"

  egress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// TODO: Delete - just for testing the private api
resource "aws_instance" "test" {
  ami                  = "ami-0ce21b51cb31a48b8"
  instance_type        = "t3.micro"
  subnet_id            = var.vpc_config.private_subnet.id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.id

  vpc_security_group_ids = [aws_security_group.allow_https.id]
  user_data              = <<SCRIPT
#!/bin/sh
echo ">>>>>>>>>>>>>>>>>>>>>>"
curl https://x7qbq9hav0.execute-api.us-west-2.amazonaws.com/app
echo "<<<<<<<<<<<<<<<<<<<<<<"
SCRIPT

  tags = {
    Name = "test private api (delete me)"
  }
}