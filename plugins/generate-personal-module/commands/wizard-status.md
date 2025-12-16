---
description: View personality wizard session status and progress
argument-hint: [session-id]
allowed-tools: Bash, Read
---

# Wizard Session Status

Check the current status and progress of a personality wizard session.

## Usage

```bash
# View specific session
/wizard-status <session-id>

# View all sessions
/wizard-status
```

!`bash scripts/wizard-status.sh "$1"`
