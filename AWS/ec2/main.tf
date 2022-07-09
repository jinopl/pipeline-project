variable "key_name" {
    type = string
    default = "aws-pipeline"
}


resource "tls_private_key" "example" {
    algorithm = "RSA"
    rsa_bits  = 4096
  }

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.example.public_key_openssh
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
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
    EOF
  tags = {
    Name = "aws-pipeline"
  }
}

output "private_key" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}
