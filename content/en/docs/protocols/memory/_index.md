---
title: "Memory Protocol"
linkTitle: "Memory"
weight: 6
description: "Knowledge memory, conversation persistence, and JSONL storage"
---

## Overview

The Memory Protocol defines how the agent persists, retrieves, and manages knowledge and conversation history across sessions. It provides two complementary capabilities:

1. **Knowledge Memory**: Long-term facts, preferences, and observations that the agent stores and recalls
2. **Conversation Memory**: The complete record of messages exchanged within a session

**Design Principles:**
- **Append-Only**: Entries are never modified or deleted through normal operations
- **Best-Effort Persistence**: Failures never interrupt conversation flow
- **LLM-Accessible**: Knowledge memory is injected into the LLM's context window
- **Session-Isolated**: Conversation history is partitioned by session

## Memory Interface

```go
type Memory interface {
    // Knowledge operations
    Load(ctx context.Context) ([]Entry, error)
    Save(ctx context.Context, entry Entry) error
    Search(ctx context.Context, query string) ([]Entry, error)

    // Conversation operations
    AppendMessage(ctx context.Context, sessionID string, msg ConversationMessage) error
    LoadConversation(ctx context.Context, sessionID string) ([]ConversationMessage, error)
    ListConversations(ctx context.Context) ([]string, error)
}
```

## Knowledge Memory

### Entry Object

```json
{
  "content": "User prefers Chinese language responses",
  "tags": ["preference", "language"],
  "timestamp": "2026-03-20T14:30:00.000000000Z"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | string | Yes | The knowledge content (free-form text) |
| `tags` | string[] | No | Categorical labels for organization |
| `timestamp` | RFC3339Nano | Auto | Auto-populated with `time.Now()` on save |

### Knowledge in Context Window

All knowledge entries are loaded and injected into the system prompt on every LLM request:

```markdown
## Your Memory
- User prefers Chinese language responses
- The project uses Go 1.22
- Database password is stored in /etc/secrets/db.env
```

This means new entries are immediately available on the next turn.

### Tag Conventions

Recommended tag categories:

| Tag | Usage |
|-----|-------|
| `preference` | User preferences (language, format, style) |
| `fact` | Objective information about the environment |
| `instruction` | Behavioral directives from the user |
| `context` | Background information about the project |
| `todo` | Pending tasks or reminders |

### Search Semantics

| Property | Value |
|----------|-------|
| Algorithm | Case-insensitive substring match on `content` field |
| Scope | All loaded entries |
| Ranking | Insertion order (no relevance ranking) |
| Freshness | Reads from disk on every call (no caching) |

## Conversation Memory

### ConversationMessage Object

```json
{
  "role": "user",
  "content": "What time is it?",
  "tool_calls": [],
  "tool_call_id": "",
  "timestamp": "2026-03-20T14:30:00.123456789Z"
}
```

### Persistence Format

Messages are stored as JSONL (one JSON object per line). Each session writes to a separate file identified by session ID:

```
Format:  YYYY-MM-DDTHH-MM-SS-<hex>
Example: 2026-03-20T14-30-05-a1b2c3d4
```

### Durability Guarantees

| Property | Guarantee |
|----------|-----------|
| Durability | Best-effort (failures logged, don't interrupt) |
| Atomicity | Single JSONL line write per message |
| Completeness | All roles persisted except system messages |
| Session isolation | Each session writes to a separate file |

### Storage Layout

```
data/agent/
├── memory/
│   └── entries.jsonl          # Knowledge memory (all entries)
└── conversations/
    ├── 2026-03-20T14-30-05-a1b2c3d4.jsonl
    └── 2026-03-21T09-15-30-b2c4d6e8.jsonl
```
