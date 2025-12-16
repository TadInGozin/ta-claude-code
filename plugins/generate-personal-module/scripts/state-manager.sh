#!/bin/bash
# state-manager.sh - 会话状态管理脚本
# 用于初始化、保存、加载和查询人格向导会话状态

set -euo pipefail

# 配置
WIZARD_STATE_DIR="${HOME}/.claude/personality-wizard"
SESSION_ID="${1:-}"
ACTION="${2:-}"

# 辅助函数
log_info() {
  echo "ℹ️  $*"
}

log_success() {
  echo "✅ $*"
}

log_error() {
  echo "❌ $*" >&2
}

# 确保状态目录存在
ensure_state_dir() {
  mkdir -p "${WIZARD_STATE_DIR}"
}

# 初始化新会话
init_session() {
  ensure_state_dir

  local new_session_id
  new_session_id=$(date +%s)
  local state_file="${WIZARD_STATE_DIR}/session-${new_session_id}.json"

  cat > "${state_file}" << EOF
{
  "session_id": "${new_session_id}",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "current_round": 0,
  "completed_rounds": [],
  "seed_input": null,
  "seed_analysis": null,
  "responses": []
}
EOF

  log_success "会话初始化成功"
  log_info "Session ID: ${new_session_id}"
  log_info "State file: ${state_file}"

  # 输出session ID供调用者使用
  echo "${new_session_id}"
}

# 保存单个回答
save_response() {
  local session_id=$1
  local round=$2
  local question=$3
  local answer=$4
  local category=$5

  local state_file="${WIZARD_STATE_DIR}/session-${session_id}.json"

  if [[ ! -f "${state_file}" ]]; then
    log_error "会话不存在: ${session_id}"
    return 1
  fi

  # 使用jq更新JSON
  local temp_file="${state_file}.tmp"

  jq \
    --arg round "$round" \
    --arg question "$question" \
    --arg answer "$answer" \
    --arg category "$category" \
    --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    '.responses += [{
      "round": ($round | tonumber),
      "question": $question,
      "answer": $answer,
      "category": $category,
      "answered_at": $timestamp
    }] |
    .completed_rounds += [($round | tonumber)] |
    .completed_rounds |= unique |
    .current_round = ([.completed_rounds[] | tonumber] | max // 0) |
    .last_updated = $timestamp' \
    "${state_file}" > "${temp_file}"

  mv "${temp_file}" "${state_file}"

  log_success "Round ${round} 已保存"
  log_info "问题: ${question}"
  log_info "答案: ${answer}"
}

# 保存Seed分析结果
save_seed_analysis() {
  local session_id=$1
  local seed_input=$2
  local analysis_json=$3

  local state_file="${WIZARD_STATE_DIR}/session-${session_id}.json"

  if [[ ! -f "${state_file}" ]]; then
    log_error "会话不存在: ${session_id}"
    return 1
  fi

  local temp_file="${state_file}.tmp"

  jq \
    --arg seed "$seed_input" \
    --argjson analysis "$analysis_json" \
    --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    '.seed_input = $seed |
     .seed_analysis = $analysis |
     .last_updated = $timestamp' \
    "${state_file}" > "${temp_file}"

  mv "${temp_file}" "${state_file}"

  log_success "Seed分析已保存"
  log_info "关键词: ${seed_input}"
}

# 获取会话状态
get_status() {
  local session_id=$1
  local state_file="${WIZARD_STATE_DIR}/session-${session_id}.json"

  if [[ ! -f "${state_file}" ]]; then
    log_error "会话不存在: ${session_id}"
    return 1
  fi

  echo "📊 会话状态"
  echo "───────────────────────────────────"
  echo "Session ID: $(jq -r '.session_id' "${state_file}")"
  echo "创建时间: $(jq -r '.created_at' "${state_file}")"
  echo "最后更新: $(jq -r '.last_updated' "${state_file}")"
  echo "当前进度: $(jq -r '.current_round' "${state_file}")/6"
  echo ""

  # 显示Seed信息（如果有）
  local seed_input
  seed_input=$(jq -r '.seed_input' "${state_file}")
  if [[ "${seed_input}" != "null" ]]; then
    echo "关键词Seed: ${seed_input}"
    echo ""
  fi

  # 显示已完成的回答
  echo "已完成回答:"
  jq -r '.responses[] | "  Round \(.round): \(.answer)"' "${state_file}" || echo "  (无)"
  echo ""

  # 显示待完成的轮次
  local completed_count
  completed_count=$(jq -r '.responses | length' "${state_file}")
  local remaining=$((6 - completed_count))

  if [[ $remaining -gt 0 ]]; then
    echo "⏳ 剩余 ${remaining} 轮待完成"
  else
    echo "✅ 所有6轮已完成"
  fi
}

