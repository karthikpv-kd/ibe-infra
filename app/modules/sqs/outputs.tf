output "queue_arn" {
  description = "ARN of the primary booking emails SQS queue"
  value       = aws_sqs_queue.booking_emails_queue.arn
}

output "queue_url" {
  description = "URL of the primary booking emails SQS queue"
  value       = aws_sqs_queue.booking_emails_queue.url
}

output "queue_name" {
  description = "Name of the primary booking emails SQS queue"
  value       = aws_sqs_queue.booking_emails_queue.name
}

output "dlq_arn" {
  description = "ARN of the dead letter queue"
  value       = aws_sqs_queue.booking_emails_dlq.arn
}

output "dlq_url" {
  description = "URL of the dead letter queue"
  value       = aws_sqs_queue.booking_emails_dlq.url
}
