resource "aws_ecr_repository" "tenant_service" {
  name                 = "${var.name_prefix}-tenant-service"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-tenant-service" })
}

resource "aws_ecr_repository" "room_search_service" {
  name                 = "${var.name_prefix}-room-search-service"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-room-search-service" })
}
