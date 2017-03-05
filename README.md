# Install BOSH on AWS #

## Install inception VM ##

1. Configure your AWS setup as described on bosh.io
    1. NOTE: Do not perform the bosh-init steps, this will be done in the remainder; only prepare your AWS
    1. see https://bosh.io/docs/init-aws.html   
1. Setup inception vm in your AWS console
    1. Manually start instance in management console
    1. Make sure that the instance is running in the same i
1. ssh to inception vm
1. Install gcc and ruby (TODO: cleanup required)
    ```sh
    sudo apt -y install gcc make ruby zlibc zlib1g-dev 
    sudo apt -y install ruby-bundler ruby-dev build-essential patch 
    sudo apt -y install libssl-dev
    sudo apt -y install build-essential bison openssl libreadline6 
    sudo apt -y install libreadline6-dev curl git-core zlib1g 
    sudo apt -y install zlib1g-dev libssl-dev libyaml-dev 
    sudo apt -y install libxml2-dev autoconf libc6-dev ncurses-dev automake libtool
    ```
    
## Install bosh via bosh-cli v2
1. SCP prepared keys (bosh.pem etc., see step 1 of aws installation) to vm bosh.pem etc
1. Clone bosh deployment repository
   ```
   git clone https://github.com/cloudfoundry/bosh-deployment.git
    ```
1. Install bosh-cli
    ```
    wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.1-linux-amd64
    mv bosh-cli... bosh
    chmod +x bosh
    mv bosh /usr/local/bin
    ```
1. Follow bosh-deployment instructions to install bosh
    1. Make sure your AWS bosh-director has a public ip (TODO: why?)
    1. Shortcut for stemcell:
         ```
        bosh -e bosh-1 upload-stemcell https://bosh.io/d/stemcells/bosh-aws-xen-hvm-ubuntu-trusty-go_agent
        ```

## TODO: Use Terraform to set up AWS inception vm
1. Install terraform https://www.terraform.io/intro/getting-started/install.html