#Global varaibles
variable "aws_region" {
  type        = string
  default     = "eu-west-3"
}

variable "cidr" {
  type = string
}

variable "source_range" {
  description = "The source adress allowed to connect to bastion, default to neoxam adresses"
  default =  ["89.225.236.186/32", "62.23.162.103/32"]
}

variable "identifier" {
  description = "The identifier of the resource"
  type        = string
}

#DataBase varaibles
variable "engine" {
  description = "engine of the database"
  type        = string
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
}

variable "instance_class" {
  type = string
}

variable "name"{
  description = "The name of the database to create when the DB instance is created"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  type = string
  default = "dummy"
}

variable "allocated_storage" {
  type = string
}

variable "storage_type" {
  type = string
}

variable "db_snapshot_identifier" {
  type = string
}

variable "username"{
  type = string
}

variable "password" {
  type = string
}

variable "port" {
  type = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

#Bastin variables
variable "ssh_pub_key" {
  description = "The key used for the EC2 instance creation"
  default     = ".ssh/id_rsa.pub"
}

variable "ssh_key" {
  default     = ".ssh/id_rsa"
}

#Route 53 variables

variable "public_hosted_zone_id" {}
variable "cluster_name" {}

variable "k8s_workers_max_count" {
  default = 10
}

variable "k8s_workers_min_count" {
  default = 1
}
variable "eks_k8s_version" {
  default = "1.14"
}
variable "k8s_az_count" {
  default = 2
}
variable "k8s_egress_ips" {
  type    = list(string)
  default = []
}
variable "ROLE_ARN" {
  default =""
}
