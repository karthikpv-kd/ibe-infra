resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = merge(var.tags, { Name = "${var.name_prefix}-nat-eip" })
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.public_subnet_id

  tags = merge(var.tags, { Name = "${var.name_prefix}-nat-gateway" })
}
