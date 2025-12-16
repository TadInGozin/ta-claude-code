#!/bin/bash
# apply-personality.sh - Apply personality model to Claude Code

set -euo pipefail

SESSION_ID="${1:-}"
SCOPE="${2:---project}"
AUTO_CONFIRM="${3:-}"
MODELS_DIR="${HOME}/.claude/personality-models"

# Validate inputs
if [[ -z "$SESSION_ID" ]]; then
  echo "❌ 错误: 请提供 session ID"
  echo ""
  echo "用法: /apply-personality <session-id> [--global|--project]"
  echo ""
  echo "查看可用模型:"
  echo "  /list-personalities"
  exit 1
fi

# Check if model exists
MODEL_FILE="${MODELS_DIR}/session-${SESSION_ID}.md"

if [[ ! -f "$MODEL_FILE" ]]; then
  echo "❌ 模型不存在: ${SESSION_ID}"
  echo ""
  echo "可用模型:"
  bash "$(dirname "$0")/list-personalities.sh"
  exit 1
fi

# Determine target file
case "$SCOPE" in
  --global)
    TARGET_FILE="${HOME}/.claude/CLAUDE.md"
    SCOPE_DESC="全局配置"
    ;;
  --project|"")
    TARGET_FILE="./CLAUDE.md"
    SCOPE_DESC="当前项目"
    ;;
  *)
    echo "❌ 无效的选项: ${SCOPE}"
    echo "支持的选项: --global, --project"
    exit 1
    ;;
esac

# Auto-confirm mode (for agent calls)
if [[ "$AUTO_CONFIRM" != "--yes" ]]; then
  # Interactive mode - show details and ask for confirmation
  echo "📋 准备应用人格模型"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Session ID: ${SESSION_ID}"
  echo "应用范围: ${SCOPE_DESC}"
  echo "目标文件: ${TARGET_FILE}"
  echo ""

  # Extract model summary
  ARCHETYPE=$(grep -A 1 "^### 🎭 Core Archetype" "$MODEL_FILE" | grep "Primary:" | cut -d':' -f2 | xargs || echo "未知")
  echo "人格原型: ${ARCHETYPE}"
  echo ""

  # Confirm action
  echo "⚠️  注意:"
  if [[ -f "$TARGET_FILE" ]]; then
    echo "  - 目标文件已存在，内容将被追加"
  else
    echo "  - 目标文件不存在，将被创建"
  fi
  echo ""

  # Ask for confirmation
  read -p "确认应用? (y/N): " -n 1 -r
  echo ""

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 0
  fi
fi

# Create backup if file exists (silent in auto mode)
if [[ -f "$TARGET_FILE" ]]; then
  BACKUP_FILE="${TARGET_FILE}.backup-$(date +%s)"
  cp "$TARGET_FILE" "$BACKUP_FILE"
  if [[ "$AUTO_CONFIRM" != "--yes" ]]; then
    echo "✅ 已备份原文件: ${BACKUP_FILE}"
  fi
fi

# Ensure directory exists
mkdir -p "$(dirname "$TARGET_FILE")"

# Apply model
echo "" >> "$TARGET_FILE"
echo "# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$TARGET_FILE"
echo "# Personality Model - Session ${SESSION_ID}" >> "$TARGET_FILE"
echo "# Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$TARGET_FILE"
echo "# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$TARGET_FILE"
echo "" >> "$TARGET_FILE"
cat "$MODEL_FILE" >> "$TARGET_FILE"

# Output success message
if [[ "$AUTO_CONFIRM" == "--yes" ]]; then
  # Silent mode for agent - just output success flag
  echo "SUCCESS"
else
  # Interactive mode - show detailed success message
  echo ""
  echo "✅ 人格模型已应用"
  echo ""
  echo "📄 目标文件: ${TARGET_FILE}"
  echo ""
  echo "💡 下一步:"
  echo "  - 重启Claude Code生效"
  echo "  - 或开始新的对话会话"
  echo ""

  # Show preview
  echo "📖 配置预览 (前10行):"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  tail -n 15 "$TARGET_FILE" | head -n 10
  echo "..."
  echo ""
fi
