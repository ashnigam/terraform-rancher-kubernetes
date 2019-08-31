# terraform-rancher-kubernetes

#### Make sure that terraform cli is installed
#### Create S3 bucket to store terraform state
#### Create AWS key pair to access EC2 instances
#### Edit security group attached to VPC to include your public IP in inbound rules
#### Install RKE in local host
#### Generate config.yml file for cluster creation using rke config command
#### Ensure ubuntu user is part of docker group in agent node
'''
usermod -aG docker ubuntu
'''
