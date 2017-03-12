# Tutorial: Deploy BOSH and UAA on AWS with Terraform #

__NOTE: This tutorial and all scripts are still WIP!__

This guide explains how to setup a bosh environment on AWS with terraform.
For those interested in deploying bosh manually, I provide an additional guide (see [Manual Deployment](MANUAL.md)).

## NOTE ##

Before you follow this guide you should be aware that you will create real resources on AWS. 
In particular, the guide requires more resources than included in Amazon's free tier. 
Obviously, I will not provide compensation for any of the costs for the reources.  

## Dependencies ##
The tutorial will make use of the following software components. 
No worries, you do not need to install them right now.
We will come back to the individual tools when we need them.

| Dependendcy  | URL |
|---|---|
| Bosh  | http://bosh.io  |
| Terraform  |  http://bosh.io  |
| UAA  |  https://github.com/cloudfoundry/uaa |   
| Bosh Deployment  | https://github.com/cloudfoundry/bosh-deployment  |


## Quickstart for the impatient ##

1. Clone the git repository of this guide, which provides all required terraform HCL files.
    
    ```bash
    git clone https://github.com/ottenwbe/bosh-install.git
    cd bosh-install
    ```
    
    The following outline gives a brief glimpse at the most important files:
    
    ```bash    
    ├── destroy.sh
    ├── rollout.sh
    └── src
        ├── bin
        │   ├── delete.sh
        │   └── install.sh
        ├── ssh
        │   ├── bosh.pem
        │   ├── bosh.pub
        │   ├── deployer.pem
        │   └── deployer.pub        
        ├── aws-vpc.tf        
        ├── jumpbox.tf
        ├── key-pairs.tf
        ├── nat.tf
        ├── outputs.tf
        ├── security-groups.tf
        ├── subnets.tf
        └── variables.tf       
    ```
    
1. Install [terraform](https://www.terraform.io/intro/getting-started/install.html) if you haven't done that already

    ```bash
    curl -fSL "https://releases.hashicorp.com/terraform/0.8.8/terraform_0.8.8_linux_amd64.zip" -o terraform.zip
    sudo unzip terraform.zip -d /opt/terraform
    sudo ln -s /opt/terraform/terraform /usr/bin/terraform
    rm -f terraform.zip
    ```

1. Create a ```terraform.tfvars``` file in the src directory which includes your AWS Key and Secret Key 
   
    ```bash
    cd src
    touch terraform.tfvars
    echo "access_key=...
    secret_key=..." >> terraform.tfvars
    ```
    
 1. Execute the rollout script to 

    ```bash
    ./rollout.sh
    ```

 2. To destroy you environment 

    ```bash
    ./destroy.sh
    ```
    
## Detailed Guide ##

__WIP__

1. Clone the git repository of this guide, which provides all required terraform HCL files.
    
    ```bash
    git clone https://github.com/ottenwbe/bosh-install.git
    cd bosh-install
    ```
    
1. Install [terraform](https://www.terraform.io/intro/getting-started/install.html) if you haven't done that already

    ```bash
    curl -fSL "https://releases.hashicorp.com/terraform/0.8.8/terraform_0.8.8_linux_amd64.zip" -o terraform.zip
    sudo unzip terraform.zip -d /opt/terraform
    sudo ln -s /opt/terraform/terraform /usr/bin/terraform
    rm -f terraform.zip
    ```

1. Create a local file ```terraform.tfvars``` to hold your aws credentials. Otherwise you have to retype the credentials with every change.
    ```
    access_key = "..."
    secret_key = "..."
    ```
1. Execute the rollout script 
    ```
    ./rollout.sh
    ```