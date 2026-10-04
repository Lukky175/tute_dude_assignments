output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "application_url" {
  description = "Express application URL"
  value       = "http://${aws_lb.main.dns_name}"
}

output "flask_url" {
  description = "Flask backend URL through ALB"
  value       = "http://${aws_lb.main.dns_name}:5000"
}

output "flask_ecr_repository_url" {
  description = "Flask ECR repository URL"
  value       = aws_ecr_repository.flask.repository_url
}

output "express_ecr_repository_url" {
  description = "Express ECR repository URL"
  value       = aws_ecr_repository.express.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "express_service_name" {
  description = "Express ECS service"
  value       = aws_ecs_service.express.name
}

output "flask_service_name" {
  description = "Flask ECS service"
  value       = aws_ecs_service.flask.name
}