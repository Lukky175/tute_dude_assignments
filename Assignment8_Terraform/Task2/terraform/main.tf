resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "task2-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "task2-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "task2-igw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "task2-route-table"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "task2_1" {
  name        = var.security_group_name_1
  description = "Security group for Task 2 Flask and Express application"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "1_task2-security-group"
  }
}

resource "aws_security_group" "task2_2" {
  name        = var.security_group_name_2
  description = "Security group for Task 2 Flask and Express application"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "2_task2-security-group"
  }
}

# Express frontend - port 3000
resource "aws_security_group_rule" "express_3000" {
  type              = "ingress"
  from_port         = var.express_port
  to_port           = var.express_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.task2_1.id
}

# Flask backend - port 5000
resource "aws_security_group_rule" "flask_5000" {
  type              = "ingress"
  from_port         = var.flask_port
  to_port           = var.flask_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.task2_2.id
}

# Allow Express EC2 to communicate with Flask EC2
resource "aws_security_group_rule" "flask_from_express" {

  type                     = "ingress"
  from_port                = var.flask_port
  to_port                  = var.flask_port
  protocol                 = "tcp"

  security_group_id        = aws_security_group.task2_2.id
  source_security_group_id = aws_security_group.task2_1.id
}

# SSH For 1st security group
resource "aws_security_group_rule" "ssh1" {
  type              = "ingress"
  from_port         = var.ssh_port
  to_port           = var.ssh_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.task2_1.id
}

# Allow all outbound traffic
resource "aws_security_group_rule" "egress1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.task2_1.id
}

# SSH For 1st security group
resource "aws_security_group_rule" "ssh2" {
  type              = "ingress"
  from_port         = var.ssh_port
  to_port           = var.ssh_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.task2_2.id
}

# Allow all outbound traffic
resource "aws_security_group_rule" "egress2" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.task2_2.id
}

resource "aws_instance" "Task2_Express" {
  ami           = var.ec2_ami_id
  instance_type = var.ec2_instance_type
  key_name      = var.key_pair_name
  count         = 1

  subnet_id = aws_subnet.main.id

  vpc_security_group_ids = [
    aws_security_group.task2_1.id
  ]

  user_data = file("${path.module}/userdata_express.sh")

  tags = {
    Name = "Task2-Express"
  }
}

resource "aws_instance" "Task2_Flask" {
  ami           = var.ec2_ami_id
  instance_type = var.ec2_instance_type
  key_name      = var.key_pair_name
  count         = 1

  subnet_id = aws_subnet.main.id

  vpc_security_group_ids = [
    aws_security_group.task2_2.id
  ]

  user_data = file("${path.module}/userdata_flask.sh")

  tags = {
    Name = "Task2-Flask"
  }
}