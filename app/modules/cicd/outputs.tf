output "tenant_codebuild_project_name" {
  value = aws_codebuild_project.tenant_service.name
}

output "room_search_codebuild_project_name" {
  value = aws_codebuild_project.room_search_service.name
}

output "artifacts_bucket_name" {
  value = aws_s3_bucket.artifacts.bucket
}
