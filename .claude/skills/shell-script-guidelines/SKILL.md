---
name: shell-script-guidelines
description: Shell script best practices and guidelines. Use when writing, reviewing, or modifying shell scripts (.sh, bash files, bin/* scripts).
user-invocable: false
---

# Shell Script Guidelines

## File Structure

- **Shebang**: `#!/usr/bin/env bash` (first line)
- **Error handling**: `set -euo pipefail` (after shebang with blank line)
- **Function order**: `usage()` → Helper functions → `main()` → `main "$@"`

## usage() Function

- **Format**: `cat <<EOF >&"$fd"` with heredoc; accept file descriptor as parameter
- **Output**: stdout (fd=1) when called with `--help`; stderr (fd=2) on errors (default)
- **Content**: Include Usage line, description, and Examples section
- **Help flags**: Support both `-h` and `--help` in `main()`

## main() Function

- **Arguments**: Always accept `"$@"` as parameters
- **Help check**: First check for help flags and call `usage()`, then `return 0`
- **Variables**: Declare all variables with `local`
- **Returns**: Use explicit `return 0` for success, `return 1` for errors

## Argument Parsing

- **Simple**: `if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then`
- **Complex**: Use `while [[ $# -gt 0 ]]; do case $1 in ... esac; done` pattern
- **Options**: Support both short (`-t`) and long (`--title`) forms
- **Validation**: Check required arguments and show usage on error

## Error Messages

- **Output**: Always output to stderr with `>&2`
- **Command checks**: `command -v cmd >/dev/null 2>&1`
- **Empty checks**: `[ -z "$var" ] && return 0` for optional outputs
- **Input validation**: Check stdin with `[ -t 0 ]` if expecting piped input

## Arrays and Commands

- **Array init**: `local args=()`
- **Array append**: `args+=(-flag value)`
- **Array expand**: `command "${args[@]}"`
- **Pipe handling**: Use `|| true` for commands that may fail: `git log || true`

## Other Conventions

- **String interpolation**: Use `"${var}"` for variable expansion
- **Default values**: Use `"${1:-.}"` pattern for optional arguments with defaults
- **Regex matching**: `[[ "$var" =~ ^pattern$ ]]` with `"${BASH_REMATCH[1]}"` for captures
- **Comments**: Add brief comments for complex logic; use shellcheck disable comments when needed
- **Helper functions**: Extract complex logic into separate functions before `main()`

## Basic Template

```bash
#!/usr/bin/env bash

set -euo pipefail

usage() {
	local fd="${1:-2}"
	cat <<EOF >&"$fd"
Usage: script-name [options] <args>

Description of what this script does.

Examples:
  script-name arg1
  script-name --option value
EOF
}

main() {
	if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
		usage 1
		return 0
	fi

	# Validation example
	if [ "$#" -lt 1 ]; then
		usage
		return 1
	fi

	# Script logic here
}

main "$@"
```
