#!/usr/bin/env bash

set +e

cd bootstrap

# Generate keys for rollout and bosh
mkdir -p ssh
#TODO: add the keys in the workflow
#ssh-keygen -t rsa -C "insecure-deployer" -P '' -f ssh/insecure-deployer
#ssh-keygen -t rsa -C "bosh" -P '' -f ssh/bosh


# Deploy Inception VM
terraform plan --out=plan
terraform apply plan
