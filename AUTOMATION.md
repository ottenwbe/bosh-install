# Deploy inception vm for bosh with terraform #

1. Install terraform (https://www.terraform.io/intro/getting-started/install.html) if not yet done
1. Clone this repository
    ```
    git clone ...
    ```
1. Create a key pair on aws and save the pem file at the following location: 
```terraform_bootstrap/bosh.pem```
1. (OPTIONAL) Create a local file ```terraform.tfvars``` to hold your aws credentials. Otherwise you have to retype the credentials with every change.
    ```
    access_key = "..."
    secret_key = "..."
    ```
1. Execute the rollout script 
    ```
    ./rollout.sh
    ```