# Example: Provision Airflow in AWS ECS using Terraform

**Disclaimer**: this is an untested proof-of-concept. Although terraform generates a plan successfully, it is not 
guaranteed to apply without issue.

# What is this?
Using Terraform, this will create all the necessary resources in Amazon Web Services (AWS) to run Apache Airflow with
Celery & Flower.

This will provision the following resources:
1. ECS Cluster
1. VPC
1. ECR - Docker registry + repository for us to publish our Docker images to
1. ElastiCache - Celery Redis-backed Cache
1. Postgres RDS - Airflow's meta-database
1. ECS task definitions + services - to run all the Docker containers
1. ALB (publicly accessible) - for both the Airflow Webserver & Flower (UI for Celery)

# How to run this?
## Requirements
Make sure you have the following:
* Docker
* Terraform 0.12
* AWS CLI - configured with appropriate IAM privileges

## Instructions
1. Run `terraform init` from within the project's _terraform_ directory
1. If all good, then run `terraform plan`
1. If you are happy with the plan, then run `terraform apply` -- note: the ECS tasks will fail to come up as we haven't
   published our custom Docker image yet - we'll do that next...
1. Run `docker-compose build` from the project's root directory to build your Docker image with your DAGs baked in
1. Now run these commands to publish your Docker image to ECR - be sure to substitute with your AWS details
   ```
   aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin YOU_AWS_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com
   docker tag airflow/app YOU_AWS_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com/airflow/app
   docker push YOU_AWS_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com/airflow/app
   ```
1. Your ECS tasks should start to come online now - give it a few minutes
1. You'll be able to access both the Airflow Webserver & Flower UIs via the ALB URLs shown after you ran `terraform apply`


