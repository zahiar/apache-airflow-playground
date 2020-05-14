resource "random_id" "airflow-db-user-password" {
  byte_length = 32
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "2.14.0"

  allocated_storage  = 20
  backup_window      = "00:00-00:30"
  engine             = "postgres"
  engine_version     = "11"
  identifier         = "airflow-db"
  instance_class     = "db.t2.micro"
  maintenance_window = "Mon:00:00-Mon:03:00"
  username           = "airflow"
  password           = random_id.airflow-db-user-password.hex
  port               = 3306
}
