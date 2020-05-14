module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "2.0.0"

  name = "airflow-cluster"
}