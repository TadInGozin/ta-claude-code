#!/bin/bash
# merge-personality-v3.sh - Generate personality model and clean up intermediate files
# Version: 3.0 (Optimized UX with cleanup)

set -euo pipefail

SESSION_ID=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_FILE="${HOME}/.claude/personality-wizard/session-${SESSION_ID}.json"
OUTPUT_DIR="${HOME}/.claude/personality-models"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Check session exists
if [[ ! -f "$STATE_FILE" ]]; then
  echo "❌ 会话不存在: ${SESSION_ID}"
  exit 1
fi

# Check session is complete
CURRENT_ROUND=$(jq -r '.current_round' "$STATE_FILE")
if [[ $CURRENT_ROUND -lt 6 ]]; then
  echo "❌ 会话未完成 (Round ${CURRENT_ROUND}/6)"
  echo "   请先完成所有6轮问答"
  exit 1
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Extract responses (no verbose output)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ARCHETYPE=$(jq -r '.responses[] | select(.round == 1) | .answer' "$STATE_FILE")
VERBOSITY=$(jq -r '.responses[] | select(.round == 2) | .answer' "$STATE_FILE")
WARMTH=$(jq -r '.responses[] | select(.round == 3) | .answer' "$STATE_FILE")
CORRECTION=$(jq -r '.responses[] | select(.round == 4) | .answer' "$STATE_FILE")
INITIATIVE=$(jq -r '.responses[] | select(.round == 5) | .answer' "$STATE_FILE")
CONSTRAINTS=$(jq -r '.responses[] | select(.round == 6) | .answer' "$STATE_FILE")

# Get Seed info (if exists)
SEED_INPUT=$(jq -r '.seed_input // "无"' "$STATE_FILE")
HAS_SEED=$(jq -r '.seed_input != null' "$STATE_FILE")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Mapping functions - Chinese to descriptions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

map_archetype() {
  case "$1" in
    "高冷型") echo "冷静理性的专业风格，保持克制和逻辑清晰" ;;
    "傲娇型") echo "外冷内热，有个性但关键时刻可靠" ;;
    "御姐/导师型") echo "成熟稳重，采用引导式交流" ;;
    "元气/猫娘型") echo "活泼可爱，亲和力强，充满热情" ;;
    *) echo "平衡的人格风格" ;;
  esac
}

map_verbosity() {
  case "$1" in
    "简洁直接") echo "提供简洁直接的答案，聚焦结论" ;;
    "适度解释") echo "平衡清晰度和简洁性，在有帮助时添加推理" ;;
    "逻辑完整") echo "提供详细解释和完整的逻辑流程" ;;
    "自然聊天") echo "使用对话风格，就像和朋友交谈一样" ;;
    *) echo "适当表达" ;;
  esac
}

map_warmth() {
  case "$1" in
    "保持距离") echo "专业的专家顾问关系" ;;
    "友好同事") echo "可靠的工作伙伴关系" ;;
    "关心朋友") echo "理解感受的朋友关系" ;;
    *) echo "适当的关系" ;;
  esac
}

map_correction() {
  case "$1" in
    "直接指出") echo "直接明确地指出错误" ;;
    "委婉提醒") echo "以温和的方式提示问题" ;;
    "引导发现") echo "通过提问引导用户自己发现问题" ;;
    *) echo "适当纠正" ;;
  esac
}

map_initiative() {
  case "$1" in
    "完全听从") echo "严格按照用户指示执行" ;;
    "适度建议") echo "在必要时提供建议和提醒" ;;
    "主动规划") echo "主动规划解决方案并提出建议" ;;
    *) echo "平衡主动性" ;;
  esac
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Generate personality model (System Prompt ONLY)
# No intermediate JSON files
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Generate final System Prompt
cat > "${OUTPUT_DIR}/session-${SESSION_ID}.md" << EOF
# Generated Personality Model

**Session ID**: ${SESSION_ID}
**Generated**: ${TIMESTAMP}
**Seed Input**: ${SEED_INPUT}

---

## Personality Configuration

### 🎭 Core Archetype
**Primary**: ${ARCHETYPE}
**Style**: $(map_archetype "${ARCHETYPE}")

### 💬 Communication Style
**Verbosity**: ${VERBOSITY}
**Instruction**: $(map_verbosity "${VERBOSITY}")

**Warmth**: ${WARMTH}
**Relationship**: $(map_warmth "${WARMTH}")

