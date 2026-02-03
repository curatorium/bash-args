#!/bin/bash
source ./bash-args.sh

function main() {
  local ARGS=("$@")
  local port host url

  args:opt port p '^[0-9]+$' --err "Port must be numeric" || exit 1
  args:opt host h '^[a-z0-9.-]+$' --err "Invalid hostname" || exit 1
  args:arg url '^https?://' --err "URL must start with http(s)://" || exit 1

  echo "Connecting to $url via $host:$port"
}

main "$@"
