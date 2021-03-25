########################################################################################
## Terraform file for elasticsearch deployment
########################################################################################

terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
  shared_credentials_file = "~/.aws/credentials"
}


locals {
  azs              =  slice(data.aws_availability_zones.azs.names,0,var.k8s_az_count)
  addons_max_count =  length(local.azs)
}
data "aws_availability_zones" "azs" {
  state = "available"
}
