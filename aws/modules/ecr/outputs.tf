output "ecrRepo" {
description = "ecr repo"
  value = aws_ecr_repository.name.repository_url
}

output "aws_lb_arn"{
  description = "aws lb arn"
  value = aws_lb.elb.arn
}

output "lbDns" {
    description = "lb dns"
    value = aws_lb.elb.dns_name
  
}