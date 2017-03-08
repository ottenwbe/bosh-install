# Install BOSH and UAA on AWS #


#Manual Deployment

## Install inception VM ##

1. Configure your AWS (for details see [bosh.io](https://bosh.io/docs/init-aws.html); NOTE: Do not perform the bosh-init steps, this will be done in the remainder of this guide; only prepare your AWS)
    1. Create a Virtual Private Cloud (VPC) with a Single Public Subnet
    1. Create an Elastic IP 
    1. Create a Key Pair - Ouput: bosh.pem
    1. Create and Configure Security Group
1. Setup an inception vm via the AWS console
    1. Manually start an Ubuntu machine in the ec2 management console
    1. Make sure that the instance is running in the bosh network
1. ssh to inception vm
1. Install gcc, ruby, and other prerequisites
    ```sh
    sudo apt -y install git gcc make ruby zlibc zlib1g-dev ruby-bundler ruby-dev build-essential patch libssl-dev bison openssl libreadline6 libreadline6-dev curl git-core libssl-dev libyaml-dev libxml2-dev autoconf libc6-dev ncurses-dev automake libtool
    ```
    
## Install bosh via bosh-cli v2
1. SCP prepared keys (bosh.pem etc., see step 1 of aws installation) to the inception vm.
1. Clone bosh deployment repository
   ```
   git clone https://github.com/cloudfoundry/bosh-deployment.git
    ```
1. Install bosh-cli
    ```
    wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.1-linux-amd64
    mv bosh-cli-2.0.1-linux-amd64 bosh
    chmod +x bosh
    sudo mv bosh /usr/local/bin
    ```
1. Follow bosh-deployment instructions to deploy bosh
    1. Make sure your AWS bosh-director has a public ip 
    1. Shortcut for stemcell:
         ```
        bosh -e bosh-1 upload-stemcell https://bosh.io/d/stemcells/bosh-aws-xen-hvm-ubuntu-trusty-go_agent
        ```
        
## Configure UAA ##
1. gem install cf-uaac
1. Extract root ca to uaa.pem from creds.yml
1. Login to uaa via credentials from creds.yml
    ```
    uaac target https://10.0.0.XX:8443 --ca-cert uaa.pem
    uaac token client get admin
    ```
    
### Test team functionality of bosh ###

#### Reader ####
1. Create a bosh.reader group
1. Create a user in the rule
1. Login with the user
1. Try to upload a new stemcell, which fails since bosh.readers do not have the rights:
    ```
    bosh -e bosh-1 upload-stemcell bosh-stemcell-3363.1-aws-xen-hvm-ubuntu-trusty-go_agent.tgz 
    Using environment '10.0.0.XX' as '?'
    ######################################################## 199.55% 117.32 MB/s -3s
    Uploading stemcell file:
      Director responded with non-successful status code '401' response '{"code":600000,"description":"Require one of the scopes: bosh.admin, bosh.413d6e27-371f-415f-9686-bda42dc2fd19.admin"}'
    ```
    
##### Team admin #####
1. Before deploying the director add bosh.teams.*.admin to the scope in the uaa (i.e., uaa.yml in the bosh deployment folder)
1. Create a bosh.teams.test.admin group
1. Upload a release as bosh.admin
1. login as team admin
1. upload release

# Automation #

## Bootstrap via Terraform ## 
1. Use Terraform to set up AWS inception vm
    1. See: [Detailed Instructions](terraform_bootstrap/REAME.md)
    