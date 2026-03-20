output "lambda_function_arn" {
  description = "ARN of the email sender Lambda function"
  value       = aws_lambda_function.email_sender.arn
}

output "lambda_function_name" {
  description = "Name of the email sender Lambda function"
  value       = aws_lambda_function.email_sender.function_name
}

output "lambda_security_group_id" {
  description = "Security group ID of the email Lambda"
  value       = aws_security_group.email_lambda_sg.id
}

output "vpc_endpoints_security_group_id" {
  description = "Security group ID of the VPC endpoints"
  value       = aws_security_group.vpc_endpoints_sg.id
}

output "sqs_vpc_endpoint_id" {
  description = "ID of the SQS VPC interface endpoint"
  value       = aws_vpc_endpoint.sqs.id
}

output "ses_vpc_endpoint_id" {
  description = "ID of the SES API VPC interface endpoint"
  value       = aws_vpc_endpoint.ses.id
}
