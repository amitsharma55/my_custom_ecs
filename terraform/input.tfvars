aws_account_num = "<aws account id>"

##### VPC ########
aws_region = "us-east-1"
vpc_cidr_block = "172.16.0.0/16"
public_subnet_a_cidr_block = "172.16.1.0/24"
public_subnet_b_cidr_block = "172.16.2.0/24"

private_subnet_a_cidr_block = "172.16.3.0/24"
private_subnet_b_cidr_block = "172.16.4.0/24"

##### Container #####
image_name = "docker_project_11"
image_version = "latest"
#since we are using network mode as awsvpc so container & host port will be same
container_port = 8080
host_port = 8080
cpu = "256"
memory = "512"
desired_task_count = 2

##### ALB Traget Tracking ####
alb_target_value_for_scaling = 10
autoscaling_min_task = 2
autoscaling_max_task = 4
