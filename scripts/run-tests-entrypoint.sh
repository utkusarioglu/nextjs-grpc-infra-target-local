#!/bin/bash

#
# This file acts as the entrypoint for docker compose run that handles
# CI tests
#
exit_codes=0
k3d_config_file_path=$1
if [ -z "$k3d_config_file_path" ]; then
  echo "Error: No path was given for K3d config"
  exit 1
fi

# Helps use the configuration that is set up in the devcontainer
HOME=/home/terraform

echo "Running devcontainer postCreateCommand…"
scripts/post-create-command.sh
step_exit_code=$?
((exit_codes+=$step_exit_code))
echo "'scripts/post-create-command.sh' finalized with exit code $step_exit_code"

echo "Creating cluster using: '$k3d_config_file_path'…"
k3d cluster create -c $k3d_config_file_path
step_exit_code=$?
((exit_codes+=$step_exit_code))
echo "Cluster creation finalized with exit code $step_exit_code"

echo "Starting tests…"
scripts/run-tests.sh 
step_exit_code=$?
((exit_codes+=$step_exit_code))
echo "'scripts/run-tests.sh' finalized with exit code $step_exit_code"

echo "Deleting cluster using: '$k3d_config_file_path'…"
k3d cluster delete -c $k3d_config_file_path
step_exit_code=$?
((exit_codes+=$step_exit_code))
echo "Cluster deletion finalized with exit code $step_exit_code"

exit $exit_codes
