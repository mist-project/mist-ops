# Mist DevOps
Repository includes all the DevOps defined for the mist project. The project runs on VMs running in a proxmox server.

## Install

### Terraform
Following is the link to install terraform.
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

Terraform version used: `v1.12.2`

### One password

#### CLI
https://developer.1password.com/docs/cli/get-started/

#### Desktop APP
One pass w



Note: 
When fetching private keys ssh from 1password and storing it a file. You will need to change permissions and clean the file. 
* chmod 600 `file`
  * this will show up as a unprotected key file error
* vi --clean `file` --> (:wq)
  * this will show up as `Load key "" error in libcryto"` Followed by `permission deined (publickey)`


if you having issues with the command `ssh -i /key/path user@host`