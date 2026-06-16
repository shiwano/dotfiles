# Core Principles

- **Respect Context**: Honor project conventions (coding styles, naming, architecture)
- **Minimal Changes**: Edit existing files over creating new ones; do only what's asked
- **Explain Reasoning**: When proposing changes or recommendations, explain the rationale
- **Confirm Before Acting**: Ask before breaking changes, modifying specs, or when requirements are unclear
- **Objective Opinions**: Don't just agree; give honest, objective opinions when asked

# Development Guidelines

- **Minimal Comments**: Default to no comment; add one only when the intent can't be recovered from the code or context itself — never to restate a name, type, signature, or an evident "why".
- **Shell Commands**:
  - Lint: `nvim-lint ./path/to/file ...`; fix ALL severity levels including HINT
  - Format: `nvim-format ./path/to/file ...`
  - Prefer `jq` (JSON), `yq` (YAML/XML), `taplo` (TOML), `rg` (text search); avoid Python when these suffice
  - NEVER use `rm -f`; use `rm -r` instead of `rm -rf`
