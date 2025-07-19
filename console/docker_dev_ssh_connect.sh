#!/bin/bash

set -euo pipefail

echo "🔐 Signing in to 1Password..."
eval "$(op signin)" || {
  echo "❌ Failed to authenticate with 1Password CLI."
  exit 1
}

# Fetch credentials
echo "📦 Fetching secrets..."
REMOTE_USER=$(op read "$OP_DOCKER_DEV_USERNAME_PATH")
PRIVATE_KEY_CONTENT=$(op read "$OP_DOCKER_DEV_PRIVATE_KEY_PATH")

if [[ -z "$REMOTE_USER" || -z "$PRIVATE_KEY_CONTENT" ]]; then
  echo "❌ Missing required credentials from 1Password."
  exit 1
fi

# Write key to a secure temp file
KEY_FILE=$(mktemp)
echo "$PRIVATE_KEY_CONTENT" > "$KEY_FILE"
chmod 600 "$KEY_FILE"

echo "✅ Key written to $KEY_FILE"

# Default host or override via arg
HOST="${1:-192.168.0.21}"
echo "🔗 Connecting to $REMOTE_USER@$HOST..."

# Start background cleanup task
(
  sleep 3
  echo "🧹 Cleaning up..."
  rm -f "$KEY_FILE"
  unset PRIVATE_KEY_CONTENT
) &

# Start SSH session (blocking)
ssh -i "$KEY_FILE" "$REMOTE_USER@$HOST" -o "StrictHostKeyChecking=no"

echo "✅ SSH session ended. Cleanup complete."