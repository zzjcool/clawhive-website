---
title: "Notification Protocol"
linkTitle: "Notification"
weight: 7
description: "Notification routing, transport abstraction, and scheduled reminders"
---

## Overview

The Notification Protocol specifies how notifications are routed through transports and how scheduled reminders work. The notification system allows agents to proactively push information to users via terminal output, webhooks, or custom transports.

## Architecture

```
Agent → Notifier → Transport (terminal / webhook / ...)
              │
              ├── Direct: send_message tool
              └── Scheduled: schedule_notification tool → time.AfterFunc → Transport + inputCh
```

## Notification Message

```go
type Message struct {
    Channel   string    // Target transport name
    Subject   string    // Optional title
    Body      string    // Message content
    Priority  Priority  // low, normal, high
    Source    string    // Origin identifier
    AgentName string    // Sending agent name
    SessionID string    // Session identifier
}
```

## Routing Rules

| Channel Value | Behavior |
|---------------|----------|
| `""` (empty) | Use notifier's default transports |
| `"terminal"` | Send to terminal transport only |
| `"webhook"` | Send to webhook transport only |
| `"all"` | Broadcast to every registered transport |
| `<custom>` | Send to the named transport |

## Priority Levels

| Priority | Terminal Behavior | Webhook Behavior |
|----------|-------------------|------------------|
| `low` | No special formatting | Standard delivery |
| `normal` | Standard output | Standard delivery |
| `high` | Bell character (`\a`) + ANSI emphasis | High-priority headers |

## Transports

### Terminal

Outputs to stderr with ANSI color formatting.

- Prefix: `[agent-name]` in dim color
- Subject line (if present): bold
- Body: normal text
- Bell: terminal bell for `normal`+ priority

### Webhook

Sends HTTP POST with JSON payload to configured URL.

```yaml
notify:
  transports:
    - name: webhook
      type: webhook
      config:
        url: "https://example.com/webhook"
```

## Scheduled Notifications

The `schedule_notification` tool creates a background timer using `time.AfterFunc`:

1. Timer fires after `delay_seconds`
2. Notification is sent through the configured transport
3. Message is injected into the agent's `inputCh` for REPL display
4. Agent can respond conversationally to the reminder

```json
{
  "name": "schedule_notification",
  "parameters": {
    "delay_seconds": 3600,
    "body": "Reminder: review PR #42",
    "priority": "high"
  }
}
```

## Cron Integration

Cron jobs can automatically route responses through notification transports:

```yaml
cron:
  - name: daily-summary
    schedule: "0 8 * * *"
    prompt: "Generate a daily summary"
    notify:
      channels: [terminal]
      priority: normal
```

When a cron job has `notify` configured, the agent's response is automatically sent through the specified channels.
