resource "aws_db_subnet_group" "db" {

  name_prefix = var.identifier
  description = "Database subnet group for var.identifier"
  subnet_ids  = aws_subnet.private_db_subnets.*.id

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "var.identifier")
    },
  )
}


#resource "aws_db_instance" "new_rds" {
 # identifier           = var.identifier
 # allocated_storage    = var.allocated_storage
 # storage_type         = var.storage_type
 # engine               = var.engine
 # engine_version       = var.engine_version
 # instance_class       = var.instance_class
 # port                 = var.port
 # name                 = var.name
 # username             = var.username
 # password             = var.password
 # vpc_security_group_ids = [aws_security_group.rds_security_group.id]
 # db_subnet_group_name = aws_db_subnet_group.db.name
#}
resource "aws_security_group" "rds_security_group" {
  name   = "rds-sg"
  vpc_id =  aws_vpc.cluster_vpc.id
}

resource "aws_security_group_rule" "db_access" {
  security_group_id = aws_security_group.rds_security_group.id
  description       = "database access"
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "db_egress" {
  security_group_id = aws_security_group.rds_security_group.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
