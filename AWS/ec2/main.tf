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
  user_data     = <<EOF
    #!/bin/bash -xe
    sudo apt update
    sudo apt upgrade -y
    sudo apt-get -qq -y install apache2
    sudo systemctl start apache2
    curl https://gist.githubusercontent.com/jinopl/48fff7865190b7cd0a86a8127a5d29bd/raw/1c3b21248733dfdc96ee3035233f143024a298bb/hostname.html > ~/index.html
    sudo mv ~/index.html /var/www/html/index.html
    EOF
  tags = {
    Name = "aws-pipeline"
  }
}
