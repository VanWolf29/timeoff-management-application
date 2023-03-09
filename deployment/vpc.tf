data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws//examples/complete-vpc"
  version = "3.19.0"

  name = "dev-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  public_subnets  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24", "10.0.14.0/24", "10.0.15.0/24", "10.0.16.0/24"]

  default_security_group_tags = { Name = "dev-vpc-default-sg" }

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true
}

resource "aws_security_group" "load_balancer_sg" {
  name        = "load-balancer-sg"
  description = "Allow HTTP(S) access from internet"
  vpc_id      = module.vpc.vpc_id

  ingress = {
    description = "HTTP Access only"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Application = "timeoff-management"
    Name        = "load-balancer-sg"
  }
}

resource "aws_security_group_rule" "load_balancer_sg_https" {
  type              = ingress
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.load_balancer_sg.id
}

resource "aws_security_group" "ecs_service_sg" {
  name        = "ecs-service-sg"
  description = "Allow balancer into container"
  vpc_id      = module.vpc.vpc_id

  ingress = {
    description       = "LB access only"
    from_port         = 3000
    to_port           = 3000
    protocol          = "tcp"
    security_group_id = aws_security_group.load_balancer_sg.id
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Application = "timeoff-management"
    Name        = "ecs-service-sg"
  }
}
