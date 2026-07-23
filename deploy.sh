#!/usr/bin/env bash

# Exit on error
set -euo pipefail

cd "$(dirname "$0")"

DEPLOY_CONFIG_FILE="deploy/ansible/deploy_config.yaml"
ANSIBLE_CONFIG_FILE="deploy/ansible/ansible.cfg"
COLLECTION_REQUIREMENTS_FILE="deploy/ansible/requirements.yml"
COLLECTIONS_PATH="deploy/ansible/collections"

if [ ! -f "$DEPLOY_CONFIG_FILE" ]; then
  echo "Error: deployment config file '$DEPLOY_CONFIG_FILE' was not found."
  echo "Copy deploy/ansible/deploy_config.yaml.example and set your target values."
  exit 1
fi

if [ ! -f "$ANSIBLE_CONFIG_FILE" ]; then
  echo "Error: Ansible config file '$ANSIBLE_CONFIG_FILE' was not found."
  exit 1
fi

if [ ! -f "$COLLECTION_REQUIREMENTS_FILE" ]; then
  echo "Error: collection requirements file '$COLLECTION_REQUIREMENTS_FILE' was not found."
  exit 1
fi

echo "Building Flutter web app for production..."
flutter build web --release

echo "Installing Ansible collections from '$COLLECTION_REQUIREMENTS_FILE'..."
ANSIBLE_CONFIG="$ANSIBLE_CONFIG_FILE" ansible-galaxy collection install \
  -r "$COLLECTION_REQUIREMENTS_FILE" \
  -p "$COLLECTIONS_PATH"

echo "Running Ansible deployment playbook..."
ANSIBLE_CONFIG="$ANSIBLE_CONFIG_FILE" ansible-playbook deploy/ansible/update.yaml -K


echo "Deployment complete!"
