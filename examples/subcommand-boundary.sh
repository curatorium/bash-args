#!/bin/bash
source ./bash-args.sh

function main() {
  local ARGS=("$@")
  local command cmd_args verbose

  args:sub command cmd_args '^(clone|pull|push)$' --err "Unknown command" || exit 1
  args:flag verbose v

  [[ "$verbose" == "true" ]] && echo "verbose mode"

  "subcommand-$command" "${cmd_args[@]}"
}

function subcommand-clone() {
  local ARGS=("$@")
  local branch verbose

  args:opt branch b
  args:flag verbose v  # subcommand's own --verbose, independent of parent's

  git clone ${branch:+--branch "$branch"} "${ARGS[@]}"
}

main "$@"
