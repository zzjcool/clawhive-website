---
title: "Triage Protocol"
linkTitle: "Triage"
weight: 2
description: "Two-stage message classification and processing strategies"
---

## Overview

The Triage Protocol defines how an agent determines whether and how to process an incoming message. Instead of every message triggering a full LLM call, a lightweight classifier first evaluates each message and selects an appropriate processing strategy, optimizing cost and latency.

**Design Principles:**
- **Fail-Open**: Any triage error defaults to full processing
- **Observable**: Every decision includes reasoning for auditing
- **Backward-Compatible**: Agents without triage behave identically to pre-triage behavior

## TriageDecision Object

```json
{
  "should_reply": true,
  "strategy": "full",
  "reasoning": "User asked a complex technical question about database indexing."
}
```

| Field | Type | Description |
|-------|------|-------------|
| `should_reply` | boolean | Whether the agent should generate a visible response |
| `strategy` | string | Processing strategy to apply |
| `reasoning` | string | Human-readable explanation (for logging/debugging) |

## Processing Strategies

| Strategy | `should_reply` | Agent Actions | Cost |
|----------|---------------|---------------|------|
| `full` | `true` | Triage + Primary LLM + Tools | Highest |
| `tool_only` | `true` | Triage + Tools (no LLM text) | Medium |
| `brief` | `true` | Triage + Primary LLM (short) | Medium |
| `memory_only` | `false` | Triage + Persist | Low |
| `silent` | `false` | Triage only | Lowest |

### silent

No response, no memory, no tools. The message is persisted in history for completeness.

**Appropriate for:** Empty messages, duplicates, accidental sends, system heartbeats.

### memory_only

No response, but the message contains meaningful information worth remembering.

**Appropriate for:** User sharing facts/preferences, "don't reply" messages, informational updates.

### brief

Short response (1-2 sentences). Uses the primary LLM with all capabilities.

**Appropriate for:** Greetings, yes/no questions, acknowledgments, quick factual lookups.

### tool_only

Action can be fulfilled by tool execution without explanatory text.

**Appropriate for:** Direct commands ("Save this to memory"), file operations, actions where tool result is sufficient.

### full

Complete reasoning capabilities with the full system prompt and tool loop.

**Appropriate for:** Complex questions, multi-step reasoning, ambiguous messages. **This is the default fallback strategy.**

## Processing Pipeline

```
Message Arrives → Persist to History → Triage Enabled?
                                        │
                              Yes: Invoke Triage LLM
                              │         │
                              │    Parse Decision
                              │    (fail-open on error → full)
                              │         │
                              │   ┌─────┼─────┬─────┬─────┐
                              │ silent mem brief tool  full
                              │   │     │    │    │     │
                              │  done  done LLM  LLM   LLM
                              │                loop  loop  loop
                              │
                              No: Full LLM processing
```

## Configuration

```yaml
spec:
  triage:
    enabled: true
    provider: openai
    model: ${TRIAGE_MODEL}       # Lightweight model recommended
    apiKey: ${TRIAGE_API_KEY}
    baseURL: ${TRIAGE_BASE_URL}  # Optional
    instruction: "..."           # Optional custom system prompt
```

When `triage.enabled` is `true`, `provider`, `model`, and `apiKey` are required.

## Triage Context Window

The triage LLM receives a **reduced** context compared to the primary LLM:

| Property | Triage Context | Primary Context |
|----------|---------------|-----------------|
| System message | Triage-specific instruction | Full soul + memory + skills |
| History depth | Last 5 messages | Full history |
| Tool definitions | None | All registered tools |

This reduction is intentional: minimal context for classification, reducing latency and cost.

## Error Handling

Any failure in the triage process results in a fallback to `strategy: "full"`:

| Error Condition | Behavior |
|----------------|----------|
| Triage LLM network error | Fall back to `full`. Log warning. |
| Triage LLM returns non-JSON | Fall back to `full`. Log warning. |
| Triage LLM returns unknown strategy | Fall back to `full`. Log warning. |
| Triage LLM timeout | Fall back to `full`. Log warning. |
| Triage disabled (`enabled: false`) | Skip triage entirely. Process as `full`. |

## Strategy Decision Examples

| Message | Strategy | Reasoning |
|---------|----------|-----------|
| `""` (empty) | `silent` | No content |
| `"Hi"` | `brief` | Simple greeting |
| `"请不要回答"` | `memory_only` | User intent communicated, no reply needed |
| `"What is quantum computing?"` | `full` | Complex question |
| `"Run ls -la"` | `tool_only` | Direct command |
| `"I prefer dark mode"` | `memory_only` | Preference statement |
| `"asdfghjkl"` | `silent` | Keyboard noise |
