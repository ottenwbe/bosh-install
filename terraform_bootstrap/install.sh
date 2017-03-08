#!/usr/bin/env bash
# Update system
sudo apt -y update
sudo apt -y upgrade

# Install prerequisites
sudo apt -y install git gcc make ruby zlibc zlib1g-dev ruby-bundler ruby-dev build-essential patch libssl-dev bison openssl libreadline6 libreadline6-dev curl git-core libssl-dev libyaml-dev libxml2-dev autoconf libc6-dev ncurses-dev automake libtool

# Install uaac
sudo gem install cf-uaac

# Prepare deployment
git clone https://github.com/cloudfoundry/bosh-deployment ~/workspace/bosh-deployment

# Download and Install bosh-cli
curl -O https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.1-linux-amd64
chmod ugo+x bosh-cli-2.0.1-linux-amd64
sudo mv bosh-cli-2.0.1-linux-amd64 /usr/local/bin/bosh

# Create a directory to keep Director deployment
mkdir -p ~/deployments/bosh-master

cd ~/deployments/bosh-master

echo "-- AWS with UAA --"
bosh create-env ./bosh.yml \
  --state ./state.json \
  -o ../aws/cpi.yml \
  -o ../uaa.yml \
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
  --var-file private_key=./bosh.pem

