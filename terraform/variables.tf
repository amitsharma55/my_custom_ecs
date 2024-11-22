variable "aws_account_num" {}
variable "aws_region" {}
variable "vpc_cidr_block" {}
variable "public_subnet_a_cidr_block" {}
variable "public_subnet_b_cidr_block" {}
variable "private_subnet_a_cidr_block" {}
variable "private_subnet_b_cidr_block" {}

variable "image_name" {}
variable "image_version" {}
variable "container_port" {}
variable "host_port" {}
variable "cpu" {}
variable "memory" {}
variable "desired_task_count" {}

variable "alb_target_value_for_scaling" {}
variable "autoscaling_min_task" {}
variable "autoscaling_max_task" {}

