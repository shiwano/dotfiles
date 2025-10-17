# CLAUDE.md - Repository Documentation

## Configuration Structure

### Dotfiles Organization

- `dot.*` files → `~/.*` (symlinked by setup.sh)
- `dot.*` directories → `~/.*` (contents symlinked individually)
- `*.example` files → `~/*` (copied if not exists, `dot` prefix removed if exists)

### Key Configuration Files

- **Shell**: `dot.zshrc` (main config), `dot.zshrc.local.example` (local overrides)
- **Shell Scripts**: `bin/*` (utility scripts available in PATH)
- **Git**: `dot.gitconfig` (aliases, delta pager, user info)
- **Neovim**: `dot.config/nvim/init.lua` (lazy.nvim plugin manager)
- **Tmux**: `dot.config/tmux/tmux.conf` (prefix Ctrl+t, custom status)
- **Terminal**: `dot.config/ghostty/config` (font, theme, keybinds)
- **Window Manager**: `dot.hammerspoon/init.lua` (layout shortcuts)
- **Version Manager**: `dot.config/mise/config.toml` (languages, tools, packages), `Brewfile` (Homebrew packages)
- **AI Assistant**: `dot.claude/claude/CLAUDE.md` (global instructions), `dot.claude/claude/settings.json` (global settings)

## Check/Format Commands

- **Check diagnostics**: Use MCP IDE tool `mcp__ide__getDiagnostics` if available; run formatters only when issues found
- **Format Commands** (run if diagnostics unavailable or show issues):
  - Shell Script: `shfmt -w ./path/to/file.sh`
  - Lua: `stylua ./path/to/file.lua`
  - Markdown: `markdownfmt -w ./path/to/file.md`

## Code Style Guidelines

- **Indentation**: Shell scripts: Tabs; Others: 2 spaces (no tabs)
- **File Encoding**: UTF-8 with LF line endings
- **Naming**: Use descriptive names; snake_case for variables, PascalCase for types/structs
- **Error Handling**: Always check errors; prefer early returns
- **Line Length**: Prefer 80 characters (colorcolumn set to 81 in nvim)
- **Trailing Spaces**: Remove trailing spaces from all lines
- **Documentation**: Include comments for complex logic and public functions
- **Git Commits**: Clear, concise messages describing the purpose of changes
- **Tests**: No tests

## Shell Script Guidelines

### File Structure

- **Shebang**: `#!/usr/bin/env bash` (first line)
- **Error handling**: `set -euo pipefail` (after shebang with blank line)
- **Function order**: `usage()` → Helper functions → `main()` → `main "$@"`

### usage() Function

- **Format**: `cat <<EOF >&$fd` with heredoc; accept file descriptor as parameter
- **Output**: stdout (fd=1) when called with `--help`; stderr (fd=2) on errors (default)
- **Content**: Include Usage line, description, and Examples section
- **Help flags**: Support both `-h` and `--help` in `main()`

### main() Function

- **Arguments**: Always accept `"$@"` as parameters
- **Help check**: First check for help flags and call `usage()`, then `return 0`
- **Variables**: Declare all variables with `local`
- **Returns**: Use explicit `return 0` for success, `return 1` for errors

### Argument Parsing

- **Simple**: `if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then`
- **Complex**: Use `while [[ $# -gt 0 ]]; do case $1 in ... esac; done` pattern
- **Options**: Support both short (`-t`) and long (`--title`) forms
- **Validation**: Check required arguments and show usage on error

### Error Messages

- **Output**: Always output to stderr with `>&2`
- **Command checks**: `command -v cmd >/dev/null 2>&1`
- **Empty checks**: `[ -z "$var" ] && return 0` for optional outputs
- **Input validation**: Check stdin with `[ -t 0 ]` if expecting piped input

### Arrays and Commands

- **Array init**: `local args=()`
- **Array append**: `args+=(-flag value)`
- **Array expand**: `command "${args[@]}"`
- **Pipe handling**: Use `|| true` for commands that may fail: `git log || true`

### Other Conventions

- **String interpolation**: Use `"${var}"` for variable expansion
- **Default values**: Use `"${1:-.}"` pattern for optional arguments with defaults
- **Regex matching**: `[[ "$var" =~ ^pattern$ ]]` with `"${BASH_REMATCH[1]}"` for captures
- **Comments**: Add brief comments for complex logic; use shellcheck disable comments when needed
- **Helper functions**: Extract complex logic into separate functions before `main()`

### Basic Template

```bash
#!/usr/bin/env bash

set -euo pipefail

usage() {
	local fd="${1:-2}"
	cat <<EOF >&$fd
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
