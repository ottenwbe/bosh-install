# Quickstart for the Impatient #

To get an environment up and running, the following quickstart guide suffices.
However, this part of the tutorial is only recommended for those who have prior experience with both, terraform and bosh.
 

1. Clone the git repository of this guide, which provides all required terraform HashiCorp configuration language (HCL) files.
    
    ```bash
    git clone https://github.com/ottenwbe/bosh-install.git
    cd bosh-install
    ```

1. Install [terraform](https://www.terraform.io/intro/getting-started/install.html), if you haven't done that already.

    ```bash
    curl -fSL "https://releases.hashicorp.com/terraform/0.9.1/terraform_0.9.1_linux_amd64.zip" -o terraform.zip
    sudo unzip terraform.zip -d /opt/terraform
    sudo ln -s /opt/terraform/terraform /usr/bin/terraform
    rm -f terraform.zip
    ```
    
1. Create a file ```terraform.tfvars``` in the src directory which includes your AWS access key and secret key 
   
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

1. To destroy your environment after you finished the guide, execute the destroy script. You may want to go through your AWS console to make sure that everything is destroyed as planned. 

    ```bash
    ./destroy.sh
    ```
