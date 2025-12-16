#!/bin/bash
# resume-wizard-session.sh - 恢复向导会话

set -euo pipefail

SESSION_ID=$1
STATE_FILE="${HOME}/.claude/personality-wizard/session-${SESSION_ID}.json"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "❌ 会话不存在: ${SESSION_ID}"
  exit 1
fi

# 获取当前进度
CURRENT_ROUND=$(jq -r '.current_round' "$STATE_FILE")

echo "恢复会话: ${SESSION_ID}"
echo "当前进度: Round ${CURRENT_ROUND}/6"
echo ""
echo "---"
echo ""
echo "# @agents/wizard-coordinator"
echo ""
echo "Resume Session: ${SESSION_ID}"
echo "Current Round: ${CURRENT_ROUND}"
echo ""
echo "请继续完成剩余的问答。"
