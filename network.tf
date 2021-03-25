########################################################################################
## VPC, Subnets, SG, ....
########################################################################################
resource "aws_vpc" "cluster_vpc" {
  cidr_block           =  var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment       = var.cluster_name
    KubernetesCluster = var.cluster_name
    Name              = var.cluster_name
  }
}

resource "aws_subnet" "public_cluster_subnets" {
  count = length(local.azs)

  vpc_id            =  aws_vpc.cluster_vpc.id
  cidr_block        =  cidrsubnet(var.cidr, 8, count.index + 1 + length(local.azs))
  availability_zone =  element(local.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Environment                                 = var.cluster_name
    KubernetesCluster                           = var.cluster_name
    Name                                        = "public-${element(local.azs, count.index)}.${var.cluster_name}"
    SubnetType                                  = "Public"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    region                                      = var.aws_region
  }

}

resource "aws_subnet" "private_cluster_subnets" {
  count             =  length(local.azs)
  vpc_id            =  aws_vpc.cluster_vpc.id
  cidr_block        =  cidrsubnet(var.cidr, 8, count.index + 1)
  availability_zone =  element(local.azs, count.index)

  tags = {
    Environment                                 = var.cluster_name
    KubernetesCluster                           = var.cluster_name
    Name                                        = "private-${element(local.azs, count.index)}-${var.cluster_name}"
    SubnetType                                  = "Private"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_eip" "private_nat_elastic_ips" {
  vpc   = true
  count = length(var.k8s_egress_ips) == 0 ? length(local.azs) : 0

  tags = {
    Environment                                 = var.cluster_name
    KubernetesCluster                           = var.cluster_name
    Name                                        = "${element(local.azs, count.index)}.${var.cluster_name}"
    "kubernetes.io/cluster/${var.cluster_name}"      = "owned"
  }
}

locals {
  nat_elastic_ips =  split(",", length(var.k8s_egress_ips) == 0 ?  join(",", aws_eip.private_nat_elastic_ips.*.id) : join(",", var.k8s_egress_ips))
}

resource "aws_nat_gateway" "private_nat_gateways" {
  depends_on = [aws_eip.private_nat_elastic_ips]

  count         =  length(local.azs)
  allocation_id =  element(local.nat_elastic_ips, count.index)
  subnet_id     =  element(aws_subnet.public_cluster_subnets.*.id, count.index)

  tags = {
    Environment                                 = var.cluster_name
    KubernetesCluster                           = var.cluster_name
    Name                                        = "${element(local.azs, count.index)}.${var.cluster_name}"
     "kubernetes.io/cluster/${var.cluster_name}"      = "owned"
  }
}

resource "aws_route" "route_0_0_0_0__0_private_route" {
  count                  = length(local.azs)
  route_table_id         = element(aws_route_table.private_route_table.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.private_nat_gateways.*.id, count.index)
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.cluster_vpc.id
  count  = length(local.azs)

  tags = {
    Environment                                 = var.cluster_name
    KubernetesCluster                           = var.cluster_name
    Name                                        = "${element(local.azs, count.index)}.${var.cluster_name}"
    "kubernetes.io/cluster/${var.cluster_name}"      = "owned"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = length(local.azs)
  subnet_id      = element(aws_subnet.private_cluster_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.private_route_table.*.id, count.index)
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.cluster_vpc.id

  tags = {
    Environment                                 = var.cluster_name
    KubernetesCluster                           = var.cluster_name
    Name                                        = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}"      = "owned"
  }
}

resource "aws_route" "route_0_0_0_0__0_public_route" {
  route_table_id         =  aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             =  aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.cluster_vpc.id

  tags = {
    Environment                                 = var.cluster_name
    KubernetesCluster                           = var.cluster_name
    Name                                        = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}"      = "owned"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  count          = length(local.azs)
  subnet_id      = element(aws_subnet.public_cluster_subnets.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

data "aws_availability_zones" "az" {
  state = "available"
}
resource "aws_subnet" "private_db_subnets" {
  count             =  2
  vpc_id            =  aws_vpc.cluster_vpc.id
  cidr_block        =  cidrsubnet(var.cidr, 12, count.index + 1)
  availability_zone =   data.aws_availability_zones.az.names[count.index+1]
  tags = {
    private = "true"
  }
}

resource "aws_route_table" "rds_route_table" {
  vpc_id = aws_vpc.cluster_vpc.id
}

resource "aws_route_table_association" "association" {
  count          = 2
  subnet_id      = element(aws_subnet.private_db_subnets.*.id, count.index)
  route_table_id = aws_route_table.rds_route_table.id
}

resource "aws_main_route_table_association" "main_route_table" {
  vpc_id         = aws_vpc.cluster_vpc.id
  route_table_id = aws_route_table.rds_route_table.id
}
data "aws_route53_zone" "hosted_zone" {
    zone_id= var.public_hosted_zone_id
}

