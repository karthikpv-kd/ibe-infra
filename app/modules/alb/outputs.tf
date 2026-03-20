output "alb_arn" {
  value = aws_lb.this.arn
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "tenant_target_group_arn" {
  value = aws_lb_target_group.tenant.arn
}

output "room_search_target_group_arn" {
  value = aws_lb_target_group.room_search.arn
}
