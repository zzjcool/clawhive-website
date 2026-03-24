---
title: "Built-in Tools"
linkTitle: "Tools"
weight: 5
description: "Tools available to ClawHive agents"
---

## Tool System

ClawHive agents use a registry-based tool system. Each tool is defined with a JSON Schema for parameter validation and a handler function for execution.

## Built-in Tools

### exec

Execute shell commands in the agent's sandbox.

```json
{
  "name": "exec",
  "description": "Execute a shell command",
  "parameters": {
    "command": "ls -la"
  }
}
```

### read_file / write_file

Read and write files in the agent's workspace.

```json
{
  "name": "read_file",
  "parameters": {
    "path": "/workspace/config.yaml"
  }
}
```

### memory_save / memory_search

Persist and retrieve knowledge from the agent's memory.

```json
{
  "name": "memory_search",
  "parameters": {
    "query": "project architecture"
  }
}
```

### send_message

Send an immediate notification through a configured transport.

```json
{
  "name": "send_message",
  "parameters": {
    "content": "Task completed successfully",
    "channel": "terminal"
  }
}
```

### schedule_notification

Schedule a delayed notification.

```json
{
  "name": "schedule_notification",
  "parameters": {
    "content": "Reminder: review PR #42",
    "delay_seconds": 3600,
    "channel": "webhook"
  }
}
```

## Custom Tools

ClawHive supports extending the tool registry with custom tools. Tools are registered with a JSON Schema definition and a handler function.

See the [tool registry](https://github.com/clawhive/clawhive/blob/main/internal/tool/registry.go) implementation for details.
