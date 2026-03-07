output "private_rt_id" {
  description = "ID of the private route table (used by S3 gateway endpoint)"
  value       = aws_route_table.private_rt.id
}
