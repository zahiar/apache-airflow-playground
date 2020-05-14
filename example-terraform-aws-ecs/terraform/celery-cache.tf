module "elasticache-redis" {
  source  = "QuiNovas/elasticache-redis/aws"
  version = "3.0.0"

  group_description = "Celery Cache (Redis) Cluster"
  group_id          = "celery-cache-group"
  name              = "Celery Cache"
  subnet_ids        = module.vpc.elasticache_subnets
  vpc_id            = module.vpc.vpc_id
}