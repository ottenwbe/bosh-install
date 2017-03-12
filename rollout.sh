#!/usr/bin/env bash

set +e

deployer_key="deployer"
deployer_path=ssh/${deployer_key}
deployer_pem="${deployer_path}.pem"

cd bootstrap

# Generate keys for the rollout (deployer.pem/pub) and the bosh rollout (bosh.pub/.pem) in the sub directory ssh
mkdir -p ssh
if [ ! -f ${deployer_pem}  ]
then
    ssh-keygen -t rsa -C "${deployer_key}" -P '' -f ${deployer_path} -b 4096
    mv ${deployer_path} ${deployer_pem}
    chmod 400 ${deployer_pem}
fi
if [ ! -f ssh/bosh.pem  ]
then
    ssh-keygen -t rsa -C "bosh" -P '' -f ssh/bosh -b 4096
    mv ssh/bosh ssh/bosh.pem
    chmod 400 ssh/bosh.pem
fi

# Deploy the nat instance, jumpbox instance with terraform; moreover trigger the script to create a bosh director
terraform plan --out=plan
terraform apply plan
