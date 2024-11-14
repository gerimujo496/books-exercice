resource "aws_db_instance" "postgres" {
  allocated_storage    = 10
  db_name              = "geridb"
  engine               = "postgres"
  engine_version    = "16.3"
  instance_class       = "db.t3.micro"
  username             = "postgres"
  password             = "geri.mujo22"
 publicly_accessible = true
  skip_final_snapshot  = true
  

}