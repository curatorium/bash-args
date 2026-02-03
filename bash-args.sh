# Copyright (c) 2025 Mihai Stancu (https://github.com/curatorium)

# @name flag
# @type function
# @desc Parse a boolean flag (e.g., -v, --verbose)
#
# @usage args:flag [-r|--required] [-b|--bundle] [--count] <long> <short> [--err <msg>]
#
# @flag [-r|--required] -- Make the flag required.
# @flag [-b|--bundle] -- Also match within combined short flags (e.g., -vfs). Requires <short>.
# @flag [--count] -- Count occurrences instead of setting a boolean. Variable will be set to the number of matches (0 if absent).
# @arg  <long> -- Long name of the flag (also used as variable name).
# @arg  <short> -- Short (1 letter) name of the flag. Use "" for long-only.
# @opt  [--err <msg>] -- Error message printed to stderr on failure.
#
# @return 0 -- Flag found or optional and absent.
# @return 1 -- Flag absent and required.
function args:flag() {
	declare -p ARGS &>/dev/null || { echo "ERROR: Add 'local ARGS=(\"\$@\")' before ${FUNCNAME[0]}." >&2; return 1; };
	# shellcheck disable=SC2178  # nameref is a string, points to an array
	local -n TOKENS="ARGS"

	local err=""; (($# >= 2)) && [[ "${*: -2:1}" == "--err" ]] && err="${*: -1}" && set -- "${@:1:$#-2}";
	local required="false"; [[ "${1:-}" == "-r" || "${1:-}" == "--required" ]] && required="true" && shift;
	local bundle="false";   [[ "${1:-}" == "-b" || "${1:-}" == "--bundle" ]] && bundle="true" && shift;
	local count="false";    [[ "${1:-}" == "--count" ]] && count="true" && shift;
	local -n value="${1//[^_0-9a-zA-Z]/_}";
	local long="${1?ERROR: args:flag requires <long>}";   shift;
	local short="${1?ERROR: args:flag requires <short>}"; shift;

	local scan; [[ -z "$short" ]] && scan="^--${long}$" || scan="^-${short}$|^--${long}$";

	local hit hits=0;
	while args::capture hit "$scan"; do ((hits++)); done

	# Bundle: also match within combined short flags (-vfs)
	if [[ "$bundle" == "true" && -n "$short" ]]; then
		local bscan="^-[^-]*${short}";
		local rest;
		while args::capture hit "$bscan"; do
			((hits++));
			rest="${hit//$short/}"; rest="${rest#-}";
			TOKENS=(${rest:+-$rest} "${TOKENS[@]}");
		done
	fi

	# Flag when --count value=$hits otherwise value=true
	((hits > 0)) && value="true";
	[[ "$count" == "true" ]] && value="$hits";

  # Flag found or optional and absent.
	((hits > 0)) || [[ "$required" == "false" ]] && return 0;

	# Flag absent and required, show error
	[[ -n "$err" ]] && echo "$err" >&2;
	return 1;
}

# @name opt
# @type function
# @desc Parse an option with a value (e.g., -n foo, --name=foo)
#
# @usage args:opt [-r|--required] [-a|--accumulate] <long> <short> [pattern] [--err <msg>]
#
# @flag [-r|--required] -- Make the option required.
# @flag [-a|--accumulate] -- Collect all occurrences into an array instead of last-wins. Variable must be declared as an array.
# @arg  <long> -- Long name of the option (also used as variable name).
# @arg  <short> -- Short (1 letter) name of the option. Use "" for long-only.
# @arg  [pattern] -- RegEx pattern to validate value. Default "(.*)".
# @opt  [--err <msg>] -- Error message printed to stderr on failure.
#
# @return 0 -- Option found and matches, or absent and optional.
# @return 1 -- Option absent and required, or found and mismatched.
function args:opt() {
	declare -p ARGS &>/dev/null || { echo "ERROR: Add 'local ARGS=(\"\$@\")' before ${FUNCNAME[0]}." >&2; return 1; };
	# shellcheck disable=SC2178  # nameref is a string, points to an array
	local -n TOKENS="ARGS"

	local err=""; (($# >= 2)) && [[ "${*: -2:1}" == "--err" ]] && err="${*: -1}" && set -- "${@:1:$#-2}";
	local required="false"; [[ "${1:-}" == "-r" || "${1:-}" == "--required" ]] && required="true" && shift;
	local accumulate="false"; [[ "${1:-}" == "-a" || "${1:-}" == "--accumulate" ]] && accumulate="true" && shift;
	local -n value="${1?ERROR: args:opt requires <long>}";
	local long="${1}"; shift;
	local short="${1?ERROR: args:opt requires <short>}"; shift;
	local pattern="${1:-(.*)}"; shift || true;

	local scan="^--${long}$|^--${long}=(.+)$"
	[[ -n "$short" ]] && scan="^-${short}$|^-${short}(.+)|--${long}|--${long}=(.+)$";

	# Scan all args and accumulate $values
	local rc=0 captured values=();
	while true; do
		args::capture captured "$scan" "$pattern";
		rc=$?;
		((rc == 0)) || break;
		values+=("$captured");
	done

	# Option was found but didn't match $pattern
	((rc == 2)) && { [[ -n "$err" ]] && echo "$err" >&2; return 1; };

	# Opt when --accumulate value=$values otherwise value=$values[0]
	((${#values[@]} > 0)) && value="${values[0]}";
	[[ "$accumulate" == "true" ]] && value=("${values[@]}");

	# Option found and matches, or absent and optional.
	((${#values[@]} > 0)) || [[ "$required" == "false" ]] && return 0;

	# Option absent and required, or found and mismatched.
	[[ -n "$err" ]] && echo "$err" >&2;
	return 1;
}

# @name arg
# @type function
# @desc Parse a positional argument
#
# @usage args:arg [-o|--optional] <name> [pattern] [--err <msg>]
#
# @flag [-o|--optional] -- Make the argument optional.
# @arg  <name> -- Variable name to assign the captured value.
# @arg  [pattern] -- RegEx pattern to validate value. Default "(.*)".
# @opt  [--err <msg>] -- Error message printed to stderr on failure.
#
# @return 0 -- Argument found and matches, or absent and optional.
# @return 1 -- Argument absent and required, or found and mismatched.
function args:arg() {
	declare -p ARGS &>/dev/null || { echo "ERROR: Add 'local ARGS=(\"\$@\")' before ${FUNCNAME[0]}." >&2; return 1; };
	# shellcheck disable=SC2178  # nameref is a string, points to an array
	local -n TOKENS="ARGS"
	local err=""; (($# >= 2)) && [[ "${*: -2:1}" == "--err" ]] && err="${*: -1}" && set -- "${@:1:$#-2}";

	local optional="false"; [[ "${1:-}" == "-o" || "${1:-}" == "--optional" ]] && optional="true" && shift;
	# shellcheck disable=SC2178  # nameref is a string, points to an array
	local -n value="${1?ERROR: args:arg requires <name>}"; shift;
	local pattern="${1:-(.*)}"; shift || true;

	[[ "${TOKENS[0]:-}" == "--" ]] && TOKENS=("${TOKENS[@]:1}");

	if ((${#TOKENS[@]} < 1)); then
		[[ "$optional" == "true" ]] && return 0;
		[[ -n "$err" ]] && echo "$err" >&2;
		return 1;
	fi

	local captured="${TOKENS[0]}";
	if [[ ! "$captured" =~ $pattern ]]; then
		[[ "$optional" == "true" ]] && return 0;
		[[ -n "$err" ]] && echo "$err" >&2;
		return 1;
	fi

	# shellcheck disable=SC2178  # nameref assigned a string
	value="${BASH_REMATCH[1]:-$captured}";

	# rewrite the $TOKENS array without the captured tokens
	TOKENS=("${TOKENS[@]:1}");
}

# @name varg
# @type function
# @desc Parse variadic (rest) arguments into an array
#
# @usage args:varg [-o|--optional] <name> [--err <msg>]
#
# @flag [-o|--optional] -- Make the arguments optional.
# @arg  <name> -- Array variable name to capture rest values.
# @opt  [--err <msg>] -- Error message printed to stderr on failure.
#
# @return 0 -- At least one argument found, or optional and none found.
# @return 1 -- No arguments and required.
function args:varg() {
	declare -p ARGS &>/dev/null || { echo "ERROR: Add 'local ARGS=(\"\$@\")' before ${FUNCNAME[0]}." >&2; return 1; };
	# shellcheck disable=SC2178  # nameref is a string, points to an array
	local -n TOKENS="ARGS";

	local err=""; (($# >= 2)) && [[ "${*: -2:1}" == "--err" ]] && err="${*: -1}" && set -- "${@:1:$#-2}";
	local optional="false"; [[ "${1:-}" == "-o" || "${1:-}" == "--optional" ]] && optional="true" && shift;
	# shellcheck disable=SC2178  # nameref is a string, points to an array
	local -n value="${1?ERROR: args:varg requires <name>}"; shift;

	[[ "${TOKENS[0]:-}" == "--" ]] && TOKENS=("${TOKENS[@]:1}");

	if ((${#TOKENS[@]} < 1)); then
		[[ "$optional" == "true" ]] && return 0;
		[[ -n "$err" ]] && echo "$err" >&2;
		return 1;
	fi

	value=("${TOKENS[@]}");

	# rewrite the $TOKENS array without the captured tokens
	TOKENS=();
}

# @name sub
# @type function
# @desc Parse a subcommand and split arguments at the subcommand boundary
#
# @usage args:sub [-o|--optional] <name> <rest> <pattern> [--err <msg>]
#
# @flag [-o|--optional] -- Make the subcommand optional.
# @arg  <name> -- Variable name to assign the subcommand name.
# @arg  <rest> -- Array variable name to capture arguments after the subcommand.
# @arg  <pattern> -- RegEx pattern to match the subcommand.
# @opt  [--err <msg>] -- Error message printed to stderr on failure.
#
# @return 0 -- Subcommand found, or optional and absent.
# @return 1 -- Subcommand absent and required, or found and mismatched.
function args:sub() {
	declare -p ARGS &>/dev/null || { echo "ERROR: Add 'local ARGS=(\"\$@\")' before ${FUNCNAME[0]}." >&2; return 1; };
	# shellcheck disable=SC2178  # nameref is a string, points to an array
	local -n TOKENS="ARGS";

	local err=""; (($# >= 2)) && [[ "${*: -2:1}" == "--err" ]] && err="${*: -1}" && set -- "${@:1:$#-2}";
	local optional="false"; [[ "${1:-}" == "-o" || "${1:-}" == "--optional" ]] && optional="true" && shift;
	# shellcheck disable=SC2178  # nameref is a string, points to an array
	local -n value="${1?ERROR: args:sub requires <name>}"; shift;
	local -n rest="${1?ERROR: args:sub requires <rest>}"; shift;
	local pattern="${1?ERROR: args:sub requires <pattern>}"; shift;

	local i captured;
	for ((i=0; i<${#TOKENS[@]}; i++)); do
		captured="${TOKENS[i]}";
		[[ "$captured" == "--" ]] && break;
		[[ ! "$captured" =~ $pattern ]] && continue;

		# shellcheck disable=SC2178  # nameref assigned a string
		value="${BASH_REMATCH[1]:-$captured}";
		rest=("${TOKENS[@]:i+1}");
		TOKENS=("${TOKENS[@]:0:i}");
		return 0;
	done

	[[ "$optional" == "true" ]] && return 0;
	[[ -n "$err" ]] && echo "$err" >&2;
	return 1;
}

# @name capture
# @type internal
# @desc Scan TOKENS for a matching token, extract value, remove from TOKENS. Stops at --.
#
# @usage args::capture <ref> <token> [value]
#
# @arg  <ref> -- Reference to assign captured value.
# @arg  <token> -- Token structure.
# @arg  [pattern] -- Value must match this pattern.
#
# @return 0 -- Token found and captured.
# @return 1 -- No matching token found.
# @return 2 -- Token found and consumed, value doesn't match pattern.
function args::capture() {
	# shellcheck disable=SC2178  # nameref is a string, points to an array
	local -n TOKENS="ARGS";

	local -n ref="${1}";   shift;
	local    tok="${1}";   shift;
	local    pat="${1:-}"; shift

	local i token tokens=() value;
	for ((i=0; i<${#TOKENS[@]}; i++)); do
		token="${TOKENS[i]}";

		# Stop at positional arguments separator
		[[ "$token" == "--" ]] && break;

		# Token not matched, go to next token (but save all uncaptured tokens)
		[[ ! "$token" =~ $tok ]] && tokens+=("$token") && continue;

		# Flag matched (no value pattern provided)
		# shellcheck disable=SC2034  # ref is a nameref, assigned for the caller
		[[ -z "$pat" ]] && ref="$token" && TOKENS=("${tokens[@]}" "${TOKENS[@]:i+1}") && return 0;

		# Value attached to option -o123 or --opt=123
		value="${BASH_REMATCH[1]:-${BASH_REMATCH[2]:-}}";
		# Value deattached from option -o 123 or --opt 123
		[[ -z "$value" ]] && ((++i)) && value="${TOKENS[i]}";

		# Value must match this pattern.
		# shellcheck disable=SC2034  # ref is a nameref, assigned for the caller
		[[ "$value" =~ $pat ]] && ref="${BASH_REMATCH[1]:-$value}" && TOKENS=("${tokens[@]}" "${TOKENS[@]:i+1}") && return 0;

		# Value found but didn't match pattern.
		TOKENS=("${tokens[@]}" "${TOKENS[@]:i+1}");
		return 2;
	done

	return 1;
}
