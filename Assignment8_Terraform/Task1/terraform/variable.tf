variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "security_group_name" {
  description = "Name of the security group"
  type        = string
  default     = "task1-security-group"
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

variable "ssh_port" {
  description = "Port for SSH access"
  type        = number
  default     = 22
}

variable "ec2_ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-01a00762f46d584a1"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_pair_name" {
  description = "Name of the key pair for SSH access"
  type        = string
  default     = "Keypair-aws"
}