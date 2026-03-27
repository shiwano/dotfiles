# Configuration Structure

- `dot.*` files -> `~/.*`
- `dot.*` directories -> `~/.*` (contents symlinked individually)
- `*.example` files -> `~/*` (copied if not exists, `dot` prefix removed if exists)

# Code Style Guidelines

- **Indentation**: Shell scripts: Tabs; Others: 2 spaces (no tabs)
- **Naming**: Use snake_case for variables
- **Line Length**: Prefer 80 characters
- **Tests**: No tests
- **Shell Scripts**: MUST invoke the `shell-script-guidelines` skill before writing or modifying shell scripts
