output "application_instance_id" {
  value = aws_instance.application.id
}

output "application_private_ip" {
  value = aws_instance.application.private_ip
}

output "application_public_ip" {
  value = aws_instance.application.public_ip
}

output "application_security_group_id" {
  value = aws_security_group.application_sg.id
}
