#!/usr/bin/env bash

echo " --Update system-- "
sudo apt -y update
sudo apt -y upgrade

# Install prerequisites
sudo apt -y install git gcc make ruby zlibc zlib1g-dev ruby-bundler ruby-dev build-essential patch libssl-dev bison openssl libreadline6 libreadline6-dev curl git-core libssl-dev libyaml-dev libxml2-dev autoconf libc6-dev ncurses-dev automake libtool

# Install uaac
sudo gem install cf-uaac

echo " --Preparing deployments-- "
git clone https://github.com/cloudfoundry/bosh-deployment ~/workspace/bosh-deployment

echo " --Download and Install bosh-cli-- "
curl -O https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.1-linux-amd64
chmod ugo+x bosh-cli-2.0.1-linux-amd64
sudo mv bosh-cli-2.0.1-linux-amd64 /usr/local/bin/bosh

echo " --Create a directory for the director-- "
mkdir -p ~/deployments/bosh-master

cd ~/deployments/bosh-master

echo "-- Trigger BOSH deployment for AWS with UAA --"
bosh create-env ~/workspace/bosh-deployment/bosh.yml \
  --state ./state.json \
  -o ~/workspace/bosh-deployment/aws/cpi.yml \
  -o ~/workspace/bosh-deployment/uaa.yml \
  --vars-store ./creds.yml \
  -v director_name=bosh-master-director \
  -v internal_cidr=$1 \
  -v internal_gw=$2 \
  -v internal_ip=$3 \
  -v access_key_id=$4 \
  -v secret_access_key=$5 \
  -v az=eu-central-1a \
  -v region=eu-central-1 \
  -v default_key_name=bosh \
  -v default_security_groups=[bosh] \
  -v subnet_id=$6 \
  --var-file private_key=~/bosh.pem

# Log in to the Director
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int ./creds.yml --path /admin_password`

# Alias deployed Director
bosh -e $3 --ca-cert <(bosh int ./creds.yml --path /director_ssl/ca) alias-env bosh-1

# Update cloud config -- single az
bosh -n -e bosh-1 update-cloud-config ~/workspace/bosh-deployment/aws/cloud-config.yml \
  -v az=us-east-1b \
  -v subnet_id=$6 \
  -v internal_cidr=$1 \
  -v internal_gw=$2

# Install cloud config and

# Upload a stemcell
bosh -e bosh-1 upload-stemcell https://bosh.io/d/stemcells/bosh-aws-xen-hvm-ubuntu-trusty-go_agent?v=3363.9
