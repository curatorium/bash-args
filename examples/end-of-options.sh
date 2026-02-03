#!/bin/bash
source ./bash-args.sh

function main() {
  local ARGS=("$@")
  local recursive output files

  args:flag recursive r
  args:opt output o
  args:varg -o files

  echo "recursive: $recursive"
  echo "output: $output"
  echo "files: ${files[*]}"
}

main "$@"
