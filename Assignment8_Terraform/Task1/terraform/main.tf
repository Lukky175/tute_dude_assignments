resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "task1-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "task1-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "task1-igw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "task1-route-table"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "task1" {
  name        = "task1-security-group"
  description = "Security group for Task 1 Flask and Express application"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "task1-security-group"
  }
}

# Express frontend - port 3000
resource "aws_security_group_rule" "express_3000" {
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.task1.id
}

# Flask backend - port 5000
resource "aws_security_group_rule" "flask_5000" {
  type              = "ingress"
  from_port         = 5000
  to_port           = 5000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.task1.id
}

# SSH
resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.task1.id
}

# Allow all outbound traffic
resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.task1.id
}

resource "aws_instance" "Task1" {
  ami           = "ami-01a00762f46d584a1"
  instance_type = "t3.small"
  key_name = "Keypair-aws"
  count = 1

  subnet_id = aws_subnet.main.id

  vpc_security_group_ids = [
    aws_security_group.task1.id
  ]

  user_data = file("${path.module}/userdata.sh")

  tags = {
    Name = "Task1-Flask-Express"
  }
}