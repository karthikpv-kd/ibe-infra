resource "aws_security_group" "email_lambda_sg" {
  name        = "${var.name_prefix}-email-lambda-sg"
  description = "Security group for booking email sender Lambda"
  vpc_id      = var.vpc_id

  egress {
    description = "HTTPS to VPC endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-email-lambda-sg"
  })
}

resource "aws_security_group" "vpc_endpoints_sg" {
  name        = "${var.name_prefix}-vpc-endpoints-sg"
  description = "Security group for SQS and SES VPC interface endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTPS from email Lambda"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.email_lambda_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-endpoints-sg"
  })
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.sqs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sqs-endpoint"
  })
}

# ─── VPC Endpoint: SES API ───
# Uses the SES API endpoint (not SMTP).
# boto3 SES client uses HTTPS API — service name is "email" not "email-smtp".
# private_dns_enabled = true means email.{region}.amazonaws.com resolves
# to the private IP of this endpoint inside the VPC — no internet traversal.
resource "aws_vpc_endpoint" "ses" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.email"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ses-api-endpoint"
  })
}

resource "aws_iam_role" "email_lambda_role" {
  name = "${var.name_prefix}-email-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-email-lambda-role"
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.email_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_sqs_policy" {
  name = "${var.name_prefix}-email-lambda-sqs-policy"
  role = aws_iam_role.email_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.sqs_queue_arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_ses_policy" {
  name = "${var.name_prefix}-email-lambda-ses-policy"
  role = aws_iam_role.email_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = [var.ses_sender_email_arn, var.ses_receiver_email_arn]
      }
    ]
  })
}

resource "aws_lambda_function" "email_sender" {
  function_name = "${var.name_prefix}-email-sender"
  role          = aws_iam_role.email_lambda_role.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  memory_size   = var.lambda_memory_size
  timeout       = var.lambda_timeout
  filename      = var.lambda_zip_path

  source_code_hash = filebase64sha256(var.lambda_zip_path)

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.email_lambda_sg.id]
  }

  environment {
    variables = {
      SES_SENDER_EMAIL = var.ses_sender_email
      SQS_QUEUE_URL    = var.sqs_queue_url
      AWS_SES_REGION   = var.aws_region
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-email-sender"
  })

  depends_on = [
    aws_iam_role_policy_attachment.lambda_vpc_access,
    aws_iam_role_policy.lambda_sqs_policy,
    aws_iam_role_policy.lambda_ses_policy
  ]
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.email_sender.arn
  batch_size       = var.batch_size
  enabled          = true

  depends_on = [aws_lambda_function.email_sender]
}
