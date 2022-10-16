#!/bin/bash

#
# This file acts as the entrypoint for docker compose run that handles
# CI tests
#

k3d_config_file_path=$1
if [ -z "$k3d_config_file_path" ]; then
  echo "Error: No path was given for K3d config"
  exit 1
fi

# Helps use the configuration that is set up in the devcontainer
HOME=/home/terraform

echo "Running devcontainer postCreateCommand…"
scripts/post-create-command.sh

echo "Creating cluster using: '$k3d_config_file_path'…"
k3d cluster create -c $k3d_config_file_path

echo "Starting tests…"
scripts/run-tests.sh 

echo "Deleting cluster using: '$k3d_config_file_path'…"
k3d cluster delete -c $k3d_config_file_path
