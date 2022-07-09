locals {
   ports = [
    {
      port        = 80
      description = "port for http traffic"
   },
   {
      port        = 443
      description = "Port for https traffic"
   },
   {
      port        = 22
      description = "port for ssh"
   }
   ]
}


resource "aws_security_group" "aws-pipeline-ingress-sg" {
  name        = "aws-pipeline-ingres-sg"
  description = "Ingress for aws-pipeline"

    dynamic ingress {
        for_each = local.ports
        iterator = port

        content {
         description = port.value.description
         from_port   = port.value.port
         to_port     = port.value.port
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
        }
    }
    tags = {
      Name = "aws-pipeline-ingres-sg"
   }
}
resource "aws_security_group" "aws-pipeline-egress-sg" {
  name        = "aws-pipeline-egress-sg"
  description = "egress for aws-pipeline"

    dynamic egress {
        for_each = local.ports
        iterator = port

        content {
         description = port.value.description
         from_port   = port.value.port
         to_port     = port.value.port
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
        }
    }
    tags = {
      Name = "aws-pipeline-egress-sg"
   }
}
