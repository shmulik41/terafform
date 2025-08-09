# Load Balancer ציבורי בשני סאבנטים ציבוריים
resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  idle_timeout = 60

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Target Group ל־HTTP:80 (ברירת מחדל / Health Check על "/")
resource "aws_lb_target_group" "app_tg" {
  name        = "${var.project_name}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# Listener על פורט 80 שמפנה ל־Target Group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Outputs שימושיים
output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}
output "target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}
