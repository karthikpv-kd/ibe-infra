output "tenant_service_repo_url" {
  value = aws_ecr_repository.tenant_service.repository_url
}

output "room_search_service_repo_url" {
  value = aws_ecr_repository.room_search_service.repository_url
}

output "tenant_service_repo_arn" {
  value = aws_ecr_repository.tenant_service.arn
}

output "room_search_service_repo_arn" {
  value = aws_ecr_repository.room_search_service.arn
}
