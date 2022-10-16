#!/bin/bash

#
# This file runs the tests on github actions
#

# set by github workflow env
k3d_config_file_path=$1

# This thwarts path bind errors due to non-existent folders
for subpath in .config/gh .kube; do
  mkdir -p  /home/runner/$subpath
done

docker compose \
  -f .devcontainer/docker-compose.yml \
  -f .docker/docker-compose.common.yml \
  -f .docker/docker-compose.ci.yml \
  run \
  nextjs-grpc-infra-target-local \
  "$k3d_config_file_path"
