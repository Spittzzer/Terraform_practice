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
    from_port = number
    to_port = number
    protocol=string
    cidr_blocks = list
  })

  default = {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}



resource "aws_instance" "terraform" {
  ami           = "ami-0b752bf1df193a6c4"
  instance_type = "t2.micro"

  tags = {
    Name = "terraform_example"
  }
  user_data              = <<-EOF
#!/bin/bash
yum update -y
yum install -y httpd 
systemctl start httpd
systemctl enable httpd
echo "<h1>Sup y'all it's me billyyy </h1>" > /var/www/html/index.html

EOF
  vpc_security_group_ids = [aws_security_group.instance_security_group.id]
  # depends_on = [
  #     aws_security_group.httpd_security_group
  #   ]
  user_data_replace_on_change = true
}




resource "aws_security_group" "instance_security_group" {
  name        = "security_group_terraform"
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

output "public_ip"{
  value = aws_instance.terraform.public_ip
  description= "the public ip of the instance"
}
