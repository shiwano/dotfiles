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

- **Checkhealth Neovim**: `nvim --headless -c 'checkhealth nvim' +q`
- **Check .zshrc syntax**: `zsh -n dot.zshrc`
- **Check Shell Script**: `shellcheck ./path/to/file.sh`
- **Format Shell Script**: `shfmt -w ./path/to/file.sh`
- **Format Lua**: `stylua ./path/to/file.lua`
- **Format Markdown**: `markdownfmt -w ./path/to/file.md`

## Code Style Guidelines

- **Indentation**: Shell scripts: Tabs; Others: 2 spaces (no tabs)
- **File Encoding**: UTF-8 with LF line endings
- **Naming**: Use descriptive names; snake_case for variables, PascalCase for types/structs
- **Error Handling**: Always check errors; prefer early returns
- **Shell Scripts**: Always include `set -euo pipefail` at the beginning; Use `main` function
- **Line Length**: Prefer 80 characters (colorcolumn set to 81 in nvim)
- **Trailing Spaces**: Remove trailing spaces from all lines
- **Documentation**: Include comments for complex logic and public functions
- **Git Commits**: Clear, concise messages describing the purpose of changes
- **Tests**: No tests
