#!/usr/bin/env bash

cd terraform_bootstrap

# Generate key for rollout
ssh-keygen -t rsa -C "insecure-deployer" -P '' -f ssh/insecure-deployer

# Deploy Inception VM
terraform plan
terraform apply