<details>
    <summary>Click to view Terraform plan output</summary>

    ```hcl-terraform
    An execution plan has been generated and is shown below.
    Resource actions are indicated with the following symbols:
      + create
     <= read (data resources)
    
    Terraform will perform the following actions:
    
      # random_id.airflow-db-user-password will be created
      + resource "random_id" "airflow-db-user-password" {
          + b64         = (known after apply)
          + b64_std     = (known after apply)
          + b64_url     = (known after apply)
          + byte_length = 32
          + dec         = (known after apply)
          + hex         = (known after apply)
          + id          = (known after apply)
        }
    
      # module.airflow-flower-web-app.data.template_file.app-task-definition-template will be read during apply
      # (config refers to values not yet known)
     <= data "template_file" "app-task-definition-template"  {
          + id       = (known after apply)
          + rendered = (known after apply)
          + template = (known after apply)
        }
    
      # module.airflow-flower-web-app.aws_alb.app-lb will be created
      + resource "aws_alb" "app-lb" {
          + arn                        = (known after apply)
          + arn_suffix                 = (known after apply)
          + dns_name                   = (known after apply)
          + drop_invalid_header_fields = false
          + enable_deletion_protection = false
          + enable_http2               = true
          + id                         = (known after apply)
          + idle_timeout               = 30
          + internal                   = false
          + ip_address_type            = (known after apply)
          + load_balancer_type         = "application"
          + name                       = "airflow-flower-load-balancer"
          + security_groups            = (known after apply)
          + subnets                    = (known after apply)
          + vpc_id                     = (known after apply)
          + zone_id                    = (known after apply)
    
          + subnet_mapping {
              + allocation_id = (known after apply)
              + subnet_id     = (known after apply)
            }
        }
    
      # module.airflow-flower-web-app.aws_alb_listener.app-lb-http-listener will be created
      + resource "aws_alb_listener" "app-lb-http-listener" {
          + arn               = (known after apply)
          + id                = (known after apply)
          + load_balancer_arn = (known after apply)
          + port              = 80
          + protocol          = "HTTP"
          + ssl_policy        = (known after apply)
    
          + default_action {
              + order = (known after apply)
              + type  = "redirect"
    
              + redirect {
                  + host        = "#{host}"
                  + path        = "/#{path}"
                  + port        = "443"
                  + protocol    = "HTTPS"
                  + query       = "#{query}"
                  + status_code = "HTTP_301"
                }
            }
        }
    
      # module.airflow-flower-web-app.aws_alb_listener.app-lb-https-listener will be created
      + resource "aws_alb_listener" "app-lb-https-listener" {
          + arn               = (known after apply)
          + id                = (known after apply)
          + load_balancer_arn = (known after apply)
          + port              = 443
          + protocol          = "HTTPS"
          + ssl_policy        = "ELBSecurityPolicy-2016-08"
    
          + default_action {
              + order            = (known after apply)
              + target_group_arn = (known after apply)
              + type             = "forward"
            }
        }
    
      # module.airflow-flower-web-app.aws_alb_target_group.app-lb-target-group will be created
      + resource "aws_alb_target_group" "app-lb-target-group" {
          + arn                                = (known after apply)
          + arn_suffix                         = (known after apply)
          + deregistration_delay               = 300
          + id                                 = (known after apply)
          + lambda_multi_value_headers_enabled = false
          + load_balancing_algorithm_type      = (known after apply)
          + name                               = "airflow-flower-target-group"
          + port                               = 80
          + protocol                           = "HTTP"
          + proxy_protocol_v2                  = false
          + slow_start                         = 0
          + target_type                        = "instance"
          + vpc_id                             = (known after apply)
    
          + health_check {
              + enabled             = true
              + healthy_threshold   = 5
              + interval            = 30
              + matcher             = "200"
              + path                = "/status"
              + port                = "traffic-port"
              + protocol            = "HTTP"
              + timeout             = (known after apply)
              + unhealthy_threshold = 2
            }
    
          + stickiness {
              + cookie_duration = (known after apply)
              + enabled         = (known after apply)
              + type            = (known after apply)
            }
        }
    
      # module.airflow-flower-web-app.aws_ecs_service.app-ecs-service will be created
      + resource "aws_ecs_service" "app-ecs-service" {
          + cluster                            = "airflow-cluster"
          + deployment_maximum_percent         = 200
          + deployment_minimum_healthy_percent = 0
          + desired_count                      = 1
          + enable_ecs_managed_tags            = false
          + iam_role                           = (known after apply)
          + id                                 = (known after apply)
          + launch_type                        = (known after apply)
          + name                               = "airflow-flower"
          + platform_version                   = (known after apply)
          + scheduling_strategy                = "REPLICA"
          + task_definition                    = "airflow-flower"
    
          + load_balancer {
              + container_name   = "airflow-flower"
              + container_port   = 80
              + target_group_arn = (known after apply)
            }
    
          + placement_strategy {
              + field = (known after apply)
              + type  = (known after apply)
            }
        }
    
      # module.airflow-flower-web-app.aws_ecs_task_definition.app-task will be created
      + resource "aws_ecs_task_definition" "app-task" {
          + arn                   = (known after apply)
          + container_definitions = (known after apply)
          + family                = "airflow-flower"
          + id                    = (known after apply)
          + network_mode          = (known after apply)
          + revision              = (known after apply)
        }
    
      # module.airflow-scheduler-app.data.template_file.app-task-definition-template will be read during apply
      # (config refers to values not yet known)
     <= data "template_file" "app-task-definition-template"  {
          + id       = (known after apply)
          + rendered = (known after apply)
          + template = (known after apply)
        }
    
      # module.airflow-scheduler-app.aws_ecs_service.app-ecs-service will be created
      + resource "aws_ecs_service" "app-ecs-service" {
          + cluster                            = "airflow-cluster"
          + deployment_maximum_percent         = 200
          + deployment_minimum_healthy_percent = 0
          + desired_count                      = 1
          + enable_ecs_managed_tags            = false
          + iam_role                           = (known after apply)
          + id                                 = (known after apply)
          + launch_type                        = (known after apply)
          + name                               = "airflow-scheduler"
          + platform_version                   = (known after apply)
          + scheduling_strategy                = "REPLICA"
          + task_definition                    = "airflow-scheduler"
    
          + placement_strategy {
              + field = (known after apply)
              + type  = (known after apply)
            }
        }
    
      # module.airflow-scheduler-app.aws_ecs_task_definition.app-task will be created
      + resource "aws_ecs_task_definition" "app-task" {
          + arn                   = (known after apply)
          + container_definitions = (known after apply)
          + family                = "airflow-scheduler"
          + id                    = (known after apply)
          + network_mode          = (known after apply)
          + revision              = (known after apply)
        }
    
      # module.airflow-webserver-web-app.data.template_file.app-task-definition-template will be read during apply
      # (config refers to values not yet known)
     <= data "template_file" "app-task-definition-template"  {
          + id       = (known after apply)
          + rendered = (known after apply)
          + template = (known after apply)
        }
    
      # module.airflow-webserver-web-app.aws_alb.app-lb will be created
      + resource "aws_alb" "app-lb" {
          + arn                        = (known after apply)
          + arn_suffix                 = (known after apply)
          + dns_name                   = (known after apply)
          + drop_invalid_header_fields = false
          + enable_deletion_protection = false
          + enable_http2               = true
          + id                         = (known after apply)
          + idle_timeout               = 30
          + internal                   = false
          + ip_address_type            = (known after apply)
          + load_balancer_type         = "application"
          + name                       = "airflow-webserver-load-balancer"
          + security_groups            = (known after apply)
          + subnets                    = (known after apply)
          + vpc_id                     = (known after apply)
          + zone_id                    = (known after apply)
    
          + subnet_mapping {
              + allocation_id = (known after apply)
              + subnet_id     = (known after apply)
            }
        }
    
      # module.airflow-webserver-web-app.aws_alb_listener.app-lb-http-listener will be created
      + resource "aws_alb_listener" "app-lb-http-listener" {
          + arn               = (known after apply)
          + id                = (known after apply)
          + load_balancer_arn = (known after apply)
          + port              = 80
          + protocol          = "HTTP"
          + ssl_policy        = (known after apply)
    
          + default_action {
              + order = (known after apply)
              + type  = "redirect"
    
              + redirect {
                  + host        = "#{host}"
                  + path        = "/#{path}"
                  + port        = "443"
                  + protocol    = "HTTPS"
                  + query       = "#{query}"
                  + status_code = "HTTP_301"
                }
            }
        }
    
      # module.airflow-webserver-web-app.aws_alb_listener.app-lb-https-listener will be created
      + resource "aws_alb_listener" "app-lb-https-listener" {
          + arn               = (known after apply)
          + id                = (known after apply)
          + load_balancer_arn = (known after apply)
          + port              = 443
          + protocol          = "HTTPS"
          + ssl_policy        = "ELBSecurityPolicy-2016-08"
    
          + default_action {
              + order            = (known after apply)
              + target_group_arn = (known after apply)
              + type             = "forward"
            }
        }
    
      # module.airflow-webserver-web-app.aws_alb_target_group.app-lb-target-group will be created
      + resource "aws_alb_target_group" "app-lb-target-group" {
          + arn                                = (known after apply)
          + arn_suffix                         = (known after apply)
          + deregistration_delay               = 300
          + id                                 = (known after apply)
          + lambda_multi_value_headers_enabled = false
          + load_balancing_algorithm_type      = (known after apply)
          + name                               = "airflow-webserver-target-group"
          + port                               = 80
          + protocol                           = "HTTP"
          + proxy_protocol_v2                  = false
          + slow_start                         = 0
          + target_type                        = "instance"
          + vpc_id                             = (known after apply)
    
          + health_check {
              + enabled             = true
              + healthy_threshold   = 5
              + interval            = 30
              + matcher             = "200"
              + path                = "/status"
              + port                = "traffic-port"
              + protocol            = "HTTP"
              + timeout             = (known after apply)
              + unhealthy_threshold = 2
            }
    
          + stickiness {
              + cookie_duration = (known after apply)
              + enabled         = (known after apply)
              + type            = (known after apply)
            }
        }
    
      # module.airflow-webserver-web-app.aws_ecs_service.app-ecs-service will be created
      + resource "aws_ecs_service" "app-ecs-service" {
          + cluster                            = "airflow-cluster"
          + deployment_maximum_percent         = 200
          + deployment_minimum_healthy_percent = 0
          + desired_count                      = 1
          + enable_ecs_managed_tags            = false
          + iam_role                           = (known after apply)
          + id                                 = (known after apply)
          + launch_type                        = (known after apply)
          + name                               = "airflow-webserver"
          + platform_version                   = (known after apply)
          + scheduling_strategy                = "REPLICA"
          + task_definition                    = "airflow-webserver"
    
          + load_balancer {
              + container_name   = "airflow-webserver"
              + container_port   = 80
              + target_group_arn = (known after apply)
            }
    
          + placement_strategy {
              + field = (known after apply)
              + type  = (known after apply)
            }
        }
    
      # module.airflow-webserver-web-app.aws_ecs_task_definition.app-task will be created
      + resource "aws_ecs_task_definition" "app-task" {
          + arn                   = (known after apply)
          + container_definitions = (known after apply)
          + family                = "airflow-webserver"
          + id                    = (known after apply)
          + network_mode          = (known after apply)
          + revision              = (known after apply)
        }
    
      # module.airflow-worker-app.data.template_file.app-task-definition-template will be read during apply
      # (config refers to values not yet known)
     <= data "template_file" "app-task-definition-template"  {
          + id       = (known after apply)
          + rendered = (known after apply)
          + template = (known after apply)
        }
    
      # module.airflow-worker-app.aws_ecs_service.app-ecs-service will be created
      + resource "aws_ecs_service" "app-ecs-service" {
          + cluster                            = "airflow-cluster"
          + deployment_maximum_percent         = 200
          + deployment_minimum_healthy_percent = 0
          + desired_count                      = 1
          + enable_ecs_managed_tags            = false
          + iam_role                           = (known after apply)
          + id                                 = (known after apply)
          + launch_type                        = (known after apply)
          + name                               = "airflow-worker"
          + platform_version                   = (known after apply)
          + scheduling_strategy                = "REPLICA"
          + task_definition                    = "airflow-worker"
    
          + placement_strategy {
              + field = (known after apply)
              + type  = (known after apply)
            }
        }
    
      # module.airflow-worker-app.aws_ecs_task_definition.app-task will be created
      + resource "aws_ecs_task_definition" "app-task" {
          + arn                   = (known after apply)
          + container_definitions = (known after apply)
          + family                = "airflow-worker"
          + id                    = (known after apply)
          + network_mode          = (known after apply)
          + revision              = (known after apply)
        }
    
      # module.ecr.aws_ecr_lifecycle_policy.repo will be created
      + resource "aws_ecr_lifecycle_policy" "repo" {
          + id          = (known after apply)
          + policy      = jsonencode(
                {
                  + rules = [
                      + {
                          + action       = {
                              + type = "expire"
                            }
                          + description  = "Keep only one untagged image, expire all others"
                          + rulePriority = 1
                          + selection    = {
                              + countNumber = 1
                              + countType   = "imageCountMoreThan"
                              + tagStatus   = "untagged"
                            }
                        },
                      + {
                          + action       = {
                              + type = "expire"
                            }
                          + description  = "Keep 20 tagged images, expire all others"
                          + rulePriority = 2
                          + selection    = {
                              + countNumber   = 20
                              + countType     = "imageCountMoreThan"
                              + tagPrefixList = [
                                  + "A",
                                  + "B",
                                  + "C",
                                  + "D",
                                  + "E",
                                  + "F",
                                  + "G",
                                  + "H",
                                  + "I",
                                  + "J",
                                ]
                              + tagStatus     = "tagged"
                            }
                        },
                      + {
                          + action       = {
                              + type = "expire"
                            }
                          + description  = "Keep 20 tagged images, expire all others"
                          + rulePriority = 3
                          + selection    = {
                              + countNumber   = 20
                              + countType     = "imageCountMoreThan"
                              + tagPrefixList = [
                                  + "K",
                                  + "L",
                                  + "M",
                                  + "N",
                                  + "O",
                                  + "P",
                                  + "Q",
                                  + "R",
                                  + "S",
                                  + "T",
                                ]
                              + tagStatus     = "tagged"
                            }
                        },
                      + {
                          + action       = {
                              + type = "expire"
                            }
                          + description  = "Keep 20 tagged images, expire all others"
                          + rulePriority = 4
                          + selection    = {
                              + countNumber   = 20
                              + countType     = "imageCountMoreThan"
                              + tagPrefixList = [
                                  + "U",
                                  + "V",
                                  + "W",
                                  + "X",
                                  + "Y",
                                  + "Z",
                                  + "a",
                                  + "b",
                                  + "c",
                                  + "d",
                                ]
                              + tagStatus     = "tagged"
                            }
                        },
                      + {
                          + action       = {
                              + type = "expire"
                            }
                          + description  = "Keep 20 tagged images, expire all others"
                          + rulePriority = 5
                          + selection    = {
                              + countNumber   = 20
                              + countType     = "imageCountMoreThan"
                              + tagPrefixList = [
                                  + "e",
                                  + "f",
                                  + "g",
                                  + "h",
                                  + "i",
                                  + "j",
                                  + "k",
                                  + "l",
                                  + "m",
                                  + "n",
                                ]
                              + tagStatus     = "tagged"
                            }
                        },
                      + {
                          + action       = {
                              + type = "expire"
                            }
                          + description  = "Keep 20 tagged images, expire all others"
                          + rulePriority = 6
                          + selection    = {
                              + countNumber   = 20
                              + countType     = "imageCountMoreThan"
                              + tagPrefixList = [
                                  + "o",
                                  + "p",
                                  + "q",
                                  + "r",
                                  + "s",
                                  + "t",
                                  + "u",
                                  + "v",
                                  + "w",
                                  + "y",
                                ]
                              + tagStatus     = "tagged"
                            }
                        },
                      + {
                          + action       = {
                              + type = "expire"
                            }
                          + description  = "Keep 20 tagged images, expire all others"
                          + rulePriority = 7
                          + selection    = {
                              + countNumber   = 20
                              + countType     = "imageCountMoreThan"
                              + tagPrefixList = [
                                  + "z",
                                  + "0",
                                  + "1",
                                  + "2",
                                  + "3",
                                  + "4",
                                  + "5",
                                  + "6",
                                  + "7",
                                  + "8",
                                ]
                              + tagStatus     = "tagged"
                            }
                        },
                      + {
                          + action       = {
                              + type = "expire"
                            }
                          + description  = "Keep 20 tagged images, expire all others"
                          + rulePriority = 8
                          + selection    = {
                              + countNumber   = 20
                              + countType     = "imageCountMoreThan"
                              + tagPrefixList = [
                                  + "9",
                                ]
                              + tagStatus     = "tagged"
                            }
                        },
                    ]
                }
            )
          + registry_id = (known after apply)
          + repository  = "airflow/app"
        }
    
      # module.ecr.aws_ecr_repository.repo will be created
      + resource "aws_ecr_repository" "repo" {
          + arn                  = (known after apply)
          + id                   = (known after apply)
          + image_tag_mutability = "MUTABLE"
          + name                 = "airflow/app"
          + registry_id          = (known after apply)
          + repository_url       = (known after apply)
        }
    
      # module.ecr.aws_ecr_repository_policy.repo will be created
      + resource "aws_ecr_repository_policy" "repo" {
          + id          = (known after apply)
          + policy      = jsonencode(
                {
                  + Statement = [
                      + {
                          + Action    = [
                              + "ecr:ListImages",
                              + "ecr:GetRepositoryPolicy",
                              + "ecr:GetDownloadUrlForLayer",
                              + "ecr:GetAuthorizationToken",
                              + "ecr:DescribeRepositories",
                              + "ecr:DescribeImages",
                              + "ecr:BatchGetImage",
                              + "ecr:BatchCheckLayerAvailability",
                            ]
                          + Effect    = "Allow"
                          + Principal = {
                              + AWS = "<REDACTED>"
                            }
                          + Sid       = "AllowCrossAccountAccess"
                        },
                    ]
                  + Version   = "2012-10-17"
                }
            )
          + registry_id = (known after apply)
          + repository  = "airflow/app"
        }
    
      # module.ecs.aws_ecs_cluster.this[0] will be created
      + resource "aws_ecs_cluster" "this" {
          + arn  = (known after apply)
          + id   = (known after apply)
          + name = "airflow-cluster"
    
          + setting {
              + name  = (known after apply)
              + value = (known after apply)
            }
        }
    
      # module.elasticache-redis.aws_elasticache_replication_group.redis will be created
      + resource "aws_elasticache_replication_group" "redis" {
          + apply_immediately              = (known after apply)
          + at_rest_encryption_enabled     = true
          + auth_token                     = (sensitive value)
          + auto_minor_version_upgrade     = false
          + automatic_failover_enabled     = true
          + configuration_endpoint_address = (known after apply)
          + engine                         = "redis"
          + engine_version                 = "3.2.6"
          + id                             = (known after apply)
          + maintenance_window             = (known after apply)
          + member_clusters                = (known after apply)
          + node_type                      = "cache.m3.medium"
          + number_cache_clusters          = 2
          + parameter_group_name           = (known after apply)
          + port                           = 6379
          + primary_endpoint_address       = (known after apply)
          + replication_group_description  = "Celery Cache (Redis) Cluster"
          + replication_group_id           = "celery-cache-group"
          + security_group_ids             = (known after apply)
          + security_group_names           = (known after apply)
          + snapshot_retention_limit       = 7
          + snapshot_window                = "06:00-07:00"
          + subnet_group_name              = "celery cache"
          + tags                           = {
              + "Name" = "Celery Cache"
            }
          + transit_encryption_enabled     = true
    
          + cluster_mode {
              + num_node_groups         = (known after apply)
              + replicas_per_node_group = (known after apply)
            }
        }
    
      # module.elasticache-redis.aws_elasticache_subnet_group.redis will be created
      + resource "aws_elasticache_subnet_group" "redis" {
          + description = "Managed by Terraform"
          + id          = (known after apply)
          + name        = "celery cache"
        }
    
      # module.elasticache-redis.aws_security_group.redis will be created
      + resource "aws_security_group" "redis" {
          + arn                    = (known after apply)
          + description            = "Managed by Terraform"
          + egress                 = (known after apply)
          + id                     = (known after apply)
          + ingress                = (known after apply)
          + name                   = "Celery Cache"
          + owner_id               = (known after apply)
          + revoke_rules_on_delete = false
          + tags                   = {
              + "Name" = "Celery Cache"
            }
          + vpc_id                 = (known after apply)
        }
    
      # module.elasticache-redis.aws_security_group_rule.all_egress will be created
      + resource "aws_security_group_rule" "all_egress" {
          + cidr_blocks              = [
              + "0.0.0.0/0",
            ]
          + from_port                = 0
          + id                       = (known after apply)
          + protocol                 = "-1"
          + security_group_id        = (known after apply)
          + self                     = false
          + source_security_group_id = (known after apply)
          + to_port                  = 0
          + type                     = "egress"
        }
    
      # module.elasticache-redis.aws_security_group_rule.self_ingress will be created
      + resource "aws_security_group_rule" "self_ingress" {
          + from_port                = 0
          + id                       = (known after apply)
          + protocol                 = "-1"
          + security_group_id        = (known after apply)
          + self                     = true
          + source_security_group_id = (known after apply)
          + to_port                  = 0
          + type                     = "ingress"
        }
    
      # module.elasticache-redis.random_string.auth_token will be created
      + resource "random_string" "auth_token" {
          + id               = (known after apply)
          + length           = 64
          + lower            = true
          + min_lower        = 0
          + min_numeric      = 0
          + min_special      = 0
          + min_upper        = 0
          + number           = true
          + override_special = "!#$%&*()-_=+[]{}<>:?"
          + result           = (known after apply)
          + special          = true
          + upper            = true
        }
    
      # module.vpc.aws_eip.nat[0] will be created
      + resource "aws_eip" "nat" {
          + allocation_id     = (known after apply)
          + association_id    = (known after apply)
          + customer_owned_ip = (known after apply)
          + domain            = (known after apply)
          + id                = (known after apply)
          + instance          = (known after apply)
          + network_interface = (known after apply)
          + private_dns       = (known after apply)
          + private_ip        = (known after apply)
          + public_dns        = (known after apply)
          + public_ip         = (known after apply)
          + public_ipv4_pool  = (known after apply)
          + tags              = {
              + "Name" = "airflow-vpc-eu-west-2a"
            }
          + vpc               = true
        }
    
      # module.vpc.aws_eip.nat[1] will be created
      + resource "aws_eip" "nat" {
          + allocation_id     = (known after apply)
          + association_id    = (known after apply)
          + customer_owned_ip = (known after apply)
          + domain            = (known after apply)
          + id                = (known after apply)
          + instance          = (known after apply)
          + network_interface = (known after apply)
          + private_dns       = (known after apply)
          + private_ip        = (known after apply)
          + public_dns        = (known after apply)
          + public_ip         = (known after apply)
          + public_ipv4_pool  = (known after apply)
          + tags              = {
              + "Name" = "airflow-vpc-eu-west-2b"
            }
          + vpc               = true
        }
    
      # module.vpc.aws_eip.nat[2] will be created
      + resource "aws_eip" "nat" {
          + allocation_id     = (known after apply)
          + association_id    = (known after apply)
          + customer_owned_ip = (known after apply)
          + domain            = (known after apply)
          + id                = (known after apply)
          + instance          = (known after apply)
          + network_interface = (known after apply)
          + private_dns       = (known after apply)
          + private_ip        = (known after apply)
          + public_dns        = (known after apply)
          + public_ip         = (known after apply)
          + public_ipv4_pool  = (known after apply)
          + tags              = {
              + "Name" = "airflow-vpc-eu-west-2c"
            }
          + vpc               = true
        }
    
      # module.vpc.aws_internet_gateway.this[0] will be created
      + resource "aws_internet_gateway" "this" {
          + id       = (known after apply)
          + owner_id = (known after apply)
          + tags     = {
              + "Name" = "airflow-vpc"
            }
          + vpc_id   = (known after apply)
        }
    
      # module.vpc.aws_nat_gateway.this[0] will be created
      + resource "aws_nat_gateway" "this" {
          + allocation_id        = (known after apply)
          + id                   = (known after apply)
          + network_interface_id = (known after apply)
          + private_ip           = (known after apply)
          + public_ip            = (known after apply)
          + subnet_id            = (known after apply)
          + tags                 = {
              + "Name" = "airflow-vpc-eu-west-2a"
            }
        }
    
      # module.vpc.aws_nat_gateway.this[1] will be created
      + resource "aws_nat_gateway" "this" {
          + allocation_id        = (known after apply)
          + id                   = (known after apply)
          + network_interface_id = (known after apply)
          + private_ip           = (known after apply)
          + public_ip            = (known after apply)
          + subnet_id            = (known after apply)
          + tags                 = {
              + "Name" = "airflow-vpc-eu-west-2b"
            }
        }
    
      # module.vpc.aws_nat_gateway.this[2] will be created
      + resource "aws_nat_gateway" "this" {
          + allocation_id        = (known after apply)
          + id                   = (known after apply)
          + network_interface_id = (known after apply)
          + private_ip           = (known after apply)
          + public_ip            = (known after apply)
          + subnet_id            = (known after apply)
          + tags                 = {
              + "Name" = "airflow-vpc-eu-west-2c"
            }
        }
    
      # module.vpc.aws_route.private_nat_gateway[0] will be created
      + resource "aws_route" "private_nat_gateway" {
          + destination_cidr_block     = "0.0.0.0/0"
          + destination_prefix_list_id = (known after apply)
          + egress_only_gateway_id     = (known after apply)
          + gateway_id                 = (known after apply)
          + id                         = (known after apply)
          + instance_id                = (known after apply)
          + instance_owner_id          = (known after apply)
          + nat_gateway_id             = (known after apply)
          + network_interface_id       = (known after apply)
          + origin                     = (known after apply)
          + route_table_id             = (known after apply)
          + state                      = (known after apply)
    
          + timeouts {
              + create = "5m"
            }
        }
    
      # module.vpc.aws_route.private_nat_gateway[1] will be created
      + resource "aws_route" "private_nat_gateway" {
          + destination_cidr_block     = "0.0.0.0/0"
          + destination_prefix_list_id = (known after apply)
          + egress_only_gateway_id     = (known after apply)
          + gateway_id                 = (known after apply)
          + id                         = (known after apply)
          + instance_id                = (known after apply)
          + instance_owner_id          = (known after apply)
          + nat_gateway_id             = (known after apply)
          + network_interface_id       = (known after apply)
          + origin                     = (known after apply)
          + route_table_id             = (known after apply)
          + state                      = (known after apply)
    
          + timeouts {
              + create = "5m"
            }
        }
    
      # module.vpc.aws_route.private_nat_gateway[2] will be created
      + resource "aws_route" "private_nat_gateway" {
          + destination_cidr_block     = "0.0.0.0/0"
          + destination_prefix_list_id = (known after apply)
          + egress_only_gateway_id     = (known after apply)
          + gateway_id                 = (known after apply)
          + id                         = (known after apply)
          + instance_id                = (known after apply)
          + instance_owner_id          = (known after apply)
          + nat_gateway_id             = (known after apply)
          + network_interface_id       = (known after apply)
          + origin                     = (known after apply)
          + route_table_id             = (known after apply)
          + state                      = (known after apply)
    
          + timeouts {
              + create = "5m"
            }
        }
    
      # module.vpc.aws_route.public_internet_gateway[0] will be created
      + resource "aws_route" "public_internet_gateway" {
          + destination_cidr_block     = "0.0.0.0/0"
          + destination_prefix_list_id = (known after apply)
          + egress_only_gateway_id     = (known after apply)
          + gateway_id                 = (known after apply)
          + id                         = (known after apply)
          + instance_id                = (known after apply)
          + instance_owner_id          = (known after apply)
          + nat_gateway_id             = (known after apply)
          + network_interface_id       = (known after apply)
          + origin                     = (known after apply)
          + route_table_id             = (known after apply)
          + state                      = (known after apply)
    
          + timeouts {
              + create = "5m"
            }
        }
    
      # module.vpc.aws_route_table.private[0] will be created
      + resource "aws_route_table" "private" {
          + id               = (known after apply)
          + owner_id         = (known after apply)
          + propagating_vgws = (known after apply)
          + route            = (known after apply)
          + tags             = {
              + "Name" = "airflow-vpc-private-eu-west-2a"
            }
          + vpc_id           = (known after apply)
        }
    
      # module.vpc.aws_route_table.private[1] will be created
      + resource "aws_route_table" "private" {
          + id               = (known after apply)
          + owner_id         = (known after apply)
          + propagating_vgws = (known after apply)
          + route            = (known after apply)
          + tags             = {
              + "Name" = "airflow-vpc-private-eu-west-2b"
            }
          + vpc_id           = (known after apply)
        }
    
      # module.vpc.aws_route_table.private[2] will be created
      + resource "aws_route_table" "private" {
          + id               = (known after apply)
          + owner_id         = (known after apply)
          + propagating_vgws = (known after apply)
          + route            = (known after apply)
          + tags             = {
              + "Name" = "airflow-vpc-private-eu-west-2c"
            }
          + vpc_id           = (known after apply)
        }
    
      # module.vpc.aws_route_table.public[0] will be created
      + resource "aws_route_table" "public" {
          + id               = (known after apply)
          + owner_id         = (known after apply)
          + propagating_vgws = (known after apply)
          + route            = (known after apply)
          + tags             = {
              + "Name" = "airflow-vpc-public"
            }
          + vpc_id           = (known after apply)
        }
    
      # module.vpc.aws_route_table_association.private[0] will be created
      + resource "aws_route_table_association" "private" {
          + id             = (known after apply)
          + route_table_id = (known after apply)
          + subnet_id      = (known after apply)
        }
    
      # module.vpc.aws_route_table_association.private[1] will be created
      + resource "aws_route_table_association" "private" {
          + id             = (known after apply)
          + route_table_id = (known after apply)
          + subnet_id      = (known after apply)
        }
    
      # module.vpc.aws_route_table_association.private[2] will be created
      + resource "aws_route_table_association" "private" {
          + id             = (known after apply)
          + route_table_id = (known after apply)
          + subnet_id      = (known after apply)
        }
    
      # module.vpc.aws_route_table_association.public[0] will be created
      + resource "aws_route_table_association" "public" {
          + id             = (known after apply)
          + route_table_id = (known after apply)
          + subnet_id      = (known after apply)
        }
    
      # module.vpc.aws_route_table_association.public[1] will be created
      + resource "aws_route_table_association" "public" {
          + id             = (known after apply)
          + route_table_id = (known after apply)
          + subnet_id      = (known after apply)
        }
    
      # module.vpc.aws_route_table_association.public[2] will be created
      + resource "aws_route_table_association" "public" {
          + id             = (known after apply)
          + route_table_id = (known after apply)
          + subnet_id      = (known after apply)
        }
    
      # module.vpc.aws_subnet.private[0] will be created
      + resource "aws_subnet" "private" {
          + arn                             = (known after apply)
          + assign_ipv6_address_on_creation = false
          + availability_zone               = "eu-west-2a"
          + availability_zone_id            = (known after apply)
          + cidr_block                      = "10.0.1.0/24"
          + id                              = (known after apply)
          + ipv6_cidr_block                 = (known after apply)
          + ipv6_cidr_block_association_id  = (known after apply)
          + map_public_ip_on_launch         = false
          + owner_id                        = (known after apply)
          + tags                            = {
              + "Name" = "airflow-vpc-private-eu-west-2a"
            }
          + vpc_id                          = (known after apply)
        }
    
      # module.vpc.aws_subnet.private[1] will be created
      + resource "aws_subnet" "private" {
          + arn                             = (known after apply)
          + assign_ipv6_address_on_creation = false
          + availability_zone               = "eu-west-2b"
          + availability_zone_id            = (known after apply)
          + cidr_block                      = "10.0.2.0/24"
          + id                              = (known after apply)
          + ipv6_cidr_block                 = (known after apply)
          + ipv6_cidr_block_association_id  = (known after apply)
          + map_public_ip_on_launch         = false
          + owner_id                        = (known after apply)
          + tags                            = {
              + "Name" = "airflow-vpc-private-eu-west-2b"
            }
          + vpc_id                          = (known after apply)
        }
    
      # module.vpc.aws_subnet.private[2] will be created
      + resource "aws_subnet" "private" {
          + arn                             = (known after apply)
          + assign_ipv6_address_on_creation = false
          + availability_zone               = "eu-west-2c"
          + availability_zone_id            = (known after apply)
          + cidr_block                      = "10.0.3.0/24"
          + id                              = (known after apply)
          + ipv6_cidr_block                 = (known after apply)
          + ipv6_cidr_block_association_id  = (known after apply)
          + map_public_ip_on_launch         = false
          + owner_id                        = (known after apply)
          + tags                            = {
              + "Name" = "airflow-vpc-private-eu-west-2c"
            }
          + vpc_id                          = (known after apply)
        }
    
      # module.vpc.aws_subnet.public[0] will be created
      + resource "aws_subnet" "public" {
          + arn                             = (known after apply)
          + assign_ipv6_address_on_creation = false
          + availability_zone               = "eu-west-2a"
          + availability_zone_id            = (known after apply)
          + cidr_block                      = "10.0.101.0/24"
          + id                              = (known after apply)
          + ipv6_cidr_block                 = (known after apply)
          + ipv6_cidr_block_association_id  = (known after apply)
          + map_public_ip_on_launch         = true
          + owner_id                        = (known after apply)
          + tags                            = {
              + "Name" = "airflow-vpc-public-eu-west-2a"
            }
          + vpc_id                          = (known after apply)
        }
    
      # module.vpc.aws_subnet.public[1] will be created
      + resource "aws_subnet" "public" {
          + arn                             = (known after apply)
          + assign_ipv6_address_on_creation = false
          + availability_zone               = "eu-west-2b"
          + availability_zone_id            = (known after apply)
          + cidr_block                      = "10.0.102.0/24"
          + id                              = (known after apply)
          + ipv6_cidr_block                 = (known after apply)
          + ipv6_cidr_block_association_id  = (known after apply)
          + map_public_ip_on_launch         = true
          + owner_id                        = (known after apply)
          + tags                            = {
              + "Name" = "airflow-vpc-public-eu-west-2b"
            }
          + vpc_id                          = (known after apply)
        }
    
      # module.vpc.aws_subnet.public[2] will be created
      + resource "aws_subnet" "public" {
          + arn                             = (known after apply)
          + assign_ipv6_address_on_creation = false
          + availability_zone               = "eu-west-2c"
          + availability_zone_id            = (known after apply)
          + cidr_block                      = "10.0.103.0/24"
          + id                              = (known after apply)
          + ipv6_cidr_block                 = (known after apply)
          + ipv6_cidr_block_association_id  = (known after apply)
          + map_public_ip_on_launch         = true
          + owner_id                        = (known after apply)
          + tags                            = {
              + "Name" = "airflow-vpc-public-eu-west-2c"
            }
          + vpc_id                          = (known after apply)
        }
    
      # module.vpc.aws_vpc.this[0] will be created
      + resource "aws_vpc" "this" {
          + arn                              = (known after apply)
          + assign_generated_ipv6_cidr_block = false
          + cidr_block                       = "10.0.0.0/16"
          + default_network_acl_id           = (known after apply)
          + default_route_table_id           = (known after apply)
          + default_security_group_id        = (known after apply)
          + dhcp_options_id                  = (known after apply)
          + enable_classiclink               = (known after apply)
          + enable_classiclink_dns_support   = (known after apply)
          + enable_dns_hostnames             = false
          + enable_dns_support               = true
          + id                               = (known after apply)
          + instance_tenancy                 = "default"
          + ipv6_association_id              = (known after apply)
          + ipv6_cidr_block                  = (known after apply)
          + main_route_table_id              = (known after apply)
          + owner_id                         = (known after apply)
          + tags                             = {
              + "Name" = "airflow-vpc"
            }
        }
    
      # module.vpc.aws_vpn_gateway.this[0] will be created
      + resource "aws_vpn_gateway" "this" {
          + amazon_side_asn = "64512"
          + id              = (known after apply)
          + tags            = {
              + "Name" = "airflow-vpc"
            }
          + vpc_id          = (known after apply)
        }
    
      # module.rds.module.db_instance.aws_db_instance.this[0] will be created
      + resource "aws_db_instance" "this" {
          + address                               = (known after apply)
          + allocated_storage                     = 20
          + allow_major_version_upgrade           = false
          + apply_immediately                     = false
          + arn                                   = (known after apply)
          + auto_minor_version_upgrade            = true
          + availability_zone                     = (known after apply)
          + backup_retention_period               = 1
          + backup_window                         = "00:00-00:30"
          + ca_cert_identifier                    = "rds-ca-2019"
          + character_set_name                    = (known after apply)
          + copy_tags_to_snapshot                 = false
          + db_subnet_group_name                  = (known after apply)
          + delete_automated_backups              = true
          + deletion_protection                   = false
          + enabled_cloudwatch_logs_exports       = []
          + endpoint                              = (known after apply)
          + engine                                = "postgres"
          + engine_version                        = "11"
          + hosted_zone_id                        = (known after apply)
          + iam_database_authentication_enabled   = false
          + id                                    = (known after apply)
          + identifier                            = "airflow-db"
          + identifier_prefix                     = (known after apply)
          + instance_class                        = "db.t2.micro"
          + iops                                  = 0
          + kms_key_id                            = (known after apply)
          + license_model                         = (known after apply)
          + maintenance_window                    = "mon:00:00-mon:03:00"
          + max_allocated_storage                 = 0
          + monitoring_interval                   = 0
          + monitoring_role_arn                   = (known after apply)
          + multi_az                              = false
          + name                                  = (known after apply)
          + option_group_name                     = (known after apply)
          + parameter_group_name                  = (known after apply)
          + password                              = (sensitive value)
          + performance_insights_enabled          = false
          + performance_insights_kms_key_id       = (known after apply)
          + performance_insights_retention_period = (known after apply)
          + port                                  = 3306
          + publicly_accessible                   = false
          + replicas                              = (known after apply)
          + resource_id                           = (known after apply)
          + skip_final_snapshot                   = true
          + status                                = (known after apply)
          + storage_encrypted                     = false
          + storage_type                          = "gp2"
          + tags                                  = {
              + "Name" = "airflow-db"
            }
          + timezone                              = (known after apply)
          + username                              = "airflow"
          + vpc_security_group_ids                = (known after apply)
    
          + timeouts {
              + create = "40m"
              + delete = "40m"
              + update = "80m"
            }
        }
    
      # module.rds.module.db_option_group.aws_db_option_group.this[0] will be created
      + resource "aws_db_option_group" "this" {
          + arn                      = (known after apply)
          + engine_name              = "postgres"
          + id                       = (known after apply)
          + name                     = (known after apply)
          + name_prefix              = "airflow-db-"
          + option_group_description = "Option group for airflow-db"
          + tags                     = {
              + "Name" = "airflow-db"
            }
    
          + timeouts {
              + delete = "15m"
            }
        }
    
      # module.rds.module.db_parameter_group.aws_db_parameter_group.this[0] will be created
      + resource "aws_db_parameter_group" "this" {
          + arn         = (known after apply)
          + description = "Database parameter group for airflow-db"
          + id          = (known after apply)
          + name        = (known after apply)
          + name_prefix = "airflow-db-"
          + tags        = {
              + "Name" = "airflow-db"
            }
        }
    
      # module.rds.module.db_subnet_group.aws_db_subnet_group.this[0] will be created
      + resource "aws_db_subnet_group" "this" {
          + arn         = (known after apply)
          + description = "Database subnet group for airflow-db"
          + id          = (known after apply)
          + name        = (known after apply)
          + name_prefix = "airflow-db-"
          + tags        = {
              + "Name" = "airflow-db"
            }
        }
    
    Plan: 60 to add, 0 to change, 0 to destroy.
    ```
</details>
