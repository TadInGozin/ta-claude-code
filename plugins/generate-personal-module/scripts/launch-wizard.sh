#!/bin/bash
# launch-wizard.sh - 启动向导agent的辅助脚本

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

# 初始化会话
SESSION_ID=$(bash "${SCRIPT_DIR}/state-manager.sh" "" init | tail -1)

echo "✅ 会话已创建: ${SESSION_ID}"
echo ""
echo "现在启动wizard-coordinator agent..."
echo ""
echo "---"
echo ""
echo "# @agents/wizard-coordinator"
echo ""
echo "Session ID: ${SESSION_ID}"
echo "Plugin Root: ${PLUGIN_ROOT}"
echo ""
echo "请按照agent的指引完成6轮问答。"
