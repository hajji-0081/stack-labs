########################################################################################
## Terraform file for elasticsearch deployment
########################################################################################

terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "nx_profile"
}


locals {
  azs              =  slice(data.aws_availability_zones.azs.names,0,var.k8s_az_count)
  bastion_dns      = "bastion.${var.cluster_name}.${data.aws_route53_zone.hosted_zone.name}"
  addons_max_count =  length(local.azs)
}
data "aws_availability_zones" "azs" {
  state = "available"
}
