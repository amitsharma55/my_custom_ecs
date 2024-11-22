
output "app_server" {
  value = "http://${aws_lb.my_custom_alb.dns_name}:${var.container_port}"
}

output "page1" {
  value = "http://${aws_lb.my_custom_alb.dns_name}:${var.container_port}/page1/"
}

output "page2" {
  value = "http://${aws_lb.my_custom_alb.dns_name}:${var.container_port}/page2/"
}
