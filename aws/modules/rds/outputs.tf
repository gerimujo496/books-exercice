output "db_adress" {
  description = "rds_adress"
  value = aws_db_instance.postgres.address
}

output "db_password" {
  description = "rds_endpoint"
  value = aws_db_instance.postgres.password
}

output "db_username" {
  description = "rds_endpoint"
  value = aws_db_instance.postgres.username
}

output "db_name" {
  description = "db name"
  value = aws_db_instance.postgres.db_name
}

output "db_port" {
  description = "db port"
  value = aws_db_instance.postgres.port
}