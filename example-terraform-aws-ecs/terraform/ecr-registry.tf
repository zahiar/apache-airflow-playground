module "ecr" {
  source  = "QuiNovas/ecr/aws"
  version = "3.0.0"

  name = "airflow/app"
}