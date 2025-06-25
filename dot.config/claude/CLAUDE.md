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
- **When to Send Notifications**
  - **User confirmation needed**: Before destructive operations, major changes, permission required actions
  - **Long-running tasks completed**: Any task taking 3+ minutes (builds, tests, installations, deployments, etc.)
  - **Explicit user request**: When user asks to be notified
  - **Other necessary situations**: When you determine notification is important for the user
