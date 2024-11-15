output "lbDns" {
    description = "lb dns"
    value = aws_lb.elb.dns_name
  
}