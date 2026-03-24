---
title: "Tool Invocation Protocol"
linkTitle: "Tool Invocation"
weight: 5
description: "Tool definition, registration, validation, and invocation lifecycle"
---

## Overview

The Tool Invocation Protocol defines how tools are registered, discovered, and invoked. Each tool has a JSON Schema definition for parameter validation and a handler function for execution.

## Tool Registry

The registry manages tool definitions and their handlers:

```go
type Registry struct {
    tools    map[string]Handler    // name → handler
    toolDefs []ToolDef             // ordered definitions for LLM
    schemas  map[string]map[string]any // name → parameter schema
}
```

- Tools are registered with a unique name
- Duplicate names are rejected
- JSON Schema is cached for validation
- Definitions are provided to the LLM as function definitions

## Tool Definition

```go
type ToolDef struct {
    Name        string         `json:"name"`
    Description string         `json:"description"`
    Parameters  map[string]any `json:"parameters"` // JSON Schema
}
```

Parameters follow JSON Schema format with `type`, `properties`, `required`, and `additionalProperties`.

## Invocation Lifecycle

```
LLM returns tool_calls
    │
    ▼
Parse tool call (id, name, arguments)
    │
    ▼
Validate arguments against JSON Schema
    │                     │
    │                  Error → "error: <description>" fed back to LLM
    │
    ▼
Execute handler(ctx, args)
    │                     │
    │                  Error → "error: <description>" fed back to LLM
    │
    ▼
Return result string to LLM
```

### Validation

The registry validates tool arguments before invoking the handler:

1. **JSON parsing**: Arguments must be valid JSON
2. **Required fields**: All fields in the `required` array must be present and non-empty
3. **Additional properties**: If `additionalProperties: false`, unknown fields are rejected

### Error Handling

Tool errors do **not** terminate the conversation. The error message is formatted as `"error: <description>"` and placed in the tool message's `content` field, allowing the LLM to observe the error and decide how to proceed.

## Built-in Tools

| Tool | Category | Timeout |
|------|----------|---------|
| `exec` | Execution | 30s default |
| `read_file` | File I/O | — |
| `write_file` | File I/O | — |
| `memory_save` | Memory | — |
| `memory_search` | Memory | — |
| `send_message` | Notification | — |
| `schedule_notification` | Notification | Background timer |

See the [Built-in Tools](../tools/) page for full parameter schemas.

## Custom Tools

To add a custom tool:

```go
registry.Register(llm.ToolDef{
    Name:        "my_tool",
    Description: "Description for the LLM.",
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
    // Implementation
    return "result", nil
})
```
