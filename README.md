# bash-args

> Argument parsing for bash scripts.

## Installation

```bash
curl -1fsSLR https://github.com/curatorium/bash-args/releases/latest/download/bash-args.sh -o .deps/bash-args.sh
```

## Usage

```bash
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
```

All functions operate on the `ARGS` array, consuming matched tokens and leaving unmatched ones for subsequent parsing. **Parsing order matters** — follow the numbering above.

Ideally inside functions you will be using `local` variables to avoid polluting the global scope.

### Why This Order

| Step | Reason |
|------|--------|
| `args:sub` first | Splits at the subcommand word. Parent parsers (steps 2-6) only see tokens before the boundary. |
| `args:flag` / `args:opt` before `args:flag --bundle` | Flags and options each match their own token patterns, so their relative order is interchangeable. Both must run before bundled flags — otherwise `-nfoo` could be misread as combined flags instead of an option value. |
| `args:flag --bundle` before `args:arg` | Combined short flags (`-vfs`) start with `-`. Since `args:arg` doesn't skip dash-prefixed tokens, it would capture them as positional values. Clean all flags/options first so only true positionals remain. |
| `args:arg` before `args:varg` | Takes the first remaining positional. Must run before `args:varg` sweeps everything. |
| `args:varg` always last | Sweeps all remaining tokens. Anything parsed after `args:varg` would find `ARGS` empty. |

## FUNCTIONS

**Parameter order matters.** Each function parses its own parameters positionally — pass them in the exact order shown in the usage line.

### `args:flag`

Parse a boolean flag (e.g., -v, --verbose)	

```bash
args:flag [-r|--required] [-b|--bundle] [--count] <long> <short> [--err <msg>]	
```

| Parameter | Description |
|-----------|-------------|
| `[-r\|--required]` | Make the flag required. |
| `[-b\|--bundle]` | Also match within combined short flags (e.g., -vfs). Requires <short>. |
| `[--count]` | Count occurrences instead of setting a boolean. Variable will be set to the number of matches (0 if absent). |
| `<long>` | Long name of the flag (also used as variable name). |
| `<short>` | Short (1 letter) name of the flag. Use "" for long-only. |
| `[--err <msg>]` | Error message printed to stderr on failure. |

| Return | Description |
|--------|-------------|
| `0` | Flag found or optional and absent. |
| `1` | Flag absent and required. |


### `args:opt`

Parse an option with a value (e.g., -n foo, --name=foo)	

```bash
args:opt [-r|--required] [-a|--accumulate] <long> <short> [pattern] [--err <msg>]	
```

| Parameter | Description |
|-----------|-------------|
| `[-r\|--required]` | Make the option required. |
| `[-a\|--accumulate]` | Collect all occurrences into an array instead of last-wins. Variable must be declared as an array. |
| `<long>` | Long name of the option (also used as variable name). |
| `<short>` | Short (1 letter) name of the option. Use "" for long-only. |
| `[pattern]` | RegEx pattern to validate value. Default "(.*)". |
| `[--err <msg>]` | Error message printed to stderr on failure. |

| Return | Description |
|--------|-------------|
| `0` | Option found and matches, or absent and optional. |
| `1` | Option absent and required, or found and mismatched. |


### `args:arg`

Parse a positional argument	

```bash
args:arg [-o|--optional] <name> [pattern] [--err <msg>]	
```

| Parameter | Description |
|-----------|-------------|
| `[-o\|--optional]` | Make the argument optional. |
| `<name>` | Variable name to assign the captured value. |
| `[pattern]` | RegEx pattern to validate value. Default "(.*)". |
| `[--err <msg>]` | Error message printed to stderr on failure. |

| Return | Description |
|--------|-------------|
| `0` | Argument found and matches, or absent and optional. |
| `1` | Argument absent and required, or found and mismatched. |


### `args:varg`

Parse variadic (rest) arguments into an array	

```bash
args:varg [-o|--optional] <name> [--err <msg>]	
```

| Parameter | Description |
|-----------|-------------|
| `[-o\|--optional]` | Make the arguments optional. |
| `<name>` | Array variable name to capture rest values. |
| `[--err <msg>]` | Error message printed to stderr on failure. |

| Return | Description |
|--------|-------------|
| `0` | At least one argument found, or optional and none found. |
| `1` | No arguments and required. |


### `args:sub`

Parse a subcommand and split arguments at the subcommand boundary	

```bash
args:sub [-o|--optional] <name> <rest> <pattern> [--err <msg>]	
```

| Parameter | Description |
|-----------|-------------|
| `[-o\|--optional]` | Make the subcommand optional. |
| `<name>` | Variable name to assign the subcommand name. |
| `<rest>` | Array variable name to capture arguments after the subcommand. |
| `<pattern>` | RegEx pattern to match the subcommand. |
| `[--err <msg>]` | Error message printed to stderr on failure. |

| Return | Description |
|--------|-------------|
| `0` | Subcommand found, or optional and absent. |
| `1` | Subcommand absent and required, or found and mismatched. |


## Pattern Matching

Options and arguments support RegEx patterns for validation:

```bash
# Numeric validation
args:opt port p '^[0-9]+$'

# URL validation
args:arg url '^https?://'

# Capture groups extract specific parts
args:opt ord o '^:([0-9]{3})$'    # --ord :100 -> ord=100
```

When a pattern contains a capture group, the captured value is assigned to the variable instead of the full match.

## Examples

### Basic CLI Tool

```bash
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
```

### Git-like Subcommands

```bash
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
```

### Subcommand with Boundary Separation

```bash
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
```

```bash
$ mytool --verbose clone --verbose --branch main repo-url
verbose mode
# parent --verbose ✓, clone gets its own --verbose + --branch main + repo-url
```

### End-of-Options Separator

```bash
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
```

The `--` separator stops `args:flag` and `args:opt` from scanning past it. Then `args:varg` consumes `--` and captures everything that remains.

```bash
$ rm --recursive --output log.txt -- --weird-filename -rf
# recursive=true, output=log.txt, files=(--weird-filename -rf)
```

### With Validation

```bash
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
```

## Limitations

- **No attached quoting.** Values with spaces must be passed as separate shell words (e.g., `--name "foo bar"`). Attached forms like `--name="foo bar"` may not preserve quoting as expected.
- **`args:flag --bundle` ordering.** `args:flag --bundle` must be called after all `args:flag` and `args:opt` calls, but before `args:arg` calls. Otherwise, combined flags may consume characters intended as option values, or positional arguments starting with `-` may be misinterpreted.
- **Subcommand detection is pattern-based.** `args:sub` finds the first token matching the pattern. If a parent option's value happens to match the subcommand pattern (e.g., `--name clone clone ...`), the value will be detected as the subcommand instead.

## License

MIT
