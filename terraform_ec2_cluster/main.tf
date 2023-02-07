terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}
provider "aws" {
  region = "eu-west-1"
}
variable "server_port" {
  type = object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)

  })

  default = {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_launch_configuration" "terraform_cluster" {
  image_id        = "ami-0b752bf1df193a6c4"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance_security_group.id]

  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y httpd 
systemctl start httpd
systemctl enable httpd
echo "<h1>hey guys $(hostname -f)</h1>" > /var/www/html/index.html

EOF
  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "ec2_cluster" {
  launch_configuration = aws_launch_configuration.terraform_cluster.name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids

  min_size = 2
  max_size = 5

  tag {
    key                 = "Name"
    value               = "terraform_asg_cluster"
    propagate_at_launch = true
  }
}
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}








resource "aws_security_group" "instance_security_group" {
  name        = "security_group_cluster"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = var.server_port.from_port
    to_port     = var.server_port.to_port
    protocol    = var.server_port.protocol
    cidr_blocks = var.server_port.cidr_blocks
  }
  egress {
    from_port   = var.server_port.from_port
    to_port     = var.server_port.to_port
    protocol    = var.server_port.protocol
    cidr_blocks = var.server_port.cidr_blocks

  }



}