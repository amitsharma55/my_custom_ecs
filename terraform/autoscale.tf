
locals {
  load_balancer_arn    = aws_lb.my_custom_alb.arn
  target_group_arn     = aws_lb_target_group.my_custom_alb_target_group.arn

  load_balancer_id     = basename(local.load_balancer_arn)
  target_group_id      = basename(local.target_group_arn)
}

resource "aws_appautoscaling_target" "my_custom_ecs_target" {
  max_capacity       = var.autoscaling_max_task
  min_capacity       = var.autoscaling_min_task
  resource_id        = "service/${aws_ecs_cluster.my_custom_nginx_cluster.name}/${aws_ecs_service.my_custom_nginx_service.name}"
  role_arn           = aws_iam_role.my_custom_ecsAutoScalingRole.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [
    aws_ecs_service.my_custom_nginx_service,
  ]
}

resource "aws_appautoscaling_policy" "my_custom_ecs_policy" {
  name                   = "my-custom-ecs-policy"
  policy_type            = "TargetTrackingScaling"
  resource_id            = "service/${aws_ecs_cluster.my_custom_nginx_cluster.name}/${aws_ecs_service.my_custom_nginx_service.name}"
  scalable_dimension     = aws_appautoscaling_target.my_custom_ecs_target.scalable_dimension
  service_namespace      = "ecs"

  target_tracking_scaling_policy_configuration {
    target_value = var.alb_target_value_for_scaling

    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "app/${aws_lb.my_custom_alb.name}/${local.load_balancer_id}/targetgroup/${aws_lb_target_group.my_custom_alb_target_group.name}/${local.target_group_id}"     
    }

    scale_in_cooldown      = 30
    scale_out_cooldown     = 30
  }
}
