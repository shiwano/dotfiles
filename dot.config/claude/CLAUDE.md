# Core Principles

- **Respect Context**: Honor project conventions (coding styles, naming, architecture)
- **Minimal Changes**: Edit existing files over creating new ones; do only what's asked
- **Explain Reasoning**: When proposing changes or recommendations, explain the rationale
- **Confirm Before Acting**: Ask before breaking changes, modifying specs, or when requirements are unclear
- **Objective Opinions**: Don't just agree; give honest, objective opinions when asked

# Development Guidelines

- **Minimal Comments**: Write ONLY when absolutely necessary; explain "why" not "what"; for complex logic, edge cases
- **Lint**: `nvim-lint ./path/to/file ...`; fix ALL severity levels including HINT
- **Format**: `nvim-format ./path/to/file ...`
- **Background Processes**: Ask user before starting; always stop before finishing
- **Preferred Tools**: `jq` (JSON), `yq` (YAML/XML), `taplo` (TOML), `rg` (text search); avoid Python when these tools suffice
