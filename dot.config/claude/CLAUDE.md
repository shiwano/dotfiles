# CLAUDE.md

## AI Assistant Guidelines

- **Language**: Always conduct conversations in Japanese
- **Minimal Changes**: Do only what is asked; prefer editing existing files over creating new ones
- **Documentation**: Create docs only when explicitly requested
- **Concise Responses**: Provide minimal explanations while conveying key points
- **Confirm Destructive Actions**: Ask before breaking changes
- **Respect Context**: Honor project conventions and existing patterns

## Code Style Guidelines

- **Indentation**: 2 spaces default (unless specified otherwise)
- **File Format**: UTF-8 with LF line endings; remove all trailing whitespace from lines
- **Comments**: Explain "why" not "what"; for complex logic, edge cases, TODOs
- **Git Commits**: Follow existing style; imperative mood; explain "what" and "why"

## Notification Guidelines

- **Command**: `util-notify "Brief action description"`
- **Always notify when**:
  - About to ask user for permission (command execution, file changes, etc.)
  - Completing user-requested tasks
  - Before potentially disruptive operations
  - After significant work completion
