##############################
# Provider Configuration
##############################
provider "aws" {
  region = var.aws_region
}

##############################
# ECS Cluster
##############################
resource "aws_ecs_cluster" "college_cluster" {
  name = "college-website-cluster"
}

##############################
# IAM Roles
##############################
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

##############################
# Task Definition
##############################
resource "aws_ecs_task_definition" "college_task" {
  family                   = "college-website-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "college-website"
      image     = var.image_url
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

##############################
# ECS Service
##############################
resource "aws_ecs_service" "college_service" {
  name            = "college-website-service"
  cluster         = aws_ecs_cluster.college_cluster.id
  task_definition = aws_ecs_task_definition.college_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.college_task]
}
