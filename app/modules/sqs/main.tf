resource "aws_sqs_queue" "booking_emails_dlq" {
  name                      = "${var.name_prefix}-booking-emails-dlq"
  message_retention_seconds = var.dlq_message_retention_seconds

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-booking-emails-dlq"
    Purpose = "DLQ for failed booking confirmation email messages"
  })
}

resource "aws_sqs_queue" "booking_emails_queue" {
  name                       = "${var.name_prefix}-booking-emails-queue"
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.booking_emails_dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-booking-emails-queue"
    Purpose = "Booking confirmation email processing queue"
  })
}
