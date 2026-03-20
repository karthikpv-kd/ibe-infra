resource "aws_lb" "this" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  tags = merge(var.tags, { Name = "${var.name_prefix}-alb" })
}

resource "aws_lb_target_group" "default" {
  name        = "${var.name_prefix}-default-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  tags = merge(var.tags, { Name = "${var.name_prefix}-default-tg" })
}

resource "aws_lb_target_group" "tenant" {
  name        = "${var.name_prefix}-tenant-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/tenant/health"
    matcher             = "200"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    interval            = 60
    timeout             = 10
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-tenant-tg" })
}

resource "aws_lb_target_group" "room_search" {
  name        = "${var.name_prefix}-room-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/rooms/health"
    matcher             = "200"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    interval            = 60
    timeout             = 10
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-room-tg" })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-http-listener" })
}

resource "aws_lb_listener_rule" "tenant" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tenant.arn
  }

  condition {
    path_pattern {
      values = ["/tenant/*"]
    }
  }

  tags = var.tags
}

resource "aws_lb_listener_rule" "room_search" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.room_search.arn
  }

  condition {
    path_pattern {
      values = ["/rooms/*"]
    }
  }

  tags = var.tags
}
