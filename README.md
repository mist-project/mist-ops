# Mist DevOps
Repository includes all the DevOps defined for the mist project. The project runs on VMs running in a proxmox server.

## Install

### Terraform
Following is the link to install terraform.
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

Installed version `v1.12.2`

### One password

#### CLI
Used to run one password CLI commands. Installed version `2.31.1`

https://developer.1password.com/docs/cli/get-started/

#### Desktop APP
Used for simplifiying authorization when executing one pw commands

https://1password.com/downloads/linux

### Ansible

Installed ansible with pipx. Installed version `10.7.0` 
https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

#### Install Ansible dependencies
```
cd ansible 
ansible-galaxy install -r requirements.yml
```

## Miscellaneous


Note: 
When fetching private keys ssh from 1password and storing it a file. You will need to change permissions and clean the file. 
* chmod 600 `file`
  * this will show up as a unprotected key file error
* vi --clean `file` --> (:wq)
  * this will show up as `Load key "" error in libcryto"` Followed by `permission deined (publickey)`


if you having issues with the command `ssh -i /key/path user@host`