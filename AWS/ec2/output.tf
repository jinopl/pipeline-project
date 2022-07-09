output "private_key" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}

output "public_dns" {
  value = aws_instance.aws-pipeline.public_dns
}

output "public_ip" {
  value = aws_instance.aws-pipeline.public_ip
}