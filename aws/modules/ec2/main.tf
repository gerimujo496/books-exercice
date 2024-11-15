resource "aws_iam_policy" "ecsPolicy" {

    name="ecsRoleGeri"

  policy = <<EOF
 {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeTags",
                "ecs:CreateCluster",
                "ecs:DeregisterContainerInstance",
                "ecs:DiscoverPollEndpoint",
                "ecs:Poll",
                "ecs:RegisterContainerInstance",
                "ecs:StartTelemetrySession",
                "ecs:UpdateContainerInstancesState",
                "ecs:Submit*",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ecs:TagResource",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "ecs:CreateAction": [
                        "CreateCluster",
                        "RegisterContainerInstance"
                    ]
                }
            }
        }
    ]
}
  EOF
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "role" {
  name               = "ger-test-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


resource "aws_iam_role_policy_attachment" "ec2-read-only-policy-attachment" {
    role = aws_iam_role.role.name
    policy_arn = aws_iam_policy.ecsPolicy.arn
}


resource "aws_iam_instance_profile" "test_profile" {
  name="test_role_2"
  path="/"
  role = aws_iam_role.role.name
}


resource "aws_ecs_cluster" "ecs" {
  name = "geriCluster1"
  

}

resource "aws_launch_template" "name1" {
 name_prefix   = "ecs-template"
 image_id      = "ami-062c116e449466e7f"
 instance_type = "t3.micro"


 
 iam_instance_profile {
   name = "ecsInstanceRole"
 }

 block_device_mappings {
   device_name = "/dev/xvda"
   ebs {
     volume_size = 30
     volume_type = "gp2"
   }
 }

 tag_specifications {
   resource_type = "instance"
   tags = {
     Name = "ecs-instance"
   }
 }

 user_data = filebase64("./modules/ec2/script.sh")
}


resource "aws_autoscaling_group" "asg" {
 
    min_size = 1
    max_size = 3
    vpc_zone_identifier = ["subnet-048ed615c746deb83", "subnet-0c446972c4be90650", "subnet-0a886674953f327bc"]
    launch_template {
      id = aws_launch_template.name1.id
      version = "$Latest"
    }
   
  
}


resource "aws_lb" "elb" {
  name = "geri-lb"
  load_balancer_type = "application"

subnets =  ["subnet-048ed615c746deb83", "subnet-0c446972c4be90650"]
  tags = {
    Name = "geri-lb"
  }
}

resource "aws_lb_listener" "name" {
  load_balancer_arn = aws_lb.elb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

resource "aws_lb_target_group" "ecs_tg" {
    vpc_id = "vpc-072bcbc3be2e0ec63"
 name        = "ecs-target-group"
 port        = 80
 protocol    = "HTTP"
 target_type = "ip"
 

 health_check {
   path = "/health"
 }
}



resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
 name = "geriCapacity"

 auto_scaling_group_provider {
   auto_scaling_group_arn = aws_autoscaling_group.asg.arn

   managed_scaling {
     maximum_scaling_step_size = 1000
     minimum_scaling_step_size = 1
     status                    = "ENABLED"
     target_capacity           = 1
     
   }
 }

}

resource "aws_ecs_cluster_capacity_providers" "example" {
 cluster_name = aws_ecs_cluster.ecs.name

 capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

 default_capacity_provider_strategy {
   base              = 1
   weight            = 100
   capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
 }
}

resource "aws_ecs_task_definition" "service" {
  family = "geri-task"
  
  container_definitions = jsonencode([ {
            "name": "geri-task",
            "image": "${var.image}",
            "cpu": 0,
            "portMappings": [
                {
                    "name": "api-5000-tcp",
                    "containerPort": 5000,
                    "hostPort": 5000,
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ],
            "essential": true,
            "environment": [
                {
                    "name": "POSTGRES_USER",
                    "value": "${var.db_username}"
                },
                {
                    "name": "DATABASE_PORT",
                    "value": "${var.db_port}"
                },
                {
                    "name": "POSTGRES_PASSWORD",
                    "value": "${var.db_password}"
                },
                {
                    "name": "POSTGRES_DB",
                    "value": "${var.db_name}"
                },
                {
                    "name": "DATABASE_HOST",
                    "value": "${var.db_adress}"
                }
            ],
            "mountPoints": [],
            "volumesFrom": [],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/geri-task",
                    "mode": "non-blocking",
                    "awslogs-create-group": "true",
                    "max-buffer-size": "25m",
                    "awslogs-region": "eu-central-1",
                    "awslogs-stream-prefix": "ecs"
                }
            },
            "systemControls": []
        }])

 execution_role_arn = "arn:aws:iam::863872515231:role/ecsTaskExecutionRole"

requires_compatibilities =  [
        "EC2"
    ]
    cpu = "1024"
    memory = "205"
network_mode = "awsvpc"
}


resource "aws_ecs_service" "ecs_service" {
 name            = "my-ecs-service"
 cluster         = aws_ecs_cluster.ecs.id
 task_definition = aws_ecs_task_definition.service.arn
 desired_count   = 1

 network_configuration {
    
   subnets         = ["subnet-048ed615c746deb83", "subnet-0c446972c4be90650", "subnet-0a886674953f327bc"]
   security_groups = ["sg-0943ad0b8875a7e25"]
 }

 force_new_deployment = true
 placement_constraints {
   type = "distinctInstance"
 }

 triggers = {
   redeployment = timestamp()
 }

 capacity_provider_strategy {
   capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
   weight            = 100
 }

 load_balancer {
   target_group_arn = aws_lb_target_group.ecs_tg.arn
   container_name   = "geri-task"
   container_port   = 5000
 }

 depends_on = [aws_autoscaling_group.asg]
}