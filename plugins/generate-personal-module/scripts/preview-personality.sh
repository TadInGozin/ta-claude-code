#!/bin/bash
# preview-personality.sh - Preview personality model details

set -euo pipefail

SESSION_ID="${1:-}"
MODELS_DIR="${HOME}/.claude/personality-models"

if [[ -z "$SESSION_ID" ]]; then
  echo "❌ 错误: 请提供 session ID"
  echo ""
  echo "用法: /preview-personality <session-id>"
  echo ""
  echo "查看可用模型:"
  echo "  /list-personalities"
  exit 1
fi

JSON_FILE="${MODELS_DIR}/session-${SESSION_ID}.json"
MD_FILE="${MODELS_DIR}/session-${SESSION_ID}.md"

if [[ ! -f "$JSON_FILE" ]] || [[ ! -f "$MD_FILE" ]]; then
  echo "❌ 模型不存在: ${SESSION_ID}"
  echo ""
  echo "可用模型:"
  bash "$(dirname "$0")/list-personalities.sh"
  exit 1
fi

# Display model preview
echo "🎭 人格模型预览"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Basic info
GENERATED=$(jq -r '.generated_at' "$JSON_FILE")
SEED=$(jq -r '.seed_input // "无"' "$JSON_FILE")

echo "📋 基本信息"
echo "  Session ID: ${SESSION_ID}"
echo "  生成时间: ${GENERATED}"
echo "  Seed关键词: ${SEED}"
echo ""

# Personality configuration
echo "🎭 人格配置"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Archetype
ARCHETYPE=$(jq -r '.personality.archetype.primary' "$JSON_FILE")
echo "  原型: ${ARCHETYPE}"

# Language
VERBOSITY=$(jq -r '.personality.language.verbosity' "$JSON_FILE")
WARMTH=$(jq -r '.personality.language.warmth' "$JSON_FILE")
echo "  表达: ${VERBOSITY}"
echo "  距离: ${WARMTH}"

# Behavior
CORRECTION=$(jq -r '.personality.behavior.correction_style' "$JSON_FILE")
INITIATIVE=$(jq -r '.personality.behavior.initiative_level' "$JSON_FILE")
echo "  纠错: ${CORRECTION}"
echo "  主导: ${INITIATIVE}"

# Constraints
echo "  约束:"
jq -r '.personality.constraints[]? // empty' "$JSON_FILE" | sed 's/^/    - /'

echo ""

# Fusion info (if exists)
HAS_SEED=$(jq -r '.seed_input != null' "$JSON_FILE")
if [[ "$HAS_SEED" == "true" ]]; then
  echo "🌱 Seed融合信息"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  SEED_CONF=$(jq -r '.seed_analysis.confidence // 0' "$JSON_FILE")
  SEED_WEIGHT=$(jq -r '.fusion.seed_weight // 0' "$JSON_FILE")
  WIZARD_WEIGHT=$(jq -r '.fusion.wizard_weight // 1' "$JSON_FILE")

  echo "  Seed置信度: ${SEED_CONF}"
  echo "  Seed权重: ${SEED_WEIGHT}"
  echo "  Wizard权重: ${WIZARD_WEIGHT}"
  echo "  融合模式: Wizard优先"

  echo ""
  echo "  Seed Notes:"
  jq -r '.seed_analysis.notes[]? // empty' "$JSON_FILE" | sed 's/^/    - /'

  echo ""
fi

# System prompt preview
echo "📖 System Prompt 预览 (前20行)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
head -n 20 "$MD_FILE"
echo "..."
echo ""
echo "💡 查看完整内容:"
echo "   cat ${MD_FILE}"
echo ""

# Application info
echo "🚀 应用方法"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  /apply-personality ${SESSION_ID} --project  # 应用到当前项目"
echo "  /apply-personality ${SESSION_ID} --global   # 应用到全局"
echo ""