### 🎯 Behavior Patterns
**Correction Style**: ${CORRECTION}
**Approach**: $(map_correction "${CORRECTION}")

**Initiative Level**: ${INITIATIVE}
**Role**: $(map_initiative "${INITIATIVE}")

### 🚫 Constraints (Hard Boundaries)
EOF

# Add constraints list
if [[ -n "$CONSTRAINTS" && "$CONSTRAINTS" != "null" ]]; then
  echo "$CONSTRAINTS" | tr ',' '\n' | while read -r constraint; do
    constraint=$(echo "$constraint" | xargs)  # trim spaces
    if [[ -n "$constraint" ]]; then
      echo "- **避免**: ${constraint}" >> "${OUTPUT_DIR}/session-${SESSION_ID}.md"
    fi
  done
else
  echo "- (无特殊约束)" >> "${OUTPUT_DIR}/session-${SESSION_ID}.md"
fi

cat >> "${OUTPUT_DIR}/session-${SESSION_ID}.md" << EOF

---

## System Instructions

You are an AI assistant with the following personality profile:

**Personality Archetype**: ${ARCHETYPE}
Embody the characteristics of $(map_archetype "${ARCHETYPE}").
EOF

# Add seed context if exists
if [[ "$HAS_SEED" == "true" ]]; then
  cat >> "${OUTPUT_DIR}/session-${SESSION_ID}.md" << EOF
This personality was inspired by "${SEED_INPUT}" but refined through user preferences.
EOF
fi

cat >> "${OUTPUT_DIR}/session-${SESSION_ID}.md" << EOF

**Communication**:
- Adopt a ${WARMTH} tone
- $(map_verbosity "${VERBOSITY}")
- $(map_warmth "${WARMTH}")

**Behavior**:
- When correcting errors: $(map_correction "${CORRECTION}")
- Initiative level: $(map_initiative "${INITIATIVE}")

**Boundaries** - Strictly avoid:
EOF

# Add constraints to system instructions
if [[ -n "$CONSTRAINTS" && "$CONSTRAINTS" != "null" ]]; then
  echo "$CONSTRAINTS" | tr ',' '\n' | while read -r constraint; do
    constraint=$(echo "$constraint" | xargs)
    if [[ -n "$constraint" ]]; then
      echo "  - ${constraint}" >> "${OUTPUT_DIR}/session-${SESSION_ID}.md"
    fi
  done
else
  echo "  - (No specific constraints)" >> "${OUTPUT_DIR}/session-${SESSION_ID}.md"
fi

cat >> "${OUTPUT_DIR}/session-${SESSION_ID}.md" << EOF

Embody this personality naturally in all interactions while maintaining professionalism and helpfulness.

---

**Generated by**: Personality Generator Plugin v3.0.0
**Session**: ${SESSION_ID}
EOF

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Clean up intermediate files
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
echo "🧹 清理中间文件..."

# Remove session state file
if [[ -f "$STATE_FILE" ]]; then
  rm -f "$STATE_FILE"
  echo "  ✓ 已删除会话状态文件"
fi

# Remove any temporary JSON files
if [[ -f "${OUTPUT_DIR}/session-${SESSION_ID}.json" ]]; then
  rm -f "${OUTPUT_DIR}/session-${SESSION_ID}.json"
  echo "  ✓ 已删除临时JSON配置"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Success output (clean and friendly)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ 你的AI人格模型已生成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📄 生成文件:"
echo "   ${OUTPUT_DIR}/session-${SESSION_ID}.md"
echo ""
echo "📋 你的人格配置:"
echo "   🎭 人格原型: ${ARCHETYPE}"
echo "   💬 表达方式: ${VERBOSITY}"
echo "   ❤️  情感距离: ${WARMTH}"
echo "   ✏️  纠错方式: ${CORRECTION}"
echo "   🎯 主导性: ${INITIATIVE}"
if [[ -n "$CONSTRAINTS" && "$CONSTRAINTS" != "null" ]]; then
  echo "   🚫 约束: ${CONSTRAINTS}"
fi
echo ""
echo "🚀 如何使用:"
echo "   方式1 (项目配置):"
echo "   cat ${OUTPUT_DIR}/session-${SESSION_ID}.md >> ./CLAUDE.md"
echo ""
echo "   方式2 (全局配置):"
echo "   cat ${OUTPUT_DIR}/session-${SESSION_ID}.md >> ~/.claude/CLAUDE.md"
echo ""
