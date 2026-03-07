data "aws_iam_policy_document" "eb_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eb_instance_role" {
  name               = "${var.name_prefix}-eb-instance-role"
  assume_role_policy = data.aws_iam_policy_document.eb_assume_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eb_web_tier" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "eb_worker_tier" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

data "aws_iam_policy_document" "eb_secrets_policy" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.secret_arn]
  }
}

resource "aws_iam_role_policy" "eb_secrets_access" {
  name   = "${var.name_prefix}-eb-secrets-access"
  role   = aws_iam_role.eb_instance_role.id
  policy = data.aws_iam_policy_document.eb_secrets_policy.json
}

resource "aws_iam_instance_profile" "eb_instance_profile" {
  name = "${var.name_prefix}-eb-instance-profile"
  role = aws_iam_role.eb_instance_role.name

  tags = var.tags
}

resource "aws_elastic_beanstalk_application" "this" {
  name        = "${var.name_prefix}-tenant-service"
  description = "Tenant Service Elastic Beanstalk Application"

  tags = var.tags
}

data "aws_elastic_beanstalk_solution_stack" "corretto21" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux 2023 v[0-9.]+ running Corretto 21$"
}

resource "aws_elastic_beanstalk_environment" "this" {
  name                = "${var.name_prefix}-tenant-service-env"
  application         = aws_elastic_beanstalk_application.this.name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.corretto21.name

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = var.app_private_subnet_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = var.public_subnet_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "false"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_instance_profile.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = var.eb_security_group_id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SPRING_DATASOURCE_URL"
    value     = "jdbc:postgresql://${var.db_host}:5432/${var.db_name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_SECRET_ARN"
    value     = var.secret_arn
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_REGION"
    value     = var.aws_region
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SERVER_PORT"
    value     = "5000"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SPRING_SQL_INIT_MODE"
    value     = "never"
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SecurityGroups"
    value     = var.alb_security_group_id
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "5000"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "/tenants"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  tags = var.tags
}
