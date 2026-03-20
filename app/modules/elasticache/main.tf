resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name_prefix}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, { Name = "${var.name_prefix}-redis-subnet-group" })
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id       = "${var.name_prefix}-redis"
  description                = "Redis cache for ${var.name_prefix}"
  node_type                  = "cache.t3.micro"
  num_cache_clusters         = 1
  engine_version             = "7.1"
  parameter_group_name       = "default.redis7"
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.this.name
  security_group_ids         = [var.redis_security_group_id]
  at_rest_encryption_enabled = false
  transit_encryption_enabled = false

  tags = merge(var.tags, { Name = "${var.name_prefix}-redis" })
}
