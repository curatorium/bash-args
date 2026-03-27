# bash-args

Generic argument parser for bash scripts. MIT licensed, standalone single-file library.

## Project Structure

```
bash-args.sh          # The library (single file). Source this to use.
bash-args.test        # Test suite. Uses assert/assert:array-eq helpers.
bash-args.test.md     # Test results in markdown table format.
examples/             # Example scripts demonstrating usage patterns.
  usage.sh            # Full usage pattern (sub + flag + opt + bundle + arg + varg).
  basic-cli.sh        # Simple flag/opt/arg/varg example.
  git-subcommands.sh  # Git-like subcommand dispatch.
  subcommand-boundary.sh  # args:sub with independent child parsing.
  end-of-options.sh   # -- separator handling.
  validation.sh       # Pattern-based validation with --err.
README.md             # Full API documentation with examples.
LICENSE               # MIT
```

## Architecture

Single-file library with 5 public functions and 1 internal helper:

| Function | Purpose |
|----------|---------|
| `args:flag` | Boolean flags (`-v`, `--verbose`). Supports `--bundle` (combined `-vfs`), `--count`, `--required`. |
| `args:opt` | Key-value options (`-n foo`, `--name=foo`). Supports `--accumulate`, `--required`, regex patterns. |
| `args:arg` | Positional arguments. Supports `--optional`, regex patterns with capture groups. |
| `args:varg` | Variadic rest arguments (sweeps all remaining tokens). Supports `--optional`. |
| `args:sub` | Subcommand detection with boundary splitting. Separates parent/child args. |
| `args::capture` | **Internal.** Token scanner used by flag/opt. Finds matching token, extracts value, removes from ARGS array. |

### Core Mechanism

All functions operate on a `local ARGS=("$@")` array via bash nameref (`local -n TOKENS="ARGS"`). Each parser function consumes matched tokens from the array, leaving unmatched ones for subsequent calls. Values are injected into caller variables via nameref (`local -n __value_="$varname"`).

The `--` separator stops flag/opt scanning but is consumed by arg/varg, allowing flag-like values as positionals.

### Parsing Order (Mandatory)

See README.md "Why This Order" for detailed rationale. Summary: sub → flag/opt → bundle → arg → varg.

### Return Codes

- `0` -- success (found, or optional and absent)
- `1` -- failure (required and missing, or pattern mismatch)
- `2` -- (internal, `args::capture` only) token found but value didn't match pattern

### Error Handling

All public functions accept `--err <msg>` as the last parameter pair. On failure, the message is printed to stderr. Callers should use `|| exit 1` or `|| return 1` to handle failures.

## Development Guidelines

### Code Style

- Functions use `args:` namespace (public) and `args::` namespace (internal).
- Heavy use of bash namerefs (`local -n`) for zero-copy variable injection.
- Parameters are parsed positionally within each function -- order matters.
- ShellCheck directives are used where nameref behavior triggers false positives (SC2178, SC2034).
- Tabs for indentation.

### Testing

Tests are in `bash-args.test` (not `.sh`). Each test function follows the naming convention `test:<category>:<scenario>`. Tests use `assert` and `assert:array-eq` helpers (sourced externally). The test file sources `bash-args.sh` directly.

Test categories: smoke, feature (required/optional, long-only, bundle, count, accumulate, pattern, err, separator), acceptance (combined features), regression (edge cases), integration (multi-function pipelines).

Results are recorded in `bash-args.test.md`.

### Known Limitations

See README.md "Limitations" section.
