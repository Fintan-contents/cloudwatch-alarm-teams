module "encryption_key" {
  source = "git::https://gitlab.com/eponas/epona.git//modules/aws/patterns/encryption_key?ref=v0.2.0"

  kms_keys = [
    { alias_name = "alias/teams-test-encryption-key" }
  ]

  tags = {
    Owner     = "teams-test"
    ManagedBy = "epona"
  }
}

locals {
  secrets = jsondecode(file("./secrets.json"))
}

module "parameter_store" {
  source = "git::https://gitlab.com/eponas/epona.git//modules/aws/patterns/parameter_store?ref=v0.2.0"

  parameters = [
    {
      name   = "/db/username"
      value  = local.secrets.db_username
      type   = "SecureString"
      key_id = module.encryption_key.keys["alias/teams-test-encryption-key"].key_alias_name
    },
    {
      name   = "/db/password"
      value  = local.secrets.db_password
      type   = "SecureString"
      key_id = module.encryption_key.keys["alias/teams-test-encryption-key"].key_alias_name
    },
  ]
}

data "aws_ssm_parameter" "username" {
  depends_on = [module.parameter_store]
  name       = module.parameter_store.parameters["/db/username"].name
}

data "aws_ssm_parameter" "password" {
  depends_on = [module.parameter_store]
  name       = module.parameter_store.parameters["/db/password"].name
}
