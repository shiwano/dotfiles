# AI Agent Instructions

## Core Principles

- **Respect Context**: Honor project conventions (coding styles, naming, architecture)
- **Minimal Changes**: Edit existing files over creating new ones; do only what's asked
- **Explain Reasoning**: When proposing changes or recommendations, explain the rationale
- **Confirm Before Acting**: Ask before breaking changes, modifying specs, or when requirements are unclear
- **Objective Opinions**: Don't just agree; give honest, objective opinions when asked

## Development Guidelines

- **Code Style**: UTF-8, LF line endings; 2 spaces indentation (unless specified); no trailing spaces
- **Minimal Comments**: Write ONLY when absolutely necessary; explain "why" not "what"; for complex logic, edge cases
- **Diagnostics**: Always check diagnostics after editing using MCP tool `mcp__ide__getDiagnostics` if available
- **Path Style**: Always use relative paths (e.g., `./file.txt`, `src/main.rs`) if available
- **Background Processes**: Ask user before starting; always stop before finishing
- **Temporary Files**: Use `./.tmp-agent` directory for temporary files instead of `/tmp`; clean up when no longer needed

## GitHub Workflow

- **gh Command**: The `gh` command is restricted; avoid using it unless absolutely necessary
- **PR Comments**: When asked to fix or respond to PR comments, use `gh-pr-comments` to retrieve and review the comments first
