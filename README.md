# Guide: Deploy BOSH and UAA on AWS with Terraform #

[![Build Status](https://travis-ci.org/ottenwbe/bosh-install.svg?branch=master)](https://travis-ci.org/ottenwbe/bosh-install)

__NOTE: This tutorial and all scripts are still WIP!__

Modern cloud applications are inherently distributed and often need 
to spin up large numbers of virtual machines to deploy out all required software components.
_Bosh_ is typically the tool of choice in this scenario to orchestrate the application and/or depending software components like data bases. 
Bosh supports an application in the release engineering, deployment, and lifecycle management.

Bosh, however, requires that you set up your basic infrastructure beforehand. You can choose to do this manually. 
But the better approach is to rely on an IaaS automation tool like _terraform_. 
This allows you to define your own infrastructure (network, compute, storage, ...) as code.
Which, in turn, makes a rollout reproducible and tetable.

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

## Target Environment ##

<img src="res/infrastructure.pdf" alt="infrastructure"  width="800" height="600inch">

In our target state you will have rolled out two VMs with terraform 
a _jumpbox_ and a _nat instance_. Moreover, you will rollout with 
 bosh the so-called _bosh-director_. With the director, you will 
 immediately be able to rollout 
 bosh releases.

The jumpbox instance allows you to access
 the environment via ssh and manage your bosh deployments. 
The jumpbox has all tools to manage bosh and UAA already installed.
The VM is therefore placed in a public network.

The bosh director is placed in a private network and cannot be accessed from the Internet. This is where the 
 NAT instance shines. It allows our bosh director to access the internet via http(s), but no other protocol.

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

     
### Preparations ###    

1. Install [terraform](https://www.terraform.io/intro/getting-started/install.html) if you haven't done that already.

    ```bash
    curl -fSL "https://releases.hashicorp.com/terraform/0.8.8/terraform_0.8.8_linux_amd64.zip" -o terraform.zip
    sudo unzip terraform.zip -d /opt/terraform
    sudo ln -s /opt/terraform/terraform /usr/bin/terraform
    rm -f terraform.zip
    ```

1. Create an IAM user in your AWS console. There are several good tutorials out there that can help you here, e.g., https://bosh.io/docs/aws-iam-users.html#create

1. Create a local file ```terraform.tfvars``` to hold your aws credentials. Otherwise you have to retype the credentials with every change.

    ```bash
    cd src
    touch terraform.tfvars
    echo "access_key=...
    secret_key=..." >> terraform.tfvars
    ```

    We will make use of the variables. To this end, make sure that there is no whitespace in each line.
    This also means, if you do not want to keep your credentials in a file, you have to modify parts of the scripts!


### The Structure ###

The following outline gives you a brief glimpse at the project outline that I anticipate throughout the guide:
    
```    
├── destroy.sh                  Script to cleanup the environment on AWS
├── rollout.sh                  Script to rollout the environment on AWS
└── src/                        All terraform resources and corresponding scripts
    ├── bin/                    Scripts that are executed on ec2 instances after the rollout
    │   ├── delete.sh
    │   └── install.sh
    ├── ssh/                    Generated ssh keys        
    ├── aws-vpc.tf              Describes our VPC on AWS
    ├── jumpbox.tf              Defines the jumpbox instance
    ├── nat.tf                  Desfines the NAT instance
    ├── security-groups.tf      Defines the access to our instances
    ├── subnets.tf              Defines the networks and routing tables 
    ├── key-pairs.tf            Describes the key pairs, see ssh folder
    ├── outputs.tf              Useful outputs, i.e., for the cleanup (destroy.sh)
    └── variables.tf       
```

You can always have a peek at a reference implementation of our environment when you clone  the git repository of this guide.
    
```bash
git clone https://github.com/ottenwbe/bosh-install.git
cd bosh-install
```

### The One with the Infrastructure as Code ###

The whole infrastructure is defined in Hashicorp's HCL.

#### Variables ###

At first we define some basic variables in ```variables.tf```. We can reference them later in other terraform files.

```hcl
/** Access key. NOTE: DO NOT DECLARE YOUR ACTUAL KEY HERE */
variable "access_key" {
  description = "Access Key"
}

/** Secret key. NOTE: DO NOT DECLARE YOUR ACTUAL KEY HERE */
variable "secret_key" {
  description = "Secret Access"
}

/** AZ which is used by default during the deployment */
variable "default_az" {
  description = "Default AZ"
  default     = "eu-central-1a"
}

/** Region which is used by default during te rollout */
variable "region" {
  description = "AWS region to host the bosh network"
  default     = "eu-central-1"
}

/** Default GW */
variable "vpc_gw" {
  description = "GW for the vpc"
  default     = "10.0.0.1"
}

/** GW for the bosh network */
variable "bosh_gw" {
  description = "GW for the bosh network"
  default     = "10.0.1.1"
}

variable "bosh_ip" {
  description = "BOSH Director IP"
  default     = "10.0.1.6"
}

/** Default CIDR */
variable "vpc_cidr" {
  description = "CIDR for VPC"
  default     = "10.0.0.0/16"
}

variable "bosh_subnet_cidr" {
  description = "CIDR for bosh subnet"
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  default     = "10.0.0.0/24"
}

/* Ubuntu amis by region */
variable "amis" {
  type        = "map"
  description = "Base AMI to launch the vms"

  default = {
    eu-central-1 = "ami-829145ed"
  }
}

```


#### The VPC ###

At first we have to define our provider (aws) and the virtual private cloud (vpc).
In our example this is defined in ```aws-vpc.tf```.
As you can see in the code snippet below we simply reference variables defined in our variables.tf.

```hcl
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

We now have to define our firewall rules, e.g., to define which inbound traffic is allowed. This is done with security groups. You can associate the firewall rules to vms in order to make them effective on the vm.
We define three security groups. First, the ```ssh``` group which allows inbound ssh traffic from the all destinations in the internet.
Second, a ```nat``` rule, which allows http(s) traffic to servers outside of your vpc.
Third, an any-to-any connection for all ```bosh``` instances. For improved security you can always add more finegranular rules here.

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

We now define our networking in the ```subnets.tf```, including the gateway to the internet.
We also define our two networks. The public network for the internet facing systems, i.e., the nat instance and the 
jumpbox and the private network for bosh. Routing tables ensure that the traffic from the private network towards the internet
is routed over the nat instance.

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

### The instances ###

We now also define the jumpbox and nat instance. Also, we define
 a public IP for the nat instance. 
 For now ignore the fact that no software is installed on the machines. 
 

```hcl-terraform
/** jumpbox instance */
resource "aws_instance" "jumpbox" {
  ami             = "${lookup(var.amis, var.region)}"
  instance_type   = "t2.micro"
  subnet_id       = "${aws_subnet.public.id}"
  security_groups = ["${aws_security_group.bosh.id}", "${aws_security_group.vpc_nat.id}", "${aws_security_group.ssh.id}"]
  key_name        = "${aws_key_pair.deployer.key_name}"

  /* ensure that nat instance and network are up and running */
  depends_on = ["aws_instance.nat", "aws_subnet.bosh"]

/**
  provisioners ...
*/

  tags = {
    Name = "jumphost-vm-${count.index}"
  }
}

/** nat instance */
resource "aws_instance" "nat" {
  ami                         = "${lookup(var.amis, var.region)}"
  availability_zone           = "${var.default_az}"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.bosh.id}", "${aws_security_group.vpc_nat.id}", "${aws_security_group.ssh.id}"]
  subnet_id                   = "${aws_subnet.public.id}"
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = "${aws_key_pair.deployer.key_name}"

  /*provisioner "remote-exec" {
   ...
  }*/

  tags {
    Name = "VPC NAT"
  }
}

resource "aws_eip" "nat" {
  instance = "${aws_instance.nat.id}"
  vpc      = true
}
```

#### Provisioners ####

Jumpbox provisioner

```hcl-terraform
  /** copy the bosh key to the jumpbox */
  provisioner "file" {
    connection {
      user        = "ubuntu"
      host        = "${aws_instance.jumpbox.public_dns}"
      timeout     = "1m"
      private_key = "${file("ssh/deployer.pem")}"
    }

    source      = "ssh/bosh.pem"
    destination = "/home/ubuntu/.ssh/bosh.pem"
  }

  provisioner "file" {
    connection {
      user        = "ubuntu"
      host        = "${aws_instance.jumpbox.public_dns}"
      timeout     = "1m"
      private_key = "${file("ssh/deployer.pem")}"
    }

    source      = "bin/install.sh"
    destination = "/home/ubuntu/install.sh"
  }

  provisioner "remote-exec" {
    connection {
      user        = "ubuntu"
      host        = "${aws_instance.jumpbox.public_dns}"
      timeout     = "25m"
      private_key = "${file("ssh/deployer.pem")}"
    }

    inline = [
      "chmod +x install.sh",
      "./install.sh ${var.bosh_subnet_cidr} ${var.bosh_gw} ${var.bosh_ip} ${var.access_key} ${var.secret_key} ${aws_subnet.bosh.id} ~/.ssh/bosh.pem",
    ]
  }
```

#### Jumpbox ####

Nat provisioner:
```hcl-terraform
  provisioner "remote-exec" {
    connection {
      user        = "ubuntu"
      timeout     = "5m"
      private_key = "${file("ssh/deployer.pem")}"
    }

    inline = [
      "sudo apt -y update",
      "sudo apt -y upgrade",
      "sudo iptables -t nat -A POSTROUTING -j MASQUERADE",
      "echo 1 | sudo tee /proc/sys/net/ipv4/conf/all/forwarding > /dev/null",
    ]
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