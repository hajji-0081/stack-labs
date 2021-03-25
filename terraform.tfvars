#--------------------------------------------------------------
# General
#--------------------------------------------------------------
# mandatory aws region for deployment
aws_region = "us-east-2"
#--------------------------------------------------------------
# Network
#--------------------------------------------------------------
# override main cidr VPC, if not specified default value 10.0.0.0/16 will be used
cidr = "10.0.0.0/16"

# mandatory whitelisted ips which are allowed to make DH requests
source_range = ["89.225.236.186/32", "62.23.162.103/32"]

# required identifier must be unique
identifier="terraformtest11"

#The port on which the load balancer is listening
alb_listener_port=443

#The protocol for connections from clients to the load balancer
alb_listener_protocol="HTTPS"

#The absolute path, starting with the leading "/"
alb_path="/nx-impress/"

#The ARN of the default SSL server certificate
alb_certificate_arn="arn:aws:acm:us-east-2:766272829042:certificate/36a94f45-6b3c-4d85-9a1d-9a0d7528284b"

#mandatory AWS Route53 zone which are managing the public DNS
public_hosted_zone_id = "ZMCBYWN144XZ9"

#--------------------------------------------------------------
# DataBase
#--------------------------------------------------------------
# Specifies the name of the database engine.
# If db_snapshot_identifier is set some other variables like engine, engine_version are overridden from the snapshot
# Required unless a snapshot_identifier is provided
engine="postgres"

# Required unless a snapshot_identifier is provided
engine_version="11.5"

# required, db.m5.large is the minimal class for oracle database
instance_class="db.t2.micro"

# Required unless a snapshot_identifier is provided
allocated_storage="20"

# Required unless a snapshot_identifier is provided
storage_type="gp2"

# Required unless a snapshot_identifier is provided
port="5432"

# Determines whether a final DB snapshot is created before the DB instance is deleted.
# using the value from final_snapshot_identifier" 
# Default to true which means no DBSnapshot is created.
# skip_final_snapshot= false

# required if skip_final_snapshot is set to false
# final_snapshot_identifier=""

# RDS db will be restored from this snapshot, if empty a new db will be created
db_snapshot_identifier=""

# DBName must begin with a letter and contain only alphanumeric characters
# Optional unless a db_snapshot_identifier is provided
# The name of the database to create when the DB instance is created. If this parameter 
# is not specified, no database is created in the DB instance. Note that this does not apply for Oracle or SQL Server engines.
name="terraform"

# Required unless a snapshot_identifier is provided
# Username for the master DB user.
username="terraform"

# Required unless a snapshot_identifier is provided
# Password for the master DB user, must be more than 8 characters
password= "terraformterraform"

#--------------------------------------------------------------
# Compute
#--------------------------------------------------------------
# Number of EC2 default 2
instance_count=2

# Type of instance to start
instance_type="t2.micro"

# Size of the volume in gibibytes
volume_size=30
//mandatory eks cluster name
cluster_name = "clustertest11"

//mandatory external ips which are allowed to connect the Kubernetes API
k8s_api_source_ranges = ["89.225.236.186/32", "62.23.162.103/32"]

//mandatory number of availability zones
k8s_az_count  = "2"

k8s_workers_instance_type = "t2.medium"
//optional maximum workers for autoscaling group default to 10
//k8s_workers_max_count = ""
//mandatory minimum workers for autoscaling group.
k8s_workers_min_count = "2"

//mandatory AWS Route53 zone which are managing the public DNS
