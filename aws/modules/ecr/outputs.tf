output "ecrRepo" {
description = "ecr repo"
  value = aws_ecr_repository.name.repository_url
}