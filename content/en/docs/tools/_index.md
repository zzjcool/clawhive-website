---
title: "Built-in Tools"
linkTitle: "Tools"
weight: 5
description: "Tools available to ClawHive agents"
---

## Tool System

ClawHive agents use a registry-based tool system. Each tool is defined with a JSON Schema for parameter validation and a handler function for execution. Tools are automatically registered during agent initialization and presented to the LLM as function definitions.

## Built-in Tools

### exec

Execute shell commands in the agent's sandbox (or local environment in `--local` mode).

```json
{
  "name": "exec",
  "description": "Run a shell command and return its output.",
  "parameters": {
    "type": "object",
    "properties": {
      "command": {
        "type": "string",
        "description": "The shell command to execute."
      }
    },
    "required": ["command"]
  }
}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `command` | string | Yes | The shell command to execute via `sh -c` |

- Default timeout: 30 seconds
- Returns combined stdout + stderr
- In Docker mode, commands run inside the sandbox container

### read_file

Read the contents of a file from the agent's workspace.

```json
{
  "name": "read_file",
  "description": "Read the contents of a file.",
  "parameters": {
    "type": "object",
    "properties": {
      "path": {
        "type": "string",
        "description": "The path to the file to read."
      }
    },
    "required": ["path"]
  }
}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `path` | string | Yes | Absolute or relative path to the file |

### write_file

Create or overwrite a file with the given content.

```json
{
  "name": "write_file",
  "description": "Create or overwrite a file with the given content.",
  "parameters": {
    "type": "object",
    "properties": {
      "path": {
        "type": "string",
        "description": "The path to the file to write."
      },
      "content": {
        "type": "string",
        "description": "The content to write to the file."
      }
    },
    "required": ["path", "content"]
  }
}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `path` | string | Yes | Path to the file |
| `content` | string | Yes | Content to write |

- Returns `"ok: N bytes written"` on success
- File permissions: `0644`

### memory_save

Save a knowledge entry for later retrieval. Entries persist across sessions in JSONL format.

```json
{
  "name": "memory_save",
  "description": "Save a memory entry for later retrieval.",
  "parameters": {
    "type": "object",
    "properties": {
      "content": {
        "type": "string",
        "description": "The content to remember."
      },
      "tags": {
        "type": "array",
        "items": { "type": "string" },
        "description": "Optional tags for categorisation."
      }
    },
    "required": ["content"]
  }
}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `content` | string | Yes | The knowledge to persist |
| `tags` | string[] | No | Optional tags for categorization and filtering |

### memory_search

Search saved memories by query string.

```json
{
  "name": "memory_search",
  "description": "Search saved memories by query string.",
  "parameters": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "The search query."
      },
      "tags": {
        "type": "array",
        "items": { "type": "string" },
        "description": "Optional tags to filter by."
      }
    },
    "required": ["query"]
  }
}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | Yes | Search query text |
| `tags` | string[] | No | Filter results by tags |

- Returns matching entries separated by `---`
- Empty result returns nothing (the LLM will communicate this)

### send_message

Send an immediate notification through a configured transport.

```json
{
  "name": "send_message",
  "description": "Send a notification to the user immediately.",
  "parameters": {
    "type": "object",
    "properties": {
      "body": {
        "type": "string",
        "description": "The message content to send."
      },
      "subject": {
        "type": "string",
        "description": "Optional short summary or title."
      },
      "channel": {
        "type": "string",
        "description": "Target transport: 'terminal', 'webhook', or empty for defaults. 'all' broadcasts."
      },
      "priority": {
        "type": "string",
        "enum": ["low", "normal", "high"],
        "description": "Notification urgency level."
      }
    },
    "required": ["body"]
  }
}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `body` | string | Yes | Message content |
| `subject` | string | No | Optional title/summary |
| `channel` | string | No | Target transport (`terminal`, `webhook`, empty for defaults, `all` for broadcast) |
| `priority` | string | No | `low`, `normal`, or `high` (default: `normal`) |

### schedule_notification

Schedule a delayed notification. Useful for reminders and timed alerts.

```json
{
  "name": "schedule_notification",
  "description": "Schedule a notification to be delivered after a delay.",
  "parameters": {
    "type": "object",
    "properties": {
      "delay_seconds": {
        "type": "integer",
        "description": "Number of seconds to wait before sending."
      },
      "body": {
        "type": "string",
        "description": "The notification message to deliver."
      },
      "subject": {
        "type": "string",
        "description": "Optional short title for the notification."
      },
      "channel": {
        "type": "string",
        "description": "Target transport: 'terminal', 'webhook', or empty for defaults."
      },
      "priority": {
        "type": "string",
        "enum": ["low", "normal", "high"],
        "description": "Notification urgency level."
      }
    },
    "required": ["delay_seconds", "body"]
  }
}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `delay_seconds` | integer | Yes | Seconds to wait (must be >= 1) |
| `body` | string | Yes | Notification message |
| `subject` | string | No | Optional title |
| `channel` | string | No | Target transport |
| `priority` | string | No | Defaults to `high` for scheduled reminders |

- Fires in the background using `time.AfterFunc`
- Delivers via notification transport AND injects into REPL input

## Custom Tools

ClawHive supports extending the tool registry with custom tools. Each tool requires:

1. A **tool definition** (`ToolDef`) with name, description, and JSON Schema parameters
2. A **handler function** (`Handler`) that receives arguments and returns a result string

```go
registry.Register(llm.ToolDef{
    Name:        "my_tool",
    Description: "Description of what the tool does.",
    Parameters: map[string]any{
        "type": "object",
        "properties": map[string]any{
            "param1": map[string]any{
                "type":        "string",
                "description": "Description of param1.",
            },
        },
        "required":             []string{"param1"},
        "additionalProperties": false,
    },
}, func(ctx context.Context, args json.RawMessage) (string, error) {
    // Parse args, execute logic, return result
    return "result", nil
})
```

See the [tool registry](https://github.com/clawhive/clawhive/blob/main/internal/tool/registry.go) implementation for details.
