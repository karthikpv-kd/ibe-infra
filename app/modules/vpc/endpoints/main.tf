# ─── Endpoint Security Group ───────────────────────────────────────────────────
# Interface endpoints expose an ENI inside the VPC. ECS tasks reach AWS services
# by sending HTTPS (443) traffic to those ENIs. This SG allows that inbound
# traffic from any address within the VPC CIDR.
resource "aws_security_group" "endpoints" {
  name        = "${var.name_prefix}-endpoints-sg"
  description = "Allow HTTPS from within the VPC to interface endpoint ENIs"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-endpoints-sg" })
}

# ─── ECR API Interface Endpoint ────────────────────────────────────────────────
# ECS task execution calls ecr.api to obtain an authorization token
# (GetAuthorizationToken) before the Docker daemon can pull any image.
# Without this endpoint, the auth handshake times out in a private subnet.
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-ecr-api-endpoint" })
}

# ─── ECR DKR Interface Endpoint ───────────────────────────────────────────────
# After authentication, the Docker daemon uses the ecr.dkr endpoint to pull
# image manifests and layer metadata (Docker HTTP API v2 protocol).
# ecr.api and ecr.dkr serve different parts of the pull flow — both are required.
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-ecr-dkr-endpoint" })
}

# ─── S3 Gateway Endpoint ──────────────────────────────────────────────────────
# ECR stores actual image layer blobs (tarballs) in Amazon S3.
# Even with ecr.dkr in place, each docker pull streams layer data from S3.
# A gateway endpoint adds a route entry to the private route tables so that
# S3 traffic stays on the AWS backbone — no NAT or internet required.
# Gateway endpoints are free and do not require a security group.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids

  tags = merge(var.tags, { Name = "${var.name_prefix}-s3-endpoint" })
}

# ─── Secrets Manager Interface Endpoint ───────────────────────────────────────
# ECS task execution calls GetSecretValue before the container starts to inject
# DB_USERNAME and DB_PASSWORD as environment variables. Without this endpoint
# the call fails with a timeout and the task emits ResourceInitializationError.
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-secretsmanager-endpoint" })
}

# ─── CloudWatch Logs Interface Endpoint ───────────────────────────────────────
# The awslogs driver inside each container streams stdout/stderr to CloudWatch
# via the logs endpoint. Without it, log delivery fails silently and operators
# lose all visibility into container behaviour.
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-logs-endpoint" })
}
