# ECS task execution role
resource "aws_iam_role" "my_custom_ecsTaskExecutionRole" {
  name = "my-custom-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_policy" "my_custom_ecsTaskExecutionRole_policy" {
  name        = "my-custom-ecsTaskExecutionRole-policy"
  description = "My custom ecstaskexecutionrole policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "my_custom_ecsTaskExecutionRole_policy_attach" {
  role       = aws_iam_role.my_custom_ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.my_custom_ecsTaskExecutionRole_policy.arn
}

# ECS auto scaling role
resource "aws_iam_role" "my_custom_ecsAutoScalingRole" {
  name = "my-custom-ecsAutoScalingRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "application-autoscaling.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_policy" "my_custom_ecsAutoScalingRole_policy" {
  name        = "my-custom-ecsAutoScalingRole-policy"
  description = "My custom ecsAutoScalingRole policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:PutMetricAlarm"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "my_custom_ecsAutoScalingRole_policy_attach" {
  role       = aws_iam_role.my_custom_ecsAutoScalingRole.name
  policy_arn = aws_iam_policy.my_custom_ecsAutoScalingRole_policy.arn
}