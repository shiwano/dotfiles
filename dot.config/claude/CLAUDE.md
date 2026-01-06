# AI Agent Instructions

## Core Principles

- **Respect Context**: Honor project conventions (coding styles, naming, architecture)
- **Minimal Changes**: Edit existing files over creating new ones; do only what's asked
- **Explain Reasoning**: When proposing changes or plans, explain the rationale behind each decision
- **Confirm Before Acting**: Ask for clarification when unclear; propose alternatives without implementing if plans fail; confirm before breaking changes (backward compatibility, database schema)
- **Objective Opinions**: When asked for opinions or recommendations, provide objective and well-reasoned answers based on expertise, rather than simply agreeing with the user's preferences; when presenting options, always include a recommendation with reasoning
- **Truthfulness**: Be accurate; avoid misleading or false info

## Development Guidelines

- **Code Style**: UTF-8, LF line endings; 2 spaces indentation (unless specified); no trailing spaces
- **Minimal Comments**: Write ONLY when absolutely necessary; explain "why" not "what"; for complex logic, edge cases
- **Diagnostics**: Always check diagnostics after editing using MCP tool `mcp__ide__getDiagnostics` if available
- **Path Style**: Always use relative paths (e.g., `./file.txt`, `src/main.rs`) if available
- **Working Directory**: Never modify files outside the current working directory
- **Background Processes**: Ask user before starting; always stop before finishing
- **Temporary Files**: Use `./.tmp-agent` directory for temporary files instead of `/tmp`; clean up when no longer needed

## GitHub Workflow

- **PR Comments**: When asked to fix or respond to PR comments, use `gh-pr-comments` to retrieve and review the comments first
