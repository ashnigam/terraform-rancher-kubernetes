terraform {
  backend "s3" {}
}

provider "aws" {
  version = "~> 2.1"
  region  = "us-west-2"
}

module "kub-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  cidr               = "10.228.0.0/16"
  name               = "kub-vpc"
  azs                = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets    = ["10.220.0.0/24", "10.220.1.0/24", "10.220.2.0/24"]
  public_subnets     = ["10.220.32.0/24", "10.220.33.0/24", "10.220.34.0/24"]
  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "rancher-server" {
    source = "./rancher-server"
    rancher_subnet = module.kub-vpc.public_subnets[0]
}