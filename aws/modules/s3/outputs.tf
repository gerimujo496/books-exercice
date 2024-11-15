output "domain_name" {
  description = "domain name"
  value = aws_s3_bucket_website_configuration.website_bucket_config.website_endpoint
}

output "bucket" {
    description = "bucket"
    value = aws_s3_bucket.bucket.bucket
  
}