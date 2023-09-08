# Band Protocol Tools
Tools for Band Protocol

## Ansible
Deploy a fullnode with oracle for bandprotocol validator using ansible playbook

### Parameters to configure
hosts.ini
* default_ssh_port='22'
* p2p_port='26656'
* custom_ssh_port='57315'
* default_user='root'
* go_bin='/usr/local/bin'
* band_version='v2.5.2'
* enable_prometheus='true'
* prometheus_ip='8.8.8.8'
* prometheus_port='26660'

### How to run ansible playbook
If you want to configure custom ssh port or enable firewall for cosmos based node, you will want to run this playbook first:
`ansible-playbook -i hosts.ini 01-os-preparation.yml -e "ansible_ssh_timeout=60"`

After the system is ready run following playbook to install bandd and yoda binaries:
`ansible-playbook -i hosts.ini 02-band-installation.yml -l 'validator' -e "ansible_ssh_timeout=60"`

Enjoy!

## Terraform
Deploy a fulllnode for bandprotocol validator to your AWS account

### Prerequisites
* Terraform 0.13 or later
* aws-cli installed
* aws account with access-key and secret-key
* ssh key called user in aws region

### Parameters to configure
terraform.tfvars     
* image_id      = "ami-0d7b738ade930e24a" # ubuntu 20.04 ami in eu-west-3 region
* instance_type = "t2.medium" # 2 cpu and 4gb ram
* ssh_key       = "user"      # aws ssh keyname    
* user          = "ubuntu"    # aws instance username
* vpc_name      = "bandprotocol"    # vpc name 
* region        = "eu-west-3" # select your prefered aws region
* profile       = "sandbox"   # your aws profile from ~/.aws/credentials

### Instruction
- Navigate to terraform directory
- Edit variables file terraform.tfvars 
- run *terraform init* to initialize modules
- run *terraform apply* to run the configuration
- press *yes* when apply changes
