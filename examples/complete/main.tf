provider "aws" {
  region = local.region

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

locals {
  name   = "complete-example"
  region = "eu-west-1"

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

data "aws_caller_identity" "current" {}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2"

  name = local.name
  cidr = "10.99.0.0/18"

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets   = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets  = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
  intra_subnets    = ["10.99.6.0/24", "10.99.7.0/24", "10.99.8.0/24"]
  database_subnets = ["10.99.9.0/24", "10.99.10.0/24", "10.99.11.0/24"]
  redshift_subnets = ["10.99.12.0/24", "10.99.13.0/24", "10.99.14.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_dedicated_network_acl       = true
  private_dedicated_network_acl      = true
  intra_dedicated_network_acl        = true
  create_database_subnet_route_table = true
  database_dedicated_network_acl     = true
  create_redshift_subnet_route_table = true
  redshift_dedicated_network_acl     = true

  default_network_acl_name = local.name
  default_network_acl_ingress = [
    {
      "action" : "deny",
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_no" : 5,
      "to_port" : 0
    }
  ]
  default_network_acl_egress = [
    {
      "action" : "deny",
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_no" : 5,
      "to_port" : 0
    }
  ]

  tags = local.tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3"

  name        = local.name
  description = "Example security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_self = [
    {
      rule        = "https-443-tcp"
      description = "Allow all internal HTTPs"
    },
  ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = local.tags
}

module "security_group_alt" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3"

  name        = "${local.name}-a"
  description = "Example security group"
  vpc_id      = module.vpc.vpc_id

  tags = local.tags
}

data "aws_iam_policy_document" "example" {
  statement {
    sid       = "Example"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

################################################################################
# Module
################################################################################

module "endpoints" {
  source = "../.."

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.security_group.this_security_group_id]

  gateway_endpoints = {
    s3 = {
      service             = "s3"
      private_dns_enabled = true
      route_table_ids     = module.vpc.private_route_table_ids
      policy              = data.aws_iam_policy_document.example.json
      tags                = { Name = "s3-vpc-endpoint" }
    },
    dynamodb = {
      service         = "dynamodb"
      route_table_ids = module.vpc.private_route_table_ids
      tags            = { Name = "dynamodb-vpc-endpoint" }
    }
  }

  interface_endpoints = {
    sns = {
      service    = "sns"
      subnet_ids = module.vpc.private_subnets
      tags       = { Name = "sns-vpc-endpoint" }
    },
    sqs = {
      service             = "sqs"
      private_dns_enabled = true
      security_group_ids  = [module.security_group_alt.this_security_group_id]
      subnet_ids          = module.vpc.intra_subnets
      tags                = { Name = "sqs-vpc-endpoint" }
    },
  }

  tags = local.tags
}
