#!/bin/bash

# Authenticate with 1Password CLI (if not already authenticated)
echo "You will be prompted to sign in to 1Password ---->"
eval $(op signin)

# Fetch secrets
ANSIBLE_REMOTE_USER=$(op read "$OP_BACKEND_DEV_USERNAME_PATH")
PG_USER_PASSWORD=$(op read "$OP_BACKEND_DEV_PASSWORD_PATH")
PRIVATE_KEY_CONTENT=$(op read "$OP_BACKEND_DEV_PRIVATE_KEY_PATH")
PRIVATE_IP_ADDRESS=$(op read "$OP_BACKEND_DEV_IP_ADDRESS_PATH")
DB_NAME=$(op read "$OP_BACKEND_DEV_DB_NAME_PATH")

# Check if secret fetching was successful
if [ -z "$ANSIBLE_REMOTE_USER" ] || \
   [ -z "$PRIVATE_KEY_CONTENT" ] || \
   [ -z "$PG_USER_PASSWORD" ] || \
   [ -z "$PRIVATE_IP_ADDRESS" ] || \
   [ -z "$DB_NAME" ]; then
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
# ansible-playbook -i inventory/hosts.ini playbooks/initialize_ubuntu_server.yml \
#   --extra-vars "ansible_ssh_private_key_file=$KEY_FILE ansible_user=$ANSIBLE_REMOTE_USER"

# ansible-playbook -i inventory/hosts.ini pg_playbooks/install_pg_version_16.yml \
#   --extra-vars "ansible_ssh_private_key_file=$KEY_FILE ansible_user=$ANSIBLE_REMOTE_USER"

ansible-playbook \
  -i inventory/hosts.ini \
  pg_playbooks/setup_pg_user.yml \
  --extra-vars "ansible_ssh_private_key_file=$KEY_FILE" \
  --extra-vars "ansible_user=$ANSIBLE_REMOTE_USER" \
  --extra-vars "db_name=$DB_NAME" \
  --extra-vars "db_user=$ANSIBLE_REMOTE_USER" \
  --extra-vars "db_password=$PG_USER_PASSWORD" \
  --extra-vars "db_host_address=$PRIVATE_IP_ADDRESS"

# Cleanup
rm -f "$KEY_FILE"
unset ANSIBLE_REMOTE_USER
unset ANSIBLE_PRIVATE_KEY_FILE
unset PG_USER_PASSWORD
unset PRIVATE_IP_ADDRESS
unset DB_NAME

echo "Ansible run completed and sensitive data cleaned up."
