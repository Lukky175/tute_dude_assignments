resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "task3-vpc"
  }
}

# ============================================================
# PUBLIC SUBNETS
# ============================================================

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_1
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true

  tags = {
    Name = "task3-public-subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_2
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = "task3-public-subnet-2"
  }
}

# ============================================================
# INTERNET GATEWAY
# ============================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "task3-igw"
  }
}


# ============================================================
# ROUTE TABLE
# ============================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "task3-public-route-table"
  }
}


resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}


# ============================================================
# ECR REPOSITORIES
# ============================================================

resource "aws_ecr_repository" "flask" {
  name = var.flask_ecr_repository_name

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "task3-flask-ecr"
  }
}

resource "aws_ecr_repository" "express" {
  name = var.express_ecr_repository_name

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "task3-express-ecr"
  }
}


# ============================================================
# SECURITY GROUP - ALB
# ============================================================

resource "aws_security_group" "alb" {
  name        = "task3-alb-security-group"
  description = "Security group for Task 3 Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "task3-alb-security-group"
  }
}


# ALB -> Express
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}


# ALB -> Flask
resource "aws_vpc_security_group_ingress_rule" "alb_flask" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = var.flask_port
  to_port     = var.flask_port
  ip_protocol = "tcp"
}


resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


# ============================================================
# SECURITY GROUP - EXPRESS ECS
# ============================================================

resource "aws_security_group" "express" {
  name        = "task3-express-security-group"
  description = "Security group for Express ECS service"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "task3-express-security-group"
  }
}


# Only ALB can access Express on port 3000
resource "aws_vpc_security_group_ingress_rule" "express_from_alb" {
  security_group_id = aws_security_group.express.id

  referenced_security_group_id = aws_security_group.alb.id

  from_port   = var.express_port
  to_port     = var.express_port
  ip_protocol = "tcp"
}


resource "aws_vpc_security_group_egress_rule" "express_all" {
  security_group_id = aws_security_group.express.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


# ============================================================
# SECURITY GROUP - FLASK ECS
# ============================================================

resource "aws_security_group" "flask" {
  name        = "task3-flask-security-group"
  description = "Security group for Flask ECS service"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "task3-flask-security-group"
  }
}


# Only ALB can access Flask on port 5000
resource "aws_vpc_security_group_ingress_rule" "flask_from_alb" {
  security_group_id = aws_security_group.flask.id

  referenced_security_group_id = aws_security_group.alb.id

  from_port   = var.flask_port
  to_port     = var.flask_port
  ip_protocol = "tcp"
}


resource "aws_vpc_security_group_egress_rule" "flask_all" {
  security_group_id = aws_security_group.flask.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


# ============================================================
# EXISTING ECS TASK EXECUTION ROLE
# ============================================================

data "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"
}


# ============================================================
# CLOUDWATCH LOG GROUPS
# ============================================================

resource "aws_cloudwatch_log_group" "flask" {
  name              = "/ecs/task3-flask"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "express" {
  name              = "/ecs/task3-express"
  retention_in_days = 7
}


# ============================================================
# ECS CLUSTER
# ============================================================

resource "aws_ecs_cluster" "main" {
  name = "task3-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "task3-ecs-cluster"
  }
}


# ============================================================
# APPLICATION LOAD BALANCER
# ============================================================

resource "aws_lb" "main" {
  name               = "task3-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  tags = {
    Name = "task3-alb"
  }
}


# ============================================================
# EXPRESS TARGET GROUP
# ============================================================

resource "aws_lb_target_group" "express" {
  name        = "task3-express-tg"
  port        = var.express_port
  protocol    = "HTTP"
  target_type = "ip"

  vpc_id = aws_vpc.main.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "task3-express-target-group"
  }
}


# ============================================================
# FLASK TARGET GROUP
# ============================================================

resource "aws_lb_target_group" "flask" {
  name        = "task3-flask-tg"
  port        = var.flask_port
  protocol    = "HTTP"
  target_type = "ip"

  vpc_id = aws_vpc.main.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "task3-flask-target-group"
  }
}


# ============================================================
# ALB LISTENER - EXPRESS
# ============================================================

resource "aws_lb_listener" "express" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.express.arn
  }
}


# ============================================================
# ALB LISTENER - FLASK
# ============================================================

resource "aws_lb_listener" "flask" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.flask_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask.arn
  }
}


# ============================================================
# FLASK ECS TASK DEFINITION
# ============================================================

resource "aws_ecs_task_definition" "flask" {
  family                   = "task3-flask"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = data.aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "flask"
      image     = "${aws_ecr_repository.flask.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = var.flask_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.flask.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "flask"
        }
      }
    }
  ])

  tags = {
    Name = "task3-flask-task"
  }
}


# ============================================================
# EXPRESS ECS TASK DEFINITION
# ============================================================

resource "aws_ecs_task_definition" "express" {
  family                   = "task3-express"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = data.aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "express"
      image     = "${aws_ecr_repository.express.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = var.express_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "BACKEND_URL"
          value = "http://${aws_lb.main.dns_name}:${var.flask_port}"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.express.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "express"
        }
      }
    }
  ])

  tags = {
    Name = "task3-express-task"
  }
}


# ============================================================
# FLASK ECS SERVICE
# ============================================================

resource "aws_ecs_service" "flask" {
  name            = "task3-flask-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.flask.arn

  desired_count = 1
  launch_type   = "FARGATE"

  health_check_grace_period_seconds = 60

  network_configuration {
    subnets = [
      aws_subnet.public_1.id,
      aws_subnet.public_2.id
    ]

    security_groups = [
      aws_security_group.flask.id
    ]

    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.flask.arn
    container_name   = "flask"
    container_port   = var.flask_port
  }

  depends_on = [
    aws_lb_listener.flask
  ]

  tags = {
    Name = "task3-flask-service"
  }
}


# ============================================================
# EXPRESS ECS SERVICE
# ============================================================

resource "aws_ecs_service" "express" {
  name            = "task3-express-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.express.arn

  desired_count = 1
  launch_type   = "FARGATE"

  health_check_grace_period_seconds = 60

  network_configuration {
    subnets = [
      aws_subnet.public_1.id,
      aws_subnet.public_2.id
    ]

    security_groups = [
      aws_security_group.express.id
    ]

    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.express.arn
    container_name   = "express"
    container_port   = var.express_port
  }

  depends_on = [
    aws_lb_listener.express
  ]

  tags = {
    Name = "task3-express-service"
  }
}