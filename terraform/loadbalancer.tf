
#Load balancer
resource "aws_lb" "my_custom_alb" {
  name               = "my-custom-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_custom_alb_sg.id]
  subnets            = [aws_subnet.my_custom_subnet_public_a.id, aws_subnet.my_custom_subnet_public_b.id]
}

#Target Group
resource "aws_lb_target_group" "my_custom_alb_target_group" {
  name        = "my-custom-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.my_custom_vpc.id

  health_check {
    path        = "/"
    port        = "traffic-port"
    protocol    = "HTTP"
    matcher     = "200"
  }
}

#Listner
resource "aws_lb_listener" "my_custom_listener" {
  load_balancer_arn = aws_lb.my_custom_alb.arn
  port              = var.container_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_custom_alb_target_group.arn
  }
}
