---
description: Apply a personality model to Claude Code
argument-hint: <session-id> [--global|--project]
allowed-tools: Bash, Write, Read
---

# Apply Personality Model

Apply a generated personality model to your Claude Code configuration.

## Usage

```bash
# Apply to current project (default)
/apply-personality <session-id>

# Apply to current project (explicit)
/apply-personality <session-id> --project

# Apply globally to all projects
/apply-personality <session-id> --global
```

## Options

- **--project**: Apply to current project's `CLAUDE.md` (default)
- **--global**: Apply to global `~/.claude/CLAUDE.md`

!`bash scripts/apply-personality.sh "$1" "$2"`
