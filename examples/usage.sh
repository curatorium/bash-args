#!/bin/bash
source ./bash-args.sh

function main() {
  local ARGS=("$@");                      # assign args to array (name MUST be ARGS)

  local cmd verbose name force dir files  # parsed values will be injected into these variables

  args:sub cmd cmd_args '^(cmd1|cmd2)$'   # 1. split at subcommand word
  args:flag verbose v                     # 2. standalone flags
  args:opt  name n                        # 3. options (--name value pairs)
  args:flag --bundle force f              # 4. bundled short flags (-zxvf) after options
  args:arg  dir;                          # 5. first remaining positional
  args:varg -o files;                     # 6. sweep all remaining tokens last

  "subcommand-$cmd" "${cmd_args[@]}";
}

function subcommand-cmd1() {
  local ARGS=("$@");                        # assign args to array (name MUST be ARGS)

  local recursive output cross dir files    # parsed values will be injected into these variables

  args:flag recursive r                     # 1. standalone flags
  args:opt  output o                        # 2. options (--name value pairs)
  args:flag --bundle cross x                # 3. bundled short flags (-zxvf) after options
  args:arg  dir;                            # 4. first remaining positional
  args:varg -o files;                       # 5. sweep all remaining tokens last

  # ...
}

main "$@"
