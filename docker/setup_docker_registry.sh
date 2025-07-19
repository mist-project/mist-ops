#!/bin/bash

set -e

mkdir -p /opt/docker-registry


echo "🚀 Starting Docker Compose..."
docker compose -f docker_registry_compose.yml up -d
