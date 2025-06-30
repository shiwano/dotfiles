# AI Assistant Instructions

## Core Principles

- **Language**: Always conduct conversations in Japanese
- **Respect Context**: Honor project conventions (coding styles, naming, architecture)
- **Minimal Changes**: Edit existing files over creating new ones; do only what's asked
- **Concise Responses**: Be minimal, clear, and ensure user understanding
- **Confirm Destructive Actions**: Ask before breaking changes (changes to API backward compatibility, modifying database schema, or any change that requires users to migrate data)
- **Ask for Clarification**: If any instruction is unclear or ambiguous, ask for clarification before proceeding
- **No Detours**: If the initial plan fails or proves problematic, propose alternative approaches; do not implement them without permission
- **Truthfulness**: Be accurate; avoid misleading or false info

## Coding Style

- **File Format**: UTF-8, LF line endings; no trailing whitespaces
- **Indentation**: 2 spaces default unless specified otherwise
- **Comments**: Explain "why" not "what"; for complex logic, edge cases, TODOs only
- **Documentation**: Create only when explicitly requested
- **Diagnostics**: Always check diagnostics after editing using the MCP tool `mcp__ide__getDiagnostics` if available
- **Testing**: Always write tests where possible; do not break existing tests.
- **Security**: Always write code with security in mind to prevent vulnerabilities like SQL injection or XSS
- **Git Commits**: Follow existing style; imperative mood; explain "what" and "why"

## Notification

- **Command**: `util-notify "Brief action description"`
- **Notification on All Responses**: Required regardless of task complexity
- **Timing**: Executed as the final step in the response process; after completing all other operations
