data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "${path.module}/../network/terraform.tfstate"
  }
}

module "database" {
  source = "git::https://gitlab.com/eponas/epona.git//modules/aws/patterns/database?ref=v0.2.0"

  name = "teams_test"

  username = data.aws_ssm_parameter.username.value
  password = data.aws_ssm_parameter.password.value

  deletion_protection = false

  tags = {
    Owner     = "teams-test"
    ManagedBy = "epona"
  }

  identifier            = "teams-test"
  engine                = "postgres"
  engine_version        = "12.3"
  port                  = 5432
  instance_class        = "db.t3.micro"
  allocated_storage     = 5
  max_allocated_storage = 10

  auto_minor_version_upgrade = false
  maintenance_window         = "Sat:22:00-Sat:22:30"

  kms_key_id = module.encryption_key.keys["alias/teams-test-encryption-key"].key_arn

  vpc_id            = data.terraform_remote_state.network.outputs.network.vpc_id
  availability_zone = "ap-northeast-1a"

  db_subnets           = data.terraform_remote_state.network.outputs.network.private_subnets
  db_subnet_group_name = "teams-test-db-subnet-group"

  parameter_group_name              = "teams-test-parameter-group"
  parameter_group_family            = "postgres12"
  option_group_name                 = "teams-test-option-group"
  option_group_engine_name          = "postgres"
  option_group_major_engine_version = "12"
  performance_insights_kms_key_id   = module.encryption_key.keys["alias/teams-test-encryption-key"].key_arn
  option_group_options              = []
  backup_retention_period           = 0
  backup_window                     = "06:00-07:00"
  skip_final_snapshot               = true
}

