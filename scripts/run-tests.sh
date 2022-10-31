#!/bin/bash

source .env
current_dir=$(pwd)

# TODO retrieve this from its source, this shouldn't be defined here
BASEPATH=/utkusarioglu-com/projects/nextjs-grpc

mkdir -p logs

skip_env_vars=""
if [ ! -z "$SKIP_STAGES" ]; then
  for stage in $SKIP_STAGES; do
    skip_env_vars="$skip_env_vars SKIP_$stage=1"
  done
fi

exit_codes=0

for terratest_repo in $TERRATEST_REPOS; do
  if [ $exit_codes -gt 0 ]; then
    echo "Error: Skipping '$terratest_repo' tests due to previous failures"
    continue 
  fi
  echo "Running \`$terratest_repo\` tests…"
  cd $BASEPATH/$terratest_repo/tests 
  bash -c "ENVIRONMENT=$ENVIRONMENT $skip_env_vars SKIP_teardown=1 go test -timeout 90m"
  step_exit_code=$?
  ((exit_codes+=$step_exit_code))
  echo "'$terratest_repo' finalized with exit code $step_exit_code"
done

if [ "$ENVIRONMENT" != "ci" ] && [[ $skip_stages != *"teardown"* ]]; then
  echo "Running \`infra/targets/local\` teardown…"
  cd $current_dir/tests
  ENVIRONMENT=$ENVIRONMENT SKIP_setup=1 SKIP_http_local=1 go test -timeout 90m 
  step_exit_code=$?
  ((exit_codes+=$step_exit_code))
  echo "Teardown finalized with exit code $step_exit_code"
fi

exit $exit_codes
