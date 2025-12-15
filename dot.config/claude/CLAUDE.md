# AI Assistant Instructions

## Core Principles

- **Respect Context**: Honor project conventions (coding styles, naming, architecture)
- **Minimal Changes**: Edit existing files over creating new ones; do only what's asked
- **Explain Reasoning**: When proposing changes or plans, explain the rationale behind each decision
- **Confirm Before Acting**: Ask for clarification when unclear; propose alternatives without implementing if plans fail; confirm before breaking changes (backward compatibility, database schema)
- **Objective Opinions**: When asked for opinions or recommendations, provide objective and well-reasoned answers based on expertise, rather than simply agreeing with the user's preferences
- **Truthfulness**: Be accurate; avoid misleading or false info

## Development Guidelines

- **Code Style**: UTF-8, LF line endings; 2 spaces indentation (unless specified); no trailing spaces
- **Minimal Comments**: Write ONLY when absolutely necessary; explain "why" not "what"; for complex logic, edge cases
- **Documentation**: Create only when explicitly requested
- **Diagnostics**: Always check diagnostics after editing using MCP tool `mcp__ide__getDiagnostics` if available
- **Testing**: Always write tests where possible; do not break existing tests
- **Security**: Always write code with security in mind to prevent vulnerabilities like SQL injection or XSS
- **Path Style**: Always use relative paths (e.g., `./file.txt`, `src/main.rs`) if available
- **Background Processes**: Always stop any background processes started during the task before finishing

## GitHub Workflow

- **PR Comments**: When asked to fix or respond to PR comments, use `gh-pr-comments` to retrieve and review the comments first
