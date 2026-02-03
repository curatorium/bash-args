#!/bin/bash
source ./bash-args.sh

function main() {
  local ARGS=("$@")
  local verbose command cmd_args

  args:flag verbose v
  args:arg command '^(clone|pull|push)$' --err "Unknown command"
  args:varg -o cmd_args

  "subcommand-$command" "${cmd_args[@]}"
}

function subcommand-clone() { git clone "$@"; }
function subcommand-pull()  { git pull "$@"; }
function subcommand-push()  { git push "$@"; }

main "$@"
