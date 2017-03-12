#!/usr/bin/env bash

cd bootstrap

scp -i ssh/deployer.pem bin/delete.sh ubuntu@$(terraform output jumpbox_dns):/home/ubuntu/
ssh -i ssh/deployer.pem ubuntu@$(terraform output jumpbox_dns) chmod +x delete.sh; ./delete.sh