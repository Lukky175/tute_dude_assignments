output "express_public_ip" {
  description = "Public IP address of the Express EC2 instance"
  value       = aws_instance.Task2_Express[0].public_ip
}

output "flask_public_ip" {
  description = "Public IP address of the Flask EC2 instance"
  value       = aws_instance.Task2_Flask[0].public_ip
}