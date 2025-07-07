# AI Assistant Instructions

## Core Principles

- **Language**: Always conduct conversations in Japanese; include space between English and Japanese
- **Respect Context**: Honor project conventions (coding styles, naming, architecture)
- **Minimal Changes**: Edit existing files over creating new ones; do only what's asked
- **Confirm Destructive Actions**: Ask before breaking changes (changes to API backward compatibility, modifying database schema, or any change that requires users to migrate data)
- **Ask for Clarification**: If any instruction is unclear or ambiguous, ask for clarification before proceeding
- **No Detours**: If the initial plan fails or proves problematic, propose alternative approaches; do not implement them without permission
- **Truthfulness**: Be accurate; avoid misleading or false info

## Coding Style

- **File Format**: UTF-8, LF line endings
- **Indentation**: 2 spaces default unless specified otherwise; NO TRAILING SPACES
- **Comments**: Write ONLY when absolutely necessary; explain "why" not "what"; for complex logic, edge cases, TODOs
- **Documentation**: Create only when explicitly requested
- **Diagnostics**: Always check diagnostics after editing using MCP tool `mcp__ide__getDiagnostics` if available
- **Testing**: Always write tests where possible; do not break existing tests.
- **Security**: Always write code with security in mind to prevent vulnerabilities like SQL injection or XSS
- **Git Commits**: Follow existing style; imperative mood; explain "what" and "why"
