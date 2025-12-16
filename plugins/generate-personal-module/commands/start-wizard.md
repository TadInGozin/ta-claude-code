---
description: Start personality wizard with 7-round conversation (seed + 6 questions)
allowed-tools: AskUserQuestion, Bash, Read, Write, WebSearch
argument-hint:
model: sonnet
personality: tsundere-friendly
---

# /start-wizard - Create Your AI Personality (v3.0)

Interactive personality model generator with natural conversational flow.

---

## Execution Steps

### Round 0: Seed Keyword Collection

**Invoke seed-analyzer agent** to handle this round:

```
嘿~ 我们来创建你的专属AI人格吧！

先告诉我一个关键词，可以是：
  • 角色类型（傲娇猫娘、冷静侦探）
  • 历史人物（诸葛亮、居里夫人）
  • 职业角色（专业医生、温暖老师）
  • 抽象概念（严谨、温暖、专业）

你想要什么样的AI？
```

**Wait for user input** → Analyze keyword → Show suggestions

---

### Rounds 1-6: Personality Questionnaire

**Invoke wizard-coordinator agent** to handle these rounds:

1. Welcome message
2. Collect Batch 1 (Rounds 1-4) via AskUserQuestion
3. Show progress
4. Collect Batch 2 (Rounds 5-6) via AskUserQuestion
5. Show final summary

---

### Final: Generation & Cleanup

1. Call merge-personality.sh script:
   ```bash
   SESSION_ID=$(date +%s)
   bash scripts/merge-personality.sh "$SESSION_ID"
   ```

2. Script will:
   - Generate System Prompt (.md file)
   - Clean up all intermediate files
   - Show usage instructions

---

## User Experience Flow

**Complete conversation example**:

```
[Round 0 - Seed]
Assistant: 嘿~ 我们来创建你的专属AI人格吧！先告诉我一个关键词...
User: 傲娇猫娘
Assistant: [分析 + 展示建议] 好~ 接下来通过6个问题来确认和调整吧！

[Rounds 1-4 - Core Personality]
Assistant: 先来4个基础问题~ [AskUserQuestion]
User: [选择答案]
Assistant: ✓ 前4个问题完成了！继续最后2个问题吧！

[Rounds 5-6 - Behavior]
Assistant: 最后2个问题... [AskUserQuestion]
User: [选择答案]
Assistant: ✓ 全部完成！正在生成你的专属AI人格模型...

[Generation]
Script: ✨ 你的AI人格模型已生成！[显示文件路径和使用方法]
```

**Total time**: ~2-3 minutes
**Total interactions**: 3 (seed input + 2 question batches)
**Files generated**: 1 (.md system prompt only)

---

## Key Changes from v2.0

### User-Facing Changes
- ✅ 7 rounds total (was 6)
- ✅ AI initiates seed request (was command argument)
- ✅ Natural conversation (no technical details)
- ✅ Single output file (no JSON clutter)
- ✅ Auto cleanup (no intermediate files left)

### Technical Changes
- ✅ seed-analyzer handles Round 0
- ✅ wizard-coordinator handles Rounds 1-6
- ✅ merge-personality.sh cleans up state files
- ✅ No confidence scores or fusion algorithms exposed

---

## Error Handling

### User Input Issues
```
Assistant: 嗯？这个好像不太清楚...
           能具体一点吗？比如"专业的医生"而不是"专业"~
```

### Session State Issues
If session gets interrupted, allow resumption:
```
Assistant: 欢迎回来~ 我们之前做到第{round}个问题了。
           要继续吗？还是重新开始？
```

---

## Success Criteria

Good experience:
- ✅ Feels like chatting with a friend
- ✅ Clear progress at each step
- ✅ No confusing technical terms
- ✅ Single clean output file
- ✅ Clear next steps

---

**Version**: 3.0
**Agents**: seed-analyzer + wizard-coordinator
**Script**: merge-personality.sh (with cleanup)
