#!/bin/bash
source ./bash-args.sh

function main() {
  local ARGS=("$@")
  local verbose help output input extra

  args:flag verbose v
  args:flag -r help h --err "Missing required --help flag"
  args:opt output o
  args:arg input
  args:varg -o extra

  echo "verbose: $verbose"
  echo "output: $output"
  echo "input: $input"
  echo "extra: ${extra[*]}"
}

main "$@"
