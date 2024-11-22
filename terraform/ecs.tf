
################ ECS ################################

#ECS Cluster Creation
resource "aws_ecs_cluster" "my_custom_nginx_cluster" {
  name = "my-custom-nginx-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

#ECS Task Definition
resource "aws_ecs_task_definition" "my_custom_nginx_td" {
  family                   = "my-custom-nginx-td"
  execution_role_arn       = aws_iam_role.my_custom_ecsTaskExecutionRole.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory

  container_definitions = jsonencode([
    {
      name  = "my-custom-nginx-container"
      image = "${var.aws_account_num}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.image_name}:${var.image_version}"
      cpu   = 256
      memory = 512
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
          protocol      = "tcp"
        }
      ]
    }
  ])
  depends_on = [ aws_ecs_cluster.my_custom_nginx_cluster, aws_iam_role.my_custom_ecsTaskExecutionRole ]
}

#ECS Service
resource "aws_ecs_service" "my_custom_nginx_service" {
  name            = "my-custom-nginx-service"
  cluster         = aws_ecs_cluster.my_custom_nginx_cluster.id
  task_definition = aws_ecs_task_definition.my_custom_nginx_td.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_task_count 


  network_configuration {
    subnets         = [aws_subnet.my_custom_subnet_private_a.id, aws_subnet.my_custom_subnet_private_b.id]
    security_groups = [aws_security_group.my_custom_ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my_custom_alb_target_group.arn
    container_name   = "my-custom-nginx-container"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_target_group.my_custom_alb_target_group, aws_ecs_task_definition.my_custom_nginx_td]
}
