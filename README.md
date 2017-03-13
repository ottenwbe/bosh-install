# Guide: Deploy BOSH and UAA on AWS with Terraform #

[![Build Status](https://travis-ci.org/ottenwbe/bosh-install.svg?branch=master)](https://travis-ci.org/ottenwbe/bosh-install)

__NOTE: This tutorial and all scripts are still WIP!__

In this guide I explain how you can setup a bosh environment on AWS with terraform.
For those interested in deploying bosh manually, I provide an additional guide (see [Manual Deployment](MANUAL.md)).

## A Word of Caution ##

Before you follow this guide you should be aware that you will create real resources on AWS. 
In particular, the guide requires that you deploy more resources than included in Amazon's free tier, i.e., two t2.small and one m3.xlarge instance. 
Obviously, I will not provide compensation for any costs.  

## Dependencies ##

The guide will make use of the following software components. 
No worries, you do not need to install them right now.
We come back to the individual tools when we need them.

| Component  | URL | Purpose |
|---|---|---|
| Bosh  | http://bosh.io  | The service we want to deploy on AWS |
| Terraform  |  http://terraform.io | Bootstrapping of the bosh infrastructure |
| UAA  |  https://github.com/cloudfoundry/uaa | (Optional) User management for bosh |   
| Bosh Deployment  | https://github.com/cloudfoundry/bosh-deployment  | Bosh templates for the deployment of bosh |

### What is Bosh? ###

Bosh is a tool to orchestrate services in the cloud. 
It supports you in the release engineering, deployment, and lifecycle management of cloud software.

### What is Terraform ###

An IaaS automation tool. It allows you to define your own infrastructure (network, compute, storage, ...) as code.

## What is our Target Environment? ##

<img src="res/infrastructure.pdf" alt="infrastructure"  width="800" height="400">

___TODO: explain the setup with a figure___

## Quickstart for the Impatient ##

For those of you who just want to get an environment up and running, the following tutorial may suffice.
However, this part of the guide is only recommended for those who have prior experience with both, Terraform and Bosh. 

1. Clone the git repository of this guide, which provides all required terraform HCL files.
    
    ```bash
    git clone https://github.com/ottenwbe/bosh-install.git
    cd bosh-install
    ```

1. Install [terraform](https://www.terraform.io/intro/getting-started/install.html), if you haven't done that already.

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
    
1. Execute the rollout script to deploy a jumbox and from there a bosh director. For internet access an auxiliary nat instance will be rolled out. 
 
     ```bash
     ./rollout.sh
     ```

1. To destroy your environment after you finished the tutorial, execute the destroy script. You may want to go through your AWS console to make sure that everything is destroyed as planned. 

    ```bash
    ./destroy.sh
    ```
    
## Detailed Guide ##

__WIP__

We now want to take a deeper look into the setup.

### The Guide's Sources ###

In order to get all terraform resources, clone the git repository of this guide.
    
```bash
git clone https://github.com/ottenwbe/bosh-install.git
cd bosh-install
```
    
The following outline gives a brief glimpse at the most important files:
    
```bash    
├── destroy.sh                  Script to cleanup the environment on AWS
├── rollout.sh                  Script to rollout the environment on AWS
└── src                         All terraform resources and corresponding scripts
    ├── bin                     Scripts that are executed on ec2 instances after the rollout
    │   ├── delete.sh
    │   └── install.sh
    ├── ssh                     Generated ssh keys
    │   ├── bosh.pem
    │   ├── bosh.pub
    │   ├── deployer.pem
    │   └── deployer.pub        
    ├── aws-vpc.tf              Describes our VPC on AWS
    ├── jumpbox.tf              Defines the jumpbox instance
    ├── nat.tf                  Desfines the NAT instance
    ├── security-groups.tf      Defines the access to our instances
    ├── subnets.tf              Defines the networks and routing tables 
    ├── key-pairs.tf            Describes the key pairs, see ssh folder
    ├── outputs.tf              Useful outputs, i.e., for the cleanup (destroy.sh)
    └── variables.tf       
```
    
### Set up your local ###    

Install [terraform](https://www.terraform.io/intro/getting-started/install.html) if you haven't done that already.

```bash
curl -fSL "https://releases.hashicorp.com/terraform/0.8.8/terraform_0.8.8_linux_amd64.zip" -o terraform.zip
sudo unzip terraform.zip -d /opt/terraform
sudo ln -s /opt/terraform/terraform /usr/bin/terraform
rm -f terraform.zip
```

Create a local file ```terraform.tfvars``` to hold your aws credentials. Otherwise you have to retype the credentials with every change.

```
cd src
touch terraform.tfvars
echo "access_key=...
secret_key=..." >> terraform.tfvars
```

The destroy script will make use of the variables. To this end, make sure that there is no whitespace in each line.
This also means, if you do not want to keep your credentials in a file, you have to modify the destroy script!

### The One with the Infrastructure as Code ###

___TODO___

### Putting it a all together ###

Execute the rollout script which triggers the deployment.

```
./rollout.sh
```

### Cleaning Up ###

```bash
./destroy.sh
```