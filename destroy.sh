#!/usr/bin/env bash

set +e

cd $(dirname $0)/src

# Use the output of terraform as configuration for the destroy process
jumpbox_dns=$(terraform output jumpbox_dns)
internal_cidr=$(terraform output bosh_subnet_cidr)
internal_gw=$(terraform output bosh_gw)
subnet_id=$(terraform output bosh_subnet)
bosh_ip=$(terraform output bosh_ip)
aws_az=$(terraform output aws_az)
aws_region=$(terraform output aws_region)
# Read the aws access key and secret key
while read -r line; do declare $line; done <terraform.tfvars

# Destroy the bosh director
scp -oStrictHostKeyChecking=no -i ssh/deployer.pem ec2/delete.sh ubuntu@${jumpbox_dns}:/home/ubuntu/
ssh -oStrictHostKeyChecking=no -i ssh/deployer.pem ubuntu@${jumpbox_dns} << EOF
  echo "The bosh director will be destroyed now"
  chmod +x delete.sh
  ./delete.sh "${internal_cidr}" "${internal_gw}" "${bosh_ip}" ${access_key} ${secret_key} "${subnet_id}" "${aws_az}" "${aws_region}" ~/.ssh/bosh.pem
EOF

# Destroy the terraform resources
terraform destroy -force
