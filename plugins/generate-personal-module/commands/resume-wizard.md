---
description: 恢复未完成的人格向导会话
argument-hint: [session-id]
allowed-tools: Bash, Read, Task
---

# 恢复人格向导

正在加载会话...

!`bash scripts/state-manager.sh "$1" status`

## 检查会话状态

!`bash scripts/check-session.sh "$1"`

## 恢复向导

如果会话有效且未完成，我将启动wizard-coordinator agent继续问答流程。

!`bash scripts/resume-wizard-session.sh "$1"`