# 列出所有会话
list_sessions() {
  ensure_state_dir

  echo "📋 所有会话"
  echo "───────────────────────────────────"

  local session_count=0

  for state_file in "${WIZARD_STATE_DIR}"/session-*.json; do
    if [[ -f "${state_file}" ]]; then
      session_count=$((session_count + 1))
      local sid
      local rounds
      local created

      sid=$(jq -r '.session_id' "${state_file}")
      rounds=$(jq -r '.current_round' "${state_file}")
      created=$(jq -r '.created_at' "${state_file}")

      echo "${session_count}. Session ${sid}"
      echo "   进度: Round ${rounds}/6"
      echo "   创建: ${created}"
      echo ""
    fi
  done

  if [[ $session_count -eq 0 ]]; then
    echo "(暂无会话)"
  fi
}

# 获取会话数据（供其他脚本使用）
get_session_data() {
  local session_id=$1
  local state_file="${WIZARD_STATE_DIR}/session-${session_id}.json"

  if [[ ! -f "${state_file}" ]]; then
    log_error "会话不存在: ${session_id}"
    return 1
  fi

  cat "${state_file}"
}

# 检查会话是否完成
is_session_complete() {
  local session_id=$1
  local state_file="${WIZARD_STATE_DIR}/session-${session_id}.json"

  if [[ ! -f "${state_file}" ]]; then
    return 1
  fi

  local current_round
  current_round=$(jq -r '.current_round' "${state_file}")

  [[ $current_round -ge 6 ]]
}

# 删除会话
delete_session() {
  local session_id=$1
  local state_file="${WIZARD_STATE_DIR}/session-${session_id}.json"

  if [[ ! -f "${state_file}" ]]; then
    log_error "会话不存在: ${session_id}"
    return 1
  fi

  rm "${state_file}"
  log_success "会话已删除: ${session_id}"
}

# 主逻辑
main() {
  case "${ACTION}" in
    init)
      init_session
      ;;
    save)
      if [[ $# -lt 6 ]]; then
        log_error "用法: $0 <session-id> save <round> <question> <answer> <category>"
        exit 1
      fi
      save_response "$1" "$3" "$4" "$5" "$6"
      ;;
    seed)
      if [[ $# -lt 4 ]]; then
        log_error "用法: $0 <session-id> seed <seed-input> <analysis-json>"
        exit 1
      fi
      save_seed_analysis "$1" "$3" "$4"
      ;;
    status)
      if [[ -z "$SESSION_ID" ]]; then
        log_error "用法: $0 <session-id> status"
        exit 1
      fi
      get_status "$SESSION_ID"
      ;;
    list)
      list_sessions
      ;;
    data)
      if [[ -z "$SESSION_ID" ]]; then
        log_error "用法: $0 <session-id> data"
        exit 1
      fi
      get_session_data "$SESSION_ID"
      ;;
    complete)
      if [[ -z "$SESSION_ID" ]]; then
        log_error "用法: $0 <session-id> complete"
        exit 1
      fi
      is_session_complete "$SESSION_ID" && echo "true" || echo "false"
      ;;
    delete)
      if [[ -z "$SESSION_ID" ]]; then
        log_error "用法: $0 <session-id> delete"
        exit 1
      fi
      delete_session "$SESSION_ID"
      ;;
    *)
      echo "用法: $0 [session-id] {init|save|seed|status|list|data|complete|delete}"
      echo ""
      echo "命令:"
      echo "  init                           - 初始化新会话"
      echo "  save <round> <q> <a> <cat>    - 保存回答"
      echo "  seed <input> <analysis>        - 保存Seed分析"
      echo "  status                         - 查看会话状态"
      echo "  list                           - 列出所有会话"
      echo "  data                           - 获取会话JSON数据"
      echo "  complete                       - 检查会话是否完成"
      echo "  delete                         - 删除会话"
      exit 1
      ;;
  esac
}

main "$@"
