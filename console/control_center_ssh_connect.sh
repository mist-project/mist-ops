#!/bin/bash

set -euo pipefail

echo "🔐 Signing in to 1Password..."
eval "$(op signin)" || {
  echo "❌ Failed to authenticate with 1Password CLI."
  exit 1
}

# Fetch credentials
echo "📦 Fetching secrets..."
REMOTE_USER=$(op read op://mistiop/control-center/username)
PRIVATE_KEY_CONTENT=$(op read "op://mistiop/control-center/private key")

if [[ -z "$REMOTE_USER" || -z "$PRIVATE_KEY_CONTENT" ]]; then
  echo "❌ Missing required credentials from 1Password."
  exit 1
fi

KEY_FILE=$(mktemp)
echo "$PRIVATE_KEY_CONTENT" > "$KEY_FILE"
chmod 600 "$KEY_FILE"

HOST="${1:-192.168.0.22}"

echo "🔗 Connecting to $REMOTE_USER@$HOST..."

# Spawn background terminal tab to delete key file after delay
gnome-terminal -- bash -c "
  echo '🧹 Deleting SSH key...'
  sleep 3
  rm -f '$KEY_FILE'
  exit
" &

# Start SSH session (blocking)
ssh -i "$KEY_FILE" "$REMOTE_USER@$HOST" -o "StrictHostKeyChecking=no"

echo "✅ SSH session ended."