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

### What is Terraform? ###

An IaaS automation tool. It allows you to define your own infrastructure (network, compute, storage, ...) as code.

## Target Environment ##

<img src="res/infrastructure.pdf" alt="infrastructure"  width="800" height="600inch">

The jumpbox instance can be accessed by you via ssh and has all tools to manage bosh and UAA already installed.
The jupbox is therefore placed in a public network.

The bosh director is placed in a private network and cannot be accessed from the Internet.

The NAT instance allows our bosh director to access the internet although the latter is place in the private network.



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
    
```    
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

```bash
cd src
touch terraform.tfvars
echo "access_key=...
secret_key=..." >> terraform.tfvars
```

The destroy script will make use of the variables. To this end, make sure that there is no whitespace in each line.
This also means, if you do not want to keep your credentials in a file, you have to modify the destroy script!

### The One with the Infrastructure as Code ###

___TODO___

#### The VPC ###

```hcl-terraform
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "bosh-terraform-vpc"
  }
}
```

#### Security Groups ###

```hcl-terraform
resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "SSH access to instances from the internet"
  vpc_id      = "${aws_vpc.default.id}"
  
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags {
    Name = "ssh sg"
  }

}

/* Security group for the nat instance */
resource "aws_security_group" "vpc_nat" {
  name        = "vpc_nat"
  description = "Allow traffic to pass from the private subnet to the internet"
  vpc_id      = "${aws_vpc.default.id}"
  
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "NATSG"
  }
}

resource "aws_security_group" "bosh" {
  name        = "bosh"
  description = "Security group for bosh vms"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  tags {
    Name = "bosh sg"
  }
}
```

#### Subnets ###

```hcl-terraform
/** internet access */
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

/** public subnet for the nat instance and the jumpbox */
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.public_subnet_cidr}"
  availability_zone       = "${var.default_az}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.default"]

  tags {
    Name = "public-net"
  }
}

/** private network for the bosh managed vms */
resource "aws_subnet" "bosh" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.bosh_subnet_cidr}"
  availability_zone       = "${var.default_az}"
  map_public_ip_on_launch = false
  depends_on              = ["aws_instance.nat"]

  tags {
    Name = "bosh-net"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
}

resource "aws_route_table" "bosh" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }

  tags {
    Name = "Private Subnet"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "bosh" {
  subnet_id      = "${aws_subnet.bosh.id}"
  route_table_id = "${aws_route_table.bosh.id}"
}
```

### Putting it a all together ###

Execute the rollout script which triggers the deployment.

```
./rollout.sh
```

### Cleaning Up ###

```bash
./destroy.sh
```