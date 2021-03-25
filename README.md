# AWS RDS infrastructure template

This aws infrastructure template provision an RDS instancen in two private subnets and create a bastion into a public subnet for database access.
The template either creates a new database or restores one from a snapshot. Some variables in terraform.tfvars are mandatory or not depending of your needs. Variables are explained in comments in terraform.tfvars.sample file.


### Infrastructure provisioning
- `cp terraform.tfvars.sample terraform.tfvars`
-  Configure terraform.tfvars.
- `./launch_toolbox.sh`: This script will lead you to a shell on the cloud toolbox docker container.
- `aws_configure_role.sh`: Follow the instructions and enter your aws credentials (nx-bastion account), and the role arn to be assumed.
- `deploy_infra.sh`: This script will launch the infrastructure provisioning.

#### Connection

From the cloud toolbox container you can ssh to the bastion instance:
`ssh -i .ssh/id_rsa ec2-user@<bastion_ip>` (provided in terraform output, in the end of deploy_infra.sh command)

The RDS instance administrator can connect the default postgres database with:
`psql -h <endpoint> -U <master_username> -d postgres`

Provide the password configured in terraform.tfvars and you should be able to connect.

More information on confluence [page](https://docs.neoxam.com/display/NXaaS/aws-rds+template) and [page](https://docs.neoxam.com/pages/viewpage.action?pageId=440598697)
