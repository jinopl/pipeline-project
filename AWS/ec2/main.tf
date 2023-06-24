terraform {
      backend "remote" {
        organization = "jinopl"
        workspaces {
          name = "aws-pipeline"
        }
      }
    }

provider "aws" {
  region = "us-east-1"
}

resource "tls_private_key" "example" {
    algorithm = "RSA"
    rsa_bits  = 4096
  }

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.example.public_key_openssh
}

resource "aws_instance" "aws-pipeline" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.aws-pipeline-ingress-sg.id , aws_security_group.aws-pipeline-egress-sg.id]
  user_data = << EOF
		#! /bin/bash
    sudo apt-get update
		sudo apt-get install -y apache2
		sudo systemctl start apache2
		sudo systemctl enable apache2
		echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
	EOF
  tags = {
    Name = "aws-pipeline"
  }
}
