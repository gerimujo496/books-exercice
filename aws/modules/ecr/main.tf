
resource "aws_ecr_repository" "name" {
  name = "geri/ecr"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
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