variable "access_key" {
  description = "Access Key"
}

variable "secret_key" {
  description = "Secret Access"
}

variable "default_az"     {
  description = "Default AZ"
  default     = "eu-central-1a"
}

variable "region"     {
  description = "AWS region to host the bosh network"
  default     = "eu-central-1"
}

variable "vpc_gw" {
  description = "GW"
  default = "10.128.0.1"
}

variable "bosh_gw" {
  description = "GW"
  default = "10.128.1.1"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default     = "10.128.0.0/16"
}

variable "bosh_ip" {
  description = "BOSH Director IP"
  default     = "10.128.1.6"
}

variable "bosh_subnet_cidr" {
  description = "CIDR for bosh subnet"
  default     = "10.128.1.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  default     = "10.128.0.0/24"
}

/* Ubuntu amis by region */
variable "amis" {
  type = "map"
  description = "Base AMI to launch the inception vm"
  default = {
    eu-central-1 = "ami-829145ed"
  }
}