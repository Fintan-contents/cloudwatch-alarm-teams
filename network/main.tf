module "network" {
  source = "git::https://gitlab.com/eponas/epona.git//modules/aws/patterns/network?ref=v0.2.0"

  name = "teams-test"

  tags = {
    Owner     = "teams-test"
    ManagedBy = "epona"
  }

  cidr_block = "192.168.0.0/16"

  availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]

  public_subnets             = ["192.168.1.0/24", "192.168.2.0/24"]
  private_subnets            = ["192.168.3.0/24", "192.168.4.0/24"]
  nat_gateway_deploy_subnets = ["192.168.1.0/24", "192.168.2.0/24"]
}

output "network" {
  value = module.network
}