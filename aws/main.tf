provider "aws" {
  region = "eu-central-1"
}


module "rds" {
  source = "./modules/rds"
}
module "ec2" {
  source = "./modules/ec2"

  db_adress = module.rds.db_adress
  db_name = module.rds.db_name
  db_password = module.rds.db_password
  db_port = module.rds.db_port
  db_username = module.rds.db_username
}

