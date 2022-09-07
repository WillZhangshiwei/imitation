#!/usr/bin/env bash

# The values of {env_config_name} are defined in the config file
# `experiments/rollouts_from_policies.csv`.
#
# TODO(shwang): Nice to have -- first evaluate the mean return of each policy, then use
# this to choose the best seed rather than hardcoding seed 0. This will probably require
# a Python implementation. We (Steven) currently pick out the best policies seeds
# manually and rename that directory to `expert_models/polieices/${env_name}_0/` to ensure
# that downstream scripts get good expert rollouts and policies. If you are in the
# process of picking good policies, then this "check rollout quality" script could
# be useful: https://gist.github.com/1bea85e658a41b32c2693832fc216b8a.

set -e  # Exit on error.

source experiments/common.sh

CONFIG_CSV=${CONFIG_CSV:-experiments/rollouts_from_policies_config.csv}

if ! TEMP=$($GNU_GETOPT -o f -l fast,timestamp: -- "$@"); then
  exit 1
fi
eval set -- "$TEMP"

while true; do
  case "$1" in
    -f | --fast)
      # Fast mode (debug)
      CONFIG_CSV="tests/testdata/rollouts_from_policies_config.csv"
      shift
      ;;
    --timestamp)
      TIMESTAMP="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Unrecognized flag $1" >&2
      exit 1
      ;;
  esac
done

OUTPUT_DIR="output/train_experts/${TIMESTAMP}"

echo "Writing logs in ${OUTPUT_DIR}, and saving rollouts in ${OUTPUT_DIR}/expert_models/*/rollouts/"

parallel -j 25% --header : --results "${OUTPUT_DIR}/parallel_rollout/" --progress --colsep , \
  python3 -m imitation.scripts.eval_policy \
  --capture=sys \
  with \
  '{env_config_name}' \
  common.log_root="${OUTPUT_DIR}" \
  rollout_save_path="${OUTPUT_DIR}/{env_config_name}_{best_seed}/rollouts/final.pkl" \
  eval_n_episodes='{n_demonstrations}' \
  eval_n_timesteps=None \
  :::: ${CONFIG_CSV}