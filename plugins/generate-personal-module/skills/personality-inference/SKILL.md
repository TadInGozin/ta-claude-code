---
name: personality-seed-inference
description: Claude-first dynamic personality inference from keywords
allowed-tools: Read, Write, Bash, WebSearch, Task
---

# Personality Seed Inference Skill v2.0

## What's New in v2.0

**Claude-First Approach**:
- ✅ No Gemini MCP dependency (completely removed)
- ✅ Dynamic research through WebSearch
- ✅ Semi-transparent user experience
- ✅ Three-phase analysis workflow
- ✅ User confirmation and control

## Activation Conditions

This skill automatically activates when personality inference from keywords is needed.

**Typical Triggering Scenarios**:
1. User provides keyword parameter in `/start-wizard` command
2. User requests: "analyze personality of [keyword]"
3. Conversation mentions building persona from a character/role
4. Explicit invocation of seed-analyzer agent

## Capability Description

This skill grants Claude the following enhanced abilities:

### 1. Fast Semantic Analysis
- Parse keyword meaning across languages (Chinese/English/Japanese)
- Identify keyword types (character, archetype, concept, role)
- Recognize cultural context and associations
- Infer initial personality traits
- Calculate confidence score

### 2. Dynamic Web Research (Conditional)
- Trigger WebSearch when confidence < 0.7
- Extract features from real online information
- Synthesize findings from multiple sources
- Update analysis based on research
- Track sources for transparency

### 3. Interactive User Confirmation
- Present analysis results semi-transparently
- Offer three user options:
  - [1] Confirm and proceed
  - [2] Skip Seed, do pure Wizard
  - [3] Provide more context, re-analyze
- Handle iterative refinement loops
- Save confirmed traits to session state

### 4. Personality Trait Mapping
Map keywords to these 6 dimensions (matching wizard rounds):
- **Archetype**: 高冷型 | 傲娇型 | 御姐型 | 元气型
- **Verbosity**: 简洁直接 | 适度解释 | 详细解释 | 聊天闲谈
- **Warmth**: 保持距离 | 友好同事 | 关心朋友
- **Correction**: 直接指出 | 委婉提醒 | 引导思考
- **Initiative**: 听从指令 | 适度建议 | 主动规划
- **Constraints**: [] (optional list)

## Analysis Workflow

### Phase 1: Fast Semantic Analysis (ALWAYS, ~3-5 seconds)

```
Input: Keyword (e.g., "诸葛亮")
  ↓
Semantic Understanding
  • Parse literal meaning
  • Identify cultural context
  • Recognize character type
  ↓
Trait Inference
  • Map to 6 personality dimensions
  • Generate reasoning points
  ↓
Confidence Scoring
  • Calculate 0.0-1.0 confidence
  • Determine if enhancement needed
  ↓
Display to User (semi-transparent)
  • Show initial analysis
  • Display confidence level
  • List reasoning points
  ↓
Decision Point:
  confidence >= 0.7 → Phase 3 (Confirmation)
  confidence < 0.7  → Phase 2 (WebSearch)
```

### Phase 2: WebSearch Enhancement (CONDITIONAL, ~5-10 seconds)

```
Trigger: confidence < 0.7
  ↓
Inform User
  ⚡ 置信度偏低，启动深度研究...
  ↓
Construct Search Queries
  • "{keyword} personality traits"
  • "{keyword} 性格特征 语言风格"
  • "{keyword} communication behavior"
  ↓
Execute WebSearch
  • Use WebSearch tool
  • Extract relevant features
  ↓
Re-analyze with Context
  • Update trait mappings
  • Recalculate confidence
  ↓
Display Enhanced Results
  • Show research findings
  • Cite sources
  • Updated confidence
```

### Phase 3: User Confirmation (ALWAYS)

```
Present Summary
  • Display inferred traits
  • Show confidence level
  • List reasoning + sources (if applicable)
  ↓
User Chooses:
  [1] ✓ Confirm
       ↓
      Save to session state
       ↓
      Continue to wizard

  [2] ✗ Skip Seed
       ↓
      Clear seed_input
       ↓
      Pure Wizard mode

  [3] ✎ Provide Context
       ↓
      Get user input
       ↓
      Re-run Phase 1 with enhanced context
```

## Output Format

After user confirms, generate JSON:

```json
{
  "seed_input": "string",
  "confidence": 0.0-1.0,
  "seed_traits": {
    "archetype": "高冷型|傲娇型|御姐型|元气型",
    "verbosity": "简洁直接|适度解释|详细解释|聊天闲谈",
    "warmth": "保持距离|友好同事|关心朋友",
    "correction": "直接指出|委婉提醒|引导思考",
    "initiative": "听从指令|适度建议|主动规划",
    "constraints": []
  },
  "reasoning": [
    "string",
    "..."
  ],
  "sources": [
    "string (if WebSearch used)",
    "..."
  ],
  "analysis_path": "semantic_only|semantic_plus_websearch"
}
```

