#!/usr/bin/env bash

set +e

deployer_key="deployer"
deployer_path=ssh/${deployer_key}
deployer_pem="${deployer_path}.pem"

bosh_key="bosh"
bosh_path=ssh/${bosh_key}
bosh_pem="${bosh_path}.pem"

cd $(dirname $0)/src

# Generate keys for the rollout (deployer.pem/pub) and the bosh rollout (bosh.pub/.pem) in the sub directory ssh
mkdir -p ssh
if [ ! -f ${deployer_pem}  ]
then
    ssh-keygen -t rsa -C "${deployer_key}" -P '' -f ${deployer_path} -b 4096
    mv ${deployer_path} ${deployer_pem}
    chmod 400 ${deployer_pem}
fi
if [ ! -f ${bosh_pem}  ]
then
    ssh-keygen -t rsa -C "${bosh_key}" -P '' -f ${bosh_path} -b 4096
    mv ${bosh_path} ${bosh_pem}
    chmod 400 ${bosh_pem}
fi

# Deploy the nat instance, jumpbox instance with terraform; moreover trigger the script to create a bosh director
terraform plan --out=plan
terraform apply plan
