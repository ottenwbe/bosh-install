# Deploy inception vm for bosh with terraform #

1. Install terraform (https://www.terraform.io/intro/getting-started/install.html) if not yet done
1. Clone this repository
1. Create a key pair on aws and save it as ```terraform_bootstrap/bosh.pem```
1. Create a local file ```terraform.tfvars``` with your aws credentials
    ```
    access_key = "..."
    secret_key = "..."
    ```
1. Execute the rollout script 
    ```
    ./rollout.sh
    ```