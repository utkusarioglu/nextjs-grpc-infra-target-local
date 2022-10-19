#!/bin/bash

source .env
current_dir=$(pwd)

BASEPATH=/utkusarioglu-com/projects/nextjs-grpc

mkdir -p logs

skip_env_vars=""
if [ ! -z "$SKIP_STAGES" ]; then
  for stage in $SKIP_STAGES; do
    skip_env_vars="$skip_env_vars SKIP_$stage=1"
  done
fi

for terratest_repo in $TERRATEST_REPOS; do
  echo "Running \`$terratest_repo\` tests…"
  cd $BASEPATH/$terratest_repo/tests 
  bash -c "ENVIRONMENT=$ENVIRONMENT $skip_env_vars SKIP_teardown=1 go test -timeout 90m"
done

if [ "$ENVIRONMENT" != "ci" ] && [[ $skip_stages != *"teardown"* ]]; then
  echo "Running \`infra/targets/local\` teardown…"
  cd $current_dir/tests
  ENVIRONMENT=$ENVIRONMENT SKIP_setup=1 SKIP_http_local=1 go test -timeout 90m 
fi
