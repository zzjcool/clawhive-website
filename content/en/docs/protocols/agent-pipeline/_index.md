---
title: "Agent Pipeline Protocol"
linkTitle: "Agent Pipeline"
weight: 3
description: "Agent lifecycle, processing pipeline, and system prompt assembly"
---

## Overview

The Agent Pipeline Protocol describes how an agent processes a message end-to-end: from system prompt assembly through LLM invocation to tool call loops and response rendering.

## Processing Pipeline

```
InputMessage arrives
    │
    ▼
┌─────────────────────────────┐
│ 1. Append user message to   │
│    conversation history     │
│ 2. Persist to JSONL         │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ 3. Triage (if enabled)      │
│    - Classify message       │
│    - Select strategy        │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ 4. Build context window     │
│    [system] + history       │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ 5. LLM.Chat/ChatStream      │
│    (with tool definitions)  │
└─────────────┬───────────────┘
              │
         ┌────┴────┐
         │         │
    Text only   Tool calls
         │         │
         ▼         ▼
┌──────────┐  ┌──────────────────────┐
│ 6. Render│  │ 7. Execute tools     │
│ response │  │ 8. Feed results back │
│          │  │ 9. Loop (max 20)     │
└──────────┘  └──────────────────────┘
```

## System Prompt Assembly

The system prompt is dynamically constructed before each LLM request:

```
SystemMessage.content = join("\n", [
    SoulPrompt,                    // 1. Agent personality and instructions
    NotificationCapabilities?,     // 2. Tool usage hints (if notifier configured)
    MemoryContext?,                // 3. Knowledge entries (if any)
    SkillPrompts*                  // 4. Active skill instructions (0..N)
])
```

### Step 1: Soul Prompt

The static personality and behavioral instruction set from the agent configuration:

```yaml
soul:
  system: "You are Jarvis, a helpful personal assistant..."
  traits: [helpful, precise]
  rules:
    - "Always respond in the user's language"
```

### Step 2: Notification Capabilities (conditional)

Injected only when a notifier is configured. Describes available notification tools (`send_message`, `schedule_notification`).

### Step 3: Memory Context (conditional)

All persisted knowledge entries injected as a bulleted list:

```markdown
## Your Memory
- User prefers Chinese language responses
- The project uses Go 1.22
```

### Step 4: Skill Prompts (conditional)

Each loaded skill's markdown content injected under a heading:

```markdown
## Skill: code-review
[skill markdown content]
```

## Tool Call Loop

When the LLM returns tool calls instead of a text response:

1. Parse tool calls from LLM response
2. Execute each tool call (validate args → invoke handler)
3. Append assistant message with tool_calls to history
4. Append tool result messages to history
5. Rebuild context window and call LLM again
6. Repeat until text response or max 20 rounds

## Streaming

When the provider supports streaming, the pipeline emits events:

```
triage_decision → [skipped → done]
               → [tool_start → tool_result → ...] → token → token → ... → done
```

Events are produced by a single goroutine and consumed by the REPL/renderer.

## Context Window Properties

| Property | Value |
|----------|-------|
| System message position | Always index 0 |
| System message count | Exactly 1 |
| History ordering | Preserved from append order |
| Dynamic reconstruction | System message rebuilt on every LLM request |
| Memory freshness | Loaded from disk on each request |
