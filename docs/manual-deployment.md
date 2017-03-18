
# Manual Installation of Bosh #

This document outlines manual scripts that ar automated in the actual [tutorial](index.md).

## Install inception VM ##

1. Configure your AWS (for details see [bosh.io](https://bosh.io/docs/init-aws.html); NOTE: Do not perform the bosh-init steps, this will be done in the remainder; only prepare your AWS)
    1. [Create a Virtual Private Cloud (VPC) with a Single Public Subnet](https://bosh.io/docs/init-aws.html#create-vpc) 
    1. [Create an Elastic IP]() 
    1. [Create a Key Pair]() - Output: ```bosh.pem```
    1. Create a second pair of keys - Output ```deployer.pem```
    1. [Create and Configure Security Group]()
1. Setup a jumpbox instance on AWS. 
From this machine you will perform the bosh setup.
    1. Manually start an Ubuntu machine in the ec2 management console.
    1. Make sure that the instance is running in the bosh network (see step 1).
1. SSH to the jumpbox instance.
    ```bash
    ssh -i "deployer.pem" ubuntu@< see console for id >
    ```
1. Install gcc, ruby, and other prerequisites on the jumpbox instance.
    ```bash
    sudo apt -y install git gcc make ruby zlibc zlib1g-dev ruby-bundler ruby-dev build-essential patch libssl-dev bison openssl libreadline6 libreadline6-dev curl git-core libssl-dev libyaml-dev libxml2-dev autoconf libc6-dev ncurses-dev automake libtool
    ```
    
## Install bosh via bosh-cli v2
1. SCP prepared key (bosh.pem, see step 1 of aws installation) to the jumpbox instance.
1. Clone bosh deployment repository
   ```bash
   git clone https://github.com/cloudfoundry/bosh-deployment.git
    ```
1. Install the bosh-cli.
    ```bash
    wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.1-linux-amd64
    mv bosh-cli-2.0.1-linux-amd64 bosh
    chmod +x bosh
    sudo mv bosh /usr/local/bin
    ```
1. Follow bosh-deployment instructions to deploy bosh.
    1. For details see https://github.com/cloudfoundry/bosh-deployment
    1. Make sure your AWS bosh-director has a public ip. 
    1. Install stemcell:
         ```
        bosh -e bosh-1 upload-stemcell https://bosh.io/d/stemcells/bosh-aws-xen-hvm-ubuntu-trusty-go_agent
        ```
        
## Configure UAA ##
1. On the jumpbox install the uaac gem
    ```bash
    gem install cf-uaac
    ```
1. Extract root ca to a file uaa.pem from the credentials file creds.yml
1. Login to uaa via credentials from creds.yml
    ```bash
    uaac target https://10.0.0.6:8443 --ca-cert uaa.pem
    uaac token client get admin
    ```
