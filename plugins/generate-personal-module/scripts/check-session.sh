#!/bin/bash
# check-session.sh - 检查会话状态并决定是否可以恢复

set -euo pipefail

SESSION_ID=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查会话是否存在
STATE_FILE="${HOME}/.claude/personality-wizard/session-${SESSION_ID}.json"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "❌ 会话不存在: ${SESSION_ID}"
  echo ""
  echo "可用会话:"
  bash "${SCRIPT_DIR}/state-manager.sh" "" list
  exit 1
fi

# 检查会话是否完成
IS_COMPLETE=$(bash "${SCRIPT_DIR}/state-manager.sh" "${SESSION_ID}" complete)

if [[ "$IS_COMPLETE" == "true" ]]; then
  echo "✅ 会话已完成所有6轮问答"
  echo ""
  echo "下一步: 生成人格模型"
  echo "   bash scripts/merge-personality.sh ${SESSION_ID}"
  exit 0
fi

# 会话未完成，可以恢复
CURRENT_ROUND=$(jq -r '.current_round' "$STATE_FILE")
REMAINING=$((6 - CURRENT_ROUND))

echo "⏳ 会话可恢复"
echo "   已完成: Round ${CURRENT_ROUND}/6"
echo "   剩余: ${REMAINING} 轮"
echo ""
echo "准备恢复向导..."