## Confidence Scoring Guidelines

**0.9-1.0 (Perfect)**:
- Clear character with well-known personality
- Examples: 诸葛亮, Sherlock Holmes, 傲娇猫娘
- No ambiguity

**0.7-0.9 (High)**:
- Clear archetype or role
- Examples: 侦探, 导师, 元气少女
- Minor ambiguity

**0.5-0.7 (Medium)**:
- General role or abstract trait
- Examples: 工程师, 专业, 温暖
- Multiple interpretations possible

**0.3-0.5 (Low)**:
- Vague or very abstract
- Examples: 普通人, 好人, 有趣
- Needs more context

**0.0-0.3 (Very Low)**:
- Too vague to infer
- Examples: 测试, 123, 随便
- Suggest pure Wizard mode

## Integration with Wizard

### Fusion Strategy

When Seed analysis completes and user confirms:

1. **Save to Session State**
   ```json
   {
     "seed_input": "...",
     "seed_analysis": {
       "confidence": 0.85,
       "seed_traits": {...},
       "reasoning": [...],
       "sources": [...],
       "analysis_path": "..."
     }
   }
   ```

2. **Continue to Wizard**
   - wizard-coordinator sees seed_input exists
   - User completes 6-round questionnaire normally
   - Both Seed and Wizard data collected

3. **Final Fusion** (in merge-personality.sh)
   ```
   Wizard weight: 1.0 (always priority)
   Seed weight: confidence × 0.3 (gentle prior)

   If conflict: Wizard wins
   If no conflict: Seed influences nuances
   ```

## Commands Using This Skill

- `/start-wizard <keyword>` - Launch wizard with Seed analysis
- `/start-wizard` - Launch wizard without Seed (pure mode)
- Direct: Tell Claude "analyze personality of [keyword]"

## Key Differences from v1.0

| Aspect | v1.0 (Gemini-first) | v2.0 (Claude-first) |
|--------|---------------------|---------------------|
| Primary Analysis | Gemini MCP | Claude semantic analysis |
| Enhancement | Fallback rules | WebSearch when needed |
| User Interaction | Automatic | Three-phase confirmation |
| Transparency | Black box | Semi-transparent |
| Fixed Mappings | Yes | No (dynamic research) |
| MCP Dependency | Zen/Gemini required | None (WebSearch only) |
| Context Loop | No | Yes (option 3) |

## Skill Boundaries

### What It Can Do

✅ Analyze keywords through semantic understanding
✅ Enhance analysis through WebSearch
✅ Present semi-transparent process to user
✅ Allow user confirmation/skip/enhancement
✅ Map traits to 6 personality dimensions
✅ Calculate meaningful confidence scores
✅ Generate structured JSON output
✅ Handle iterative refinement

### What It Cannot Do

❌ Cannot generate constraints (user chooses in Round 6)
❌ Cannot override Wizard choices (Seed is prior only)
❌ Cannot guarantee perfect accuracy (honest confidence)
❌ Cannot analyze non-personality keywords
❌ Cannot process > 50 character inputs
❌ Cannot work offline (WebSearch may be needed)

## Important Principles

1. **Dynamic Over Fixed**: No predetermined mappings, fresh analysis each time
2. **User Control**: Always require user confirmation, respect all three options
3. **Transparency**: Show key steps without overwhelming detail
4. **Speed First**: Fast initial analysis, deep research only when needed
5. **Conservative Confidence**: Lower scores when uncertain, encourage context
6. **Prior Nature**: Seed is gentle prior, Wizard always has priority
7. **Cultural Awareness**: Consider Chinese/English/Japanese cultural contexts

## Edge Cases

### Very Vague Keywords
- Show low confidence clearly
- Recommend option 3 (provide context) or option 2 (skip Seed)
- Don't force analysis on ambiguous input

### Non-Chinese Keywords
- Analyze in original language context
- Consider cross-cultural interpretation
- Provide bilingual reasoning if helpful

### Multiple Interpretations
- Choose most common interpretation
- Note other possibilities in reasoning
- Allow user to clarify via option 3

### Abstract Concepts
- Trigger WebSearch to find context
- Look for usage patterns
- Suggest concrete examples to user

---

**Skill Version**: 2.0 (Claude-First)
**Status**: Active - Automatically activates when Seed inference needed
**Integration**: Seamless with Wizard flow, supports Seed + Wizard fusion
**Dependencies**: None (WebSearch is built-in tool, no external MCP required)
