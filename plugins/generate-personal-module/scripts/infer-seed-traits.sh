#!/bin/bash
# infer-seed-traits.sh - Claude-first Seed analysis (No Gemini dependency)
# This script is a wrapper that integrates with seed-analyzer agent

set -euo pipefail

# This script is now integrated directly into Claude Code workflow
# Seed analysis happens through seed-analyzer agent in the main conversation

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Seed Personality Analysis v2.0"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "ℹ️  Seed分析已升级为Claude-first方式"
echo ""
echo "新的分析流程:"
echo "  1. 快速语义分析 (Claude直接分析)"
echo "  2. WebSearch增强 (置信度低时触发)"
echo "  3. 用户确认 (三个选项)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 如何使用:"
echo ""
echo "   方式1: 通过start-wizard命令 (推荐)"
echo "   --------------------------------------"
echo "   在Claude Code中执行:"
echo "     /start-wizard <关键词>"
echo ""
echo "   示例:"
echo "     /start-wizard 诸葛亮"
echo "     /start-wizard 傲娇猫娘"
echo "     /start-wizard 专业的医生"
echo ""
echo "   方式2: 在主对话中直接请求"
echo "   --------------------------------------"
echo "   直接对Claude说:"
echo "     \"我想用'诸葛亮'作为seed关键词创建人格模型\""
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  注意事项:"
echo ""
echo "  • Seed分析必须在Claude Code主对话中进行"
echo "  • 分析过程将显示半透明进度"
echo "  • 你可以确认、跳过或补充上下文"
echo "  • 整个过程通常在5-15秒内完成"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if being called from command line with arguments
if [[ $# -gt 0 ]]; then
  SEED_INPUT="${1:-}"

  if [[ -n "$SEED_INPUT" ]]; then
    echo "检测到关键词: \"${SEED_INPUT}\""
    echo ""
    echo "📋 下一步:"
    echo "   请在Claude Code对话中告诉我:"
    echo "   \"请用'${SEED_INPUT}'作为seed分析关键词\""
    echo ""
  fi
fi

# If called from within Claude Code workflow, output structured info
if [[ "${CLAUDE_CODE_CONTEXT:-}" == "true" ]]; then
  echo ""
  echo "📌 集成信息:"
  echo "   Agent: seed-analyzer v2.0"
  echo "   工具: Claude语义分析 + WebSearch"
  echo "   依赖: 无 (已移除Gemini MCP)"
  echo "   模式: 交互式三阶段分析"
  echo ""
fi
