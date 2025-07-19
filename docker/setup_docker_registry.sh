#!/bin/bash

set -e

echo "📄 Writing registry-config.yml..."
mkdir -p /opt/docker-registry

cat > /opt/docker-registry/registry-config.yml <<EOF
version: 0.1
log:
  fields:
    service: registry

http:
  addr: :5000
  headers:
    Access-Control-Allow-Origin: ["http://192.168.0.22:9444"]
    Access-Control-Allow-Methods: ["GET", "HEAD", "OPTIONS", "DELETE"]
    Access-Control-Allow-Headers: ["Authorization", "Accept", "Cache-Control"]
storage:
  filesystem:
    rootdirectory: /var/lib/registry
EOF

echo "🚀 Starting Docker Compose..."
docker compose -f docker_registry_compose.yml up -d
