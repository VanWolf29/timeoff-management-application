module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.4.0"

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.load_balancer_sg.id]

  http_tcp_listener_rules = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name             = "timeoff-tg"
      backend_protocol = "HTTP"
      backend_port     = 3000
      target_type      = "ip"
    }
  ]
}

resource "aws_ecs_cluster" "dev_cluster" {
  name = "dev-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.dev_cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "timeoff_management_task_definition" {
  family                   = "timeoff-management-td"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsoneconde([
    {
      name      = "timeoff",
      image     = "image",
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        {
          containerPort = 3000
        }
      ]
      linuxParameters = {
        initProcessEnabled = true
      }
    }
  ])
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "x86_64"
  }
}

resource "aws_ecs_service" "name" {
  name                   = "timeoff-service"
  cluster                = aws_ecs_cluster.dev_cluster.id
  task_definition        = aws_ecs_task_definition.timeoff_management_task_definition.arn
  desired_count          = 1
  enable_execute_command = true

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name   = "timeoff"
    container_port   = 3000
  }
}
