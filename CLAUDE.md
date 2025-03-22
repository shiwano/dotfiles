# CLAUDE.md - Repository Documentation

## Check/Format Commands

- **Checkhealth Neovim**: `nvim --headless -c 'checkhealth nvim' +q`
- **Check .zshrc syntax** `zsh -n dot.zshrc`
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
- **Documentation**: Include comments for complex logic and public functions
- **Git Commits**: Clear, concise messages describing the purpose of changes
- **Tests**: No tests

## Environment Settings

- **Terminal**: Uses zsh with custom prompt
- **Editor**: Neovim with many plugins (see dot.config/nvim)
- **Package Manager**: Uses asdf for version management
- **Git**: Custom git aliases in dot.gitconfig
