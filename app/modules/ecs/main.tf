# ─── ECS Cluster ───
resource "aws_ecs_cluster" "this" {
  name = "${var.name_prefix}-cluster"
  tags = merge(var.tags, { Name = "${var.name_prefix}-cluster" })
}

# ─── Service Connect Namespace ───
# Creates a Cloud Map HTTP namespace so ECS services can reach each other
# via short DNS names (e.g. http://tenant-service:8080) entirely within
# the VPC, without going through the public ALB.
resource "aws_service_discovery_http_namespace" "this" {
  name = "${var.name_prefix}.local"
  tags = var.tags
}

# ─── CloudWatch Log Groups ───
resource "aws_cloudwatch_log_group" "tenant" {
  name              = "/ecs/${var.name_prefix}-tenant-service"
  retention_in_days = 7
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "room_search" {
  name              = "/ecs/${var.name_prefix}-room-search-service"
  retention_in_days = 7
  tags              = var.tags
}

# ─── ECS Task Execution Role (pulling images, writing logs, reading secrets) ───
data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.name_prefix}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_secrets_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [var.secret_arn]
  }
}

resource "aws_iam_role_policy" "ecs_secrets_access" {
  name   = "${var.name_prefix}-ecs-secrets-access"
  role   = aws_iam_role.ecs_task_execution.id
  policy = data.aws_iam_policy_document.ecs_secrets_policy.json
}

# ─── ECS Task Role (for application-level AWS API calls) ───
resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.name_prefix}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "ecs_task_secrets" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [var.secret_arn]
  }
}

resource "aws_iam_role_policy" "ecs_task_secrets" {
  name   = "${var.name_prefix}-ecs-task-secrets"
  role   = aws_iam_role.ecs_task_role.id
  policy = data.aws_iam_policy_document.ecs_task_secrets.json
}

# ─── Tenant Service Task Definition ───
resource "aws_ecs_task_definition" "tenant" {
  family                   = "${var.name_prefix}-tenant-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "tenant-service"
      image     = "${var.tenant_ecr_repo_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
          # Named port required for ECS Service Connect
          name          = "http"
        }
      ]

      environment = [
        { name = "DB_HOST", value = var.db_host },
        { name = "DB_PORT", value = tostring(var.db_port) },
        { name = "DB_NAME", value = var.db_name },
        { name = "SPRING_SQL_INIT_MODE", value = "never" }
      ]

      secrets = [
        {
          name      = "DB_USERNAME"
          valueFrom = "${var.secret_arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.secret_arn}:password::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.tenant.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = merge(var.tags, { Name = "${var.name_prefix}-tenant-service-task" })
}

# ─── Room Search Service Task Definition ───
resource "aws_ecs_task_definition" "room_search" {
  family                   = "${var.name_prefix}-room-search-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "room-search-service"
      image     = "${var.room_search_ecr_repo_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "TENANT_SERVICE_URL", value = "http://tenant-service:8080" },
        # REDIS DISABLED — uncomment when ElastiCache is re-enabled
        # { name = "REDIS_HOST",             value = var.redis_host },
        # { name = "REDIS_PORT",             value = tostring(var.redis_port) },
        # { name = "SPRING_DATA_REDIS_HOST", value = var.redis_host },
        # { name = "SPRING_DATA_REDIS_PORT", value = tostring(var.redis_port) }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.room_search.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = merge(var.tags, { Name = "${var.name_prefix}-room-search-service-task" })
}

# ─── Tenant Service ECS Service ───
resource "aws_ecs_service" "tenant" {
  name                               = "${var.name_prefix}-tenant-service"
  cluster                            = aws_ecs_cluster.this.id
  task_definition                    = aws_ecs_task_definition.tenant.arn
  desired_count                      = 1
  launch_type                        = "FARGATE"
  # Give Spring Boot 120 s to complete JVM startup before ALB health check
  # results can trigger a task replacement.
  health_check_grace_period_seconds  = 300

  lifecycle {
    ignore_changes = [task_definition]
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.tenant_target_group_arn
    container_name   = "tenant-service"
    container_port   = 8080
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = false
  }

  # Expose tenant-service to other services in the cluster under the
  # DNS name "tenant-service" on port 8080 via Service Connect.
  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.this.arn

    service {
      port_name      = "http"
      discovery_name = "tenant-service"

      client_alias {
        port     = 8080
        dns_name = "tenant-service"
      }
    }
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-tenant-service" })
}

# ─── Room Search Service ECS Service ───
resource "aws_ecs_service" "room_search" {
  name                               = "${var.name_prefix}-room-search-service"
  cluster                            = aws_ecs_cluster.this.id
  task_definition                    = aws_ecs_task_definition.room_search.arn
  desired_count                      = 1
  launch_type                        = "FARGATE"
  # Give Spring Boot 120 s to complete JVM startup before ALB health check
  # results can trigger a task replacement.
  health_check_grace_period_seconds  = 300

  lifecycle {
    ignore_changes = [task_definition]
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.room_search_target_group_arn
    container_name   = "room-search-service"
    container_port   = 8080
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = false
  }

  # Join the same Service Connect namespace as a client so it can reach
  # tenant-service at http://tenant-service:8080 inside the VPC.
  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.this.arn
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-room-search-service" })
}
