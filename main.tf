provider "aws" {
  region     = "us-east-1"
}

resource "aws_s3_bucket" "phonedirectorybucket" {
  bucket = "phonedirectorybucket"
}

resource "aws_s3_bucket_object" "phone_directory_json" {
  bucket  = aws_s3_bucket.phonedirectorybucket.bucket
  key     = "phone_directory.json"
  content = "{}"
}

resource "aws_s3_bucket_policy" "public_bucket_policy" {
  bucket = aws_s3_bucket.phonedirectorybucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "arn:aws:s3:::phonedirectorybucket/*"
      }
    ]
  })
}


resource "aws_ecr_repository" "phoneappimage" {
  name = "phoneappimage"
}

resource "aws_ecs_cluster" "phoneapp_cluster" {
  name = "phoneapp-cluster"
}

resource "aws_ecs_task_definition" "phoneapp_task" {
  family                   = "phoneapp-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "phoneapp-container"
      image     = "016963197464.dkr.ecr.us-east-1.amazonaws.com/phoneappimage:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8501
          hostPort      = 8501
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "phoneapp_service" {
  name            = "phoneapp-service"
  cluster         = aws_ecs_cluster.phoneapp_cluster.id
  task_definition = aws_ecs_task_definition.phoneapp_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-07762df7584a820c5"]
    security_groups = [aws_security_group.phoneapp_sg.id]
  }
}

resource "aws_security_group" "phoneapp_sg" {
  name        = "phoneapp-sg"
  description = "Security group for phone app"
  vpc_id      = "vpc-0cf7450f4c2a0e58d"

  ingress {
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
