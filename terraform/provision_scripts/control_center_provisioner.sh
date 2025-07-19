#!/bin/bash

# Authenticate with 1Password CLI (if not already authenticated)
eval $(op signin)

# Fetch secrets and export as TF_VAR_ environment variables
export TF_VAR_CONTROL_CENTER_USERNAME=$(op read op://mistiop/control-center/username)
export TF_VAR_CONTROL_CENTER_SSH_PUBKEY=$(op read op://mistiop/control-center/public\ key)

# Check if secret fetching was successful before proceeding
if [ -z "$TF_VAR_CONTROL_CENTER_USERNAME" ] || \
   [ -z "$TF_VAR_CONTROL_CENTER_SSH_PUBKEY" ]; then
    echo "Error: One or more secrets could not be fetched from 1Password."
    exit 1
fi

# Only provisions the Docker development VM
terraform apply --auto-approve --target=proxmox_vm_qemu.control-center

# Unset the exported variables after terraform apply completes
unset TF_VAR_CONTROL_CENTER_USERNAME
unset TF_VAR_CONTROL_CENTER_SSH_PUBKEY

echo "Terraform apply completed and sensitive environment variables have been unset."