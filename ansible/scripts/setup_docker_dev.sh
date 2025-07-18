#!/bin/bash

# Authenticate with 1Password CLI (if not already authenticated)
echo "You will be prompted to sign in to 1Password ---->"
eval $(op signin)

# Fetch secrets
ANSIBLE_REMOTE_USER=$(op read op://mistiop/control-center/username)
PRIVATE_KEY_CONTENT=$(op read op://mistiop/control-center/private\ key)

# Check if secret fetching was successful
if [ -z "$ANSIBLE_REMOTE_USER" ] || \
   [ -z "$PRIVATE_KEY_CONTENT" ]; then
    echo "Error: One or more secrets could not be fetched from 1Password."
    exit 1
fi

# Write private key to a secure temp file
KEY_FILE=$(mktemp)
echo "$PRIVATE_KEY_CONTENT" > "$KEY_FILE"
echo "Remote user: $ANSIBLE_REMOTE_USER"
echo "Private key written to $KEY_FILE"
chmod 600 "$KEY_FILE"
export ANSIBLE_PRIVATE_KEY_FILE="$KEY_FILE"

# Run Ansible playbook
ansible-playbook -i inventory/hosts.ini docker_playbooks/initialize_ubuntu_server.yml \
  --extra-vars "ansible_ssh_private_key_file=$KEY_FILE ansible_user=$ANSIBLE_REMOTE_USER"

ansible-playbook -i inventory/hosts.ini docker_playbooks/install_docker.yml \
  --extra-vars "ansible_ssh_private_key_file=$KEY_FILE ansible_user=$ANSIBLE_REMOTE_USER"

# Cleanup
rm -f "$KEY_FILE"
unset ANSIBLE_REMOTE_USER
unset ANSIBLE_PRIVATE_KEY_FILE

echo "Ansible run completed and sensitive data cleaned up."
