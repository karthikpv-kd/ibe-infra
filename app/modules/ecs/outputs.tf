output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "tenant_service_name" {
  value = aws_ecs_service.tenant.name
}

output "room_search_service_name" {
  value = aws_ecs_service.room_search.name
}

output "tenant_task_definition_arn" {
  value = aws_ecs_task_definition.tenant.arn
}

output "room_search_task_definition_arn" {
  value = aws_ecs_task_definition.room_search.arn
}
