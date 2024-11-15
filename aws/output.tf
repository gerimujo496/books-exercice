output "ecrRepo" {
  description = "ecr-repo"
  
  value = module.ecr.ecrRepo
}


output "lbDns" {
  description = "dnslb"
  value = module.ec2.lbDns
}

output "s3BucketName" {
  description = "s3 bucket name"
  value = module.s3_bucket.bucket
}