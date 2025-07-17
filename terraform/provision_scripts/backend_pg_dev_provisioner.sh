#!/bin/bash

# Authenticate with 1Password CLI (if not already authenticated)
eval $(op signin)

# Fetch secrets and export as TF_VAR_ environment variables
export TF_VAR_MIST_BACKEND_PG_DEV_USERNAME=$(op read op://mistiop/mist-backend-pg-dev/username)
export TF_VAR_MIST_BACKEND_PG_DEV_SSH_PUBKEY=$(op read op://mistiop/mist-backend-pg-dev/public\ key)

# Check if secret fetching was successful before proceeding
if [ -z "$TF_VAR_MIST_BACKEND_PG_DEV_USERNAME" ] || \
   [ -z "$TF_VAR_MIST_BACKEND_PG_DEV_SSH_PUBKEY" ]; then
    echo "Error: One or more secrets could not be fetched from 1Password."
    exit 1
fi

# Only provisions the backend PostgreSQL development VM
terraform apply --auto-approve --target=proxmox_vm_qemu.mist-backend-pg-dev

# Unset the exported variables after terraform apply completes
unset TF_VAR_MIST_BACKEND_PG_DEV_USERNAME
unset TF_VAR_MIST_BACKEND_PG_DEV_SSH_PUBKEY

echo "Terraform apply completed and sensitive environment variables have been unset."