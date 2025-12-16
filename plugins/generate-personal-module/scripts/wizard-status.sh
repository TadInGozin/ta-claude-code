#!/bin/bash
# wizard-status.sh - View wizard session status and progress

set -euo pipefail

SESSION_ID="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIZARD_STATE_DIR="${HOME}/.claude/personality-wizard"

# If no session ID provided, list all sessions
if [[ -z "$SESSION_ID" ]]; then
  echo "📋 所有向导会话"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  session_count=0
  for state_file in "${WIZARD_STATE_DIR}"/session-*.json; do
    if [[ -f "${state_file}" ]]; then
      session_count=$((session_count + 1))

      sid=$(jq -r '.session_id' "${state_file}")
      rounds=$(jq -r '.current_round' "${state_file}")
      created=$(jq -r '.created_at' "${state_file}")
      seed=$(jq -r '.seed_input // "无"' "${state_file}")

      # Calculate status
      if [[ $rounds -ge 6 ]]; then
        status="✅ 完成"
      else
        status="⏳ 进行中 (Round ${rounds}/6)"
      fi

      echo ""
      echo "${session_count}. Session ${sid}"
      echo "   状态: ${status}"
      echo "   创建: ${created}"
      echo "   Seed: ${seed}"
    fi
  done

  if [[ $session_count -eq 0 ]]; then
    echo ""
    echo "暂无会话"
    echo ""
    echo "💡 提示: 使用 /start-wizard 创建新会话"
  fi

  echo ""
  exit 0
fi

# View specific session
STATE_FILE="${WIZARD_STATE_DIR}/session-${SESSION_ID}.json"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "❌ 会话不存在: ${SESSION_ID}"
  echo ""
  echo "可用会话:"
  bash "$0" ""  # Call self without arguments to list all
  exit 1
fi

# Display detailed session status
echo "📊 会话详情: ${SESSION_ID}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Basic info
CREATED=$(jq -r '.created_at' "$STATE_FILE")
UPDATED=$(jq -r '.last_updated' "$STATE_FILE")
CURRENT_ROUND=$(jq -r '.current_round' "$STATE_FILE")
SEED_INPUT=$(jq -r '.seed_input // "无"' "$STATE_FILE")

echo "创建时间: ${CREATED}"
echo "最后更新: ${UPDATED}"
echo "Seed关键词: ${SEED_INPUT}"
echo ""

# Progress
echo "📈 问答进度: ${CURRENT_ROUND}/6"
echo ""

# Detailed responses
if [[ $CURRENT_ROUND -gt 0 ]]; then
  echo "✅ 已完成的回答:"
  jq -r '.responses[] | "  Round \(.round) - \(.category): \(.answer)"' "$STATE_FILE"
  echo ""
fi

# Remaining rounds
REMAINING=$((6 - CURRENT_ROUND))
if [[ $REMAINING -gt 0 ]]; then
  echo "⏳ 待完成: ${REMAINING} 轮"
  echo ""

  # Show next steps
  if [[ $CURRENT_ROUND -eq 0 ]]; then
    echo "💡 下一步: 开始问答"
    echo "   使用 /resume-wizard ${SESSION_ID}"
  elif [[ $CURRENT_ROUND -lt 6 ]]; then
    echo "💡 下一步: 继续问答"
    echo "   使用 /resume-wizard ${SESSION_ID}"
  fi
else
  echo "✅ 所有6轮已完成"
  echo ""
  echo "💡 下一步: 生成人格模型"
  echo "   bash scripts/merge-personality.sh ${SESSION_ID}"
fi

echo ""

# Seed analysis info (if exists)
if [[ "${SEED_INPUT}" != "无" ]]; then
  SEED_CONFIDENCE=$(jq -r '.seed_analysis.confidence // 0' "$STATE_FILE")
  if [[ "$SEED_CONFIDENCE" != "0" ]]; then
    echo "🌱 Seed分析信息:"
    echo "   置信度: ${SEED_CONFIDENCE}"
    echo "   Notes:"
    jq -r '.seed_analysis.notes[]? // empty' "$STATE_FILE" | sed 's/^/     - /'
    echo ""
  fi
fi
