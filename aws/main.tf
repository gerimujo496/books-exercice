provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-remote-state-geri"
    key    = "key/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "rds" {
  source = "./modules/rds"
}
module "ec2" {
  source = "./modules/ec2"
  image = var.image
  db_adress = module.rds.db_adress
  db_name = module.rds.db_name
  db_password = module.rds.db_password
  db_port = module.rds.db_port
  db_username = module.rds.db_username
}

module "ecr" {
  source = "./modules/ecr"
}



module "s3_bucket"{
  source = "./modules/s3"

  bucket_name = "geri007"

  document_suffix = "index.html"
  document_error = "error.html"
}

module "cloudfront" {
  source = "./modules/cloudfront"

domain_name = module.s3_bucket.domain_name
bucket =  module.s3_bucket.bucket

  document_suffix = "index.html"

}