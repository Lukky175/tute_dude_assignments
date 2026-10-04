variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_1" {
  description = "CIDR block for the first public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_cidr_2" {
  description = "CIDR block for the second public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone_1" {
  description = "First availability zone"
  type        = string
  default     = "ap-south-1a"
}

variable "availability_zone_2" {
  description = "Second availability zone"
  type        = string
  default     = "ap-south-1b"
}

variable "express_port" {
  description = "Port for the Express application"
  type        = number
  default     = 3000
}

variable "flask_port" {
  description = "Port for the Flask application"
  type        = number
  default     = 5000
}

variable "flask_ecr_repository_name" {
  description = "Flask ECR repository name"
  type        = string
  default     = "assignment8_terraform_task3_flask"
}

variable "express_ecr_repository_name" {
  description = "Express ECR repository name"
  type        = string
  default     = "assignment8_terraform_task3_express"
}