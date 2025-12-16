#!/bin/bash
# list-personalities.sh - List all generated personality models

set -euo pipefail

MODELS_DIR="${HOME}/.claude/personality-models"

echo "🎭 已生成的人格模型"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [[ ! -d "$MODELS_DIR" ]]; then
  echo "暂无生成的模型"
  echo ""
  echo "💡 提示: 使用 /start-wizard 创建新模型"
  exit 0
fi

model_count=0

for json_file in "${MODELS_DIR}"/session-*.json; do
  if [[ -f "${json_file}" ]]; then
    model_count=$((model_count + 1))

    # Extract model info
    sid=$(jq -r '.session_id' "${json_file}")
    generated=$(jq -r '.generated_at' "${json_file}")
    archetype=$(jq -r '.personality.archetype.primary' "${json_file}")
    verbosity=$(jq -r '.personality.language.verbosity' "${json_file}")
    warmth=$(jq -r '.personality.language.warmth' "${json_file}")
    seed=$(jq -r '.seed_input // "无"' "${json_file}")

    echo "${model_count}. Session ${sid}"
    echo "   生成时间: ${generated}"
    echo "   Seed: ${seed}"
    echo "   人格原型: ${archetype}"
    echo "   表达方式: ${verbosity}"
    echo "   情感距离: ${warmth}"
    echo ""
    echo "   📄 文件:"
    echo "      JSON: ${MODELS_DIR}/session-${sid}.json"
    echo "      MD:   ${MODELS_DIR}/session-${sid}.md"
    echo ""
    echo "   💡 应用方法:"
    echo "      /apply-personality ${sid}"
    echo ""
  fi
done

if [[ $model_count -eq 0 ]]; then
  echo "暂无生成的模型"
  echo ""
  echo "💡 提示: 使用 /start-wizard 创建新模型"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "总计: ${model_count} 个模型"
echo ""
