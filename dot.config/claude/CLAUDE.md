# Core Principles

- **Respect Context**: Honor project conventions (coding styles, naming, architecture)
- **Minimal Changes**: Edit existing files over creating new ones; do only what's asked
- **Explain Reasoning**: When proposing changes or recommendations, explain the rationale
- **Confirm Before Acting**: Ask before breaking changes, modifying specs, or when requirements are unclear
- **Objective Opinions**: Don't just agree; give honest, objective opinions when asked

# Development Guidelines

- **Minimal Comments**: Default to none; add one only when intent can't be recovered from the code itself, never to restate a name, type, signature, or evident "why".
- **Minimal Prose** (docs, AGENTS.md, skills): Write only facts a reader needs. No rationale or self-justification unless asked (e.g. "so that…", "not an X but a Y"). Don't restate what's documented elsewhere. Don't editorialize.
- **Lint/Format**: Runs automatically via a Claude hook; no need to invoke manually
  - Lint: `nvim-lint ./path/to/file ...`; fix ALL severity levels including HINT
  - Format: `nvim-format ./path/to/file ...`
- **Shell Commands**:
  - Prefer `jq`, `yq`, `taplo`, `rg`; avoid Python when these suffice
