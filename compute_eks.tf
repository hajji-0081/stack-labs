########################################################################################
## EKS Cluster
########################################################################################

locals {
  subnets =  concat(aws_subnet.private_cluster_subnets.*.id, aws_subnet.public_cluster_subnets.*.id)
}

resource "aws_eks_cluster" "cluster" {

  name     =  var.cluster_name
  role_arn =  aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids         = local.subnets
  }
}
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"
  description = "Allow cluster to manage node groups, fargate nodes and cloudwatch logs"
  force_detach_policies = true
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks.amazonaws.com",
          "eks-fargate-pods.amazonaws.com"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy1"{
policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
role       = aws_iam_role.eks_cluster_role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController1" {
policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
role       = aws_iam_role.eks_cluster_role.name
}
locals {
  kubeconfig = <<KUBECONFIG

apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.cluster.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster_name}"
        - "-r"
        - "${var.ROLE_ARN}"
KUBECONFIG
}

resource "local_file" "cluster_config" {
  content  =  local.kubeconfig
  filename = "${path.root}/.kube/config"
}

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH

apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.eks_node_group_role.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

resource "local_file" "aws_auth" {
  content  = local.config_map_aws_auth
  filename = "${path.root}/.kube/aws_auth.yaml"
}

resource "local_file" "eks_admin" {
  content  = file("${path.root}/data/eks_admin.yaml")
  filename = "${path.root}/.kube/eks_admin.yaml"
}
