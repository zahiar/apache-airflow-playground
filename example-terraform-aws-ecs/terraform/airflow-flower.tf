module "airflow-flower-web-app" {
  source = "git::https://github.com/zahiar/terraform-aws-ecs-web-app.git"

  app-container-web-port       = 8080
  app-cpu                      = 1024
  app-docker-image-repo        = module.ecr.repository_url
  app-docker-image-tag         = "latest"
  app-ecs-cluster-name         = module.ecs.this_ecs_cluster_name
  app-lb-health-check-url      = "/status"
  app-lb-https-certificate-arn = ""
  app-lb-idle-timeout          = 30
  app-lb-vpc-id                = module.vpc.vpc_id
  app-memory                   = 1024
  app-name                     = "airflow-flower"
  app-environment-variables = {
    AIRFLOW__CORE__EXECUTOR : "CeleryExecutor"
    AIRFLOW__CELERY__BROKER_URL : "redis://${module.elasticache-redis.auth_token}:@${module.elasticache-redis.primary_endpoint_address}/0"
    AIRFLOW__CELERY__RESULT_BACKEND : "db+postgresql://${module.rds.this_db_instance_username}:${module.rds.this_db_instance_password}@${module.rds.this_db_instance_address}:${module.rds.this_db_instance_port}/airflow"
    AIRFLOW__CORE__SQL_ALCHEMY_CONN : "postgresql+psycopg2://${module.rds.this_db_instance_username}:${module.rds.this_db_instance_password}@${module.rds.this_db_instance_address}:${module.rds.this_db_instance_port}/airflow"
    AIRFLOW__CORE__FERNET_KEY : "FB0o_zt4e3Ziq3LdUUO7F2Z95cvFFx16hU8jTeR1ASM="
    AIRFLOW__CORE__LOAD_EXAMPLES : "False"
  }
  app-lb-vpc-security-groups = [module.vpc.default_security_group_id]
  app-lb-vpc-subnets         = module.vpc.public_subnets
}