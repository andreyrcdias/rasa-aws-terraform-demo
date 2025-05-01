resource "aws_ecr_repository" "chatbot_api" {
  name                 = "${var.app_name}-api"
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  tags = {
    Project = var.project
    Name    = "${var.app_name}-api"
  }
}

resource "aws_s3_bucket" "chatbot_models" {
  bucket        = "${var.app_name}-models"
  force_destroy = true

  tags = {
    Project = var.project
    Name    = "${var.app_name}-models"
  }
}

resource "aws_cloudwatch_log_group" "api_log_group" {
  name              = "/aws/ecs/${var.app_name}-api/cluster"
  retention_in_days = 1
  skip_destroy      = false

  tags = {
    Project = var.project
    Name    = "${var.app_name}-api"
  }
}

resource "aws_lb" "api_lb" {
  name               = "${var.app_name}-api-lb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [var.core_sg_id]
  subnets            = var.public_subnets

  enable_deletion_protection = false
  idle_timeout               = 60

  tags = {
    Project = var.project
    Name    = var.app_name
  }
}

resource "aws_lb_target_group" "api_tc" {
  name        = "${var.app_name}-api-tc"
  port        = 5005
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    interval            = 60
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Project = var.project
    Name    = var.app_name
  }
}

# resource "aws_lb_listener" "api_listener" {
#   load_balancer_arn = aws_lb.api_lb.arn
#   port              = 80
#   protocol          = "TCP"
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.api_tc.arn
#   }
#
#   tags = {
#     Project = var.project
#     Name    = var.app_name
#   }
# }

resource "aws_lb_listener" "api_listener_https" {
  load_balancer_arn = aws_lb.api_lb.arn
  port              = 443
  protocol          = "TLS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tc.arn
  }

  tags = {
    Project = var.project
    Name    = var.app_name
  }
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.app_name}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-api"
      image     = "${aws_ecr_repository.chatbot_api.repository_url}:latest"
      command   = ["rasa", "run", "--endpoints", "endpoints.yml", "--credentials", "credentials.yml", "--remote-storage", "aws", "--enable-api", "--cors", "*"]
      essential = true
      portMappings = [
        {
          containerPort = 5005
          hostPort      = 5005
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.api_log_group.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      },
      environment = [
        {
          name  = "AWS_ACCESS_KEY_ID"
          value = var.aws_access_key_id
        },
        {
          name  = "AWS_SECRET_ACCESS_KEY"
          value = var.aws_secret_access_key
        },
        {
          name  = "BUCKET_NAME"
          value = aws_s3_bucket.chatbot_models.id
        },
        {
          name  = "AWS_DEFAULT_REGION"
          value = var.aws_region
        },
        {
          name  = "AWS_ENDPOINT_URL"
          value = "https://s3.${var.aws_region}.amazonaws.com"
        },
        {
          name  = "SQLALCHEMY_SILENCE_UBER_WARNING"
          value = "1"
        }
      ]
    }
  ])
  tags = {
    Project = var.project
    Name    = "${var.app_name}-api"
  }
}

resource "aws_ecs_service" "api" {
  name                    = "${var.app_name}-api"
  cluster                 = var.ecs_cluster_id
  task_definition         = aws_ecs_task_definition.api.arn
  desired_count           = var.ecs_desired_count
  launch_type             = "FARGATE"
  enable_ecs_managed_tags = true

  network_configuration {
    subnets          = var.public_subnets
    security_groups  = [var.core_sg_id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.api_tc.arn
    container_name   = "${var.app_name}-api"
    container_port   = 5005
  }
  tags = {
    Project = var.project
    Name    = "${var.app_name}-api"
  }
}

resource "aws_route53_record" "www" {
  zone_id = var.route53_zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.api_lb.dns_name
    zone_id                = aws_lb.api_lb.zone_id
    evaluate_target_health = true
  }
}

# # resource "aws_dynamodb_table" "chatbot_states" {
#   name         = var.app_name
#   billing_mode = "PAY_PER_REQUEST" # on-demand billing mode

#   attribute {
#     name = "id" # Primary key attribute name
#     type = "S"  # Attribute type (S = String, N = Number, B = Binary)
#   }

#   hash_key = "id" # Specify the primary key

#   tags = {
#     Project = var.project
#     Name = var.app_name
#   }
# }
