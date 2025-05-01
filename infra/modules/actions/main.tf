resource "aws_ecr_repository" "chatbot_actions" {
  name                 = "${var.app_name}-actions"
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  tags = {
    Project = var.project
    Name    = "${var.app_name}-actions"
  }
}

resource "aws_cloudwatch_log_group" "actions_log_group" {
  name              = "/aws/ecs/${var.app_name}-actions/cluster"
  retention_in_days = 1
  skip_destroy      = false

  tags = {
    Project = var.project
    Name    = "${var.app_name}-actions"
  }
}

resource "aws_lb" "actions_lb" {
  name               = "${var.app_name}-actions-lb"
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

resource "aws_lb_target_group" "actions_tc" {
  name        = "${var.app_name}-actions-tc"
  port        = 5055
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/health"
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

resource "aws_lb_listener" "actions_listener_https" {
  load_balancer_arn = aws_lb.actions_lb.arn
  port              = 443
  protocol          = "TLS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.actions_tc.arn
  }

  tags = {
    Project = var.project
    Name    = var.app_name
  }
}

resource "aws_ecs_task_definition" "actions" {
  family                   = "${var.app_name}-actions"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-actions"
      image     = "${aws_ecr_repository.chatbot_actions.repository_url}:latest"
      command   = ["rasa", "run", "actions", "--actions", "actions"]
      essential = true
      portMappings = [
        {
          containerPort = 5055
          hostPort      = 5055
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.actions_log_group.name
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
          name  = "AWS_DEFAULT_REGION"
          value = var.aws_region
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
    Name    = "${var.app_name}-actions"
  }
}

resource "aws_ecs_service" "actions" {
  name                    = "${var.app_name}-actions"
  cluster                 = var.ecs_cluster_id
  task_definition         = aws_ecs_task_definition.actions.arn
  desired_count           = var.ecs_desired_count
  launch_type             = "FARGATE"
  enable_ecs_managed_tags = true

  network_configuration {
    subnets          = var.public_subnets
    security_groups  = [var.core_sg_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.actions_tc.arn
    container_name   = "${var.app_name}-actions"
    container_port   = 5055
  }

  tags = {
    Project = var.project
    Name    = "${var.app_name}-actions"
  }
}


resource "aws_route53_record" "www" {
  zone_id = var.route53_zone_id
  name    = "actions.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.actions_lb.dns_name
    zone_id                = aws_lb.actions_lb.zone_id
    evaluate_target_health = true
  }
}
