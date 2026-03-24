---
title: "LLM Provider Protocol"
linkTitle: "LLM Provider"
weight: 4
description: "Provider interface, multi-model adaptation, and streaming"
---

## Overview

The LLM Provider Protocol specifies the interface contract for LLM providers. ClawHive supports OpenAI, Anthropic, and DeepSeek out of the box, with an extensible interface for custom providers.

## Provider Interfaces

```go
// Basic provider (non-streaming)
type Provider interface {
    Chat(ctx context.Context, messages []Message, tools []ToolDef) (*Response, error)
}

// Streaming provider (extends Provider)
type StreamProvider interface {
    Provider
    ChatStream(ctx context.Context, messages []Message, tools []ToolDef) (<-chan StreamChunk, error)
}
```

## Built-in Providers

### OpenAI

Full streaming support via Server-Sent Events (SSE).

| Feature | Support |
|---------|---------|
| Streaming | Yes (SSE) |
| Retry | Exponential backoff on transient errors |
| API Format | Chat Completions API |

### Anthropic

Non-streaming mode using the Messages API format.

| Feature | Support |
|---------|---------|
| Streaming | No (non-streaming) |
| API Format | Anthropic Messages API |

### DeepSeek

Uses an OpenAI-compatible API wrapper.

| Feature | Support |
|---------|---------|
| Streaming | Depends on API configuration |
| API Format | OpenAI-compatible |

## StreamChunk

When streaming, providers emit chunks:

```go
type StreamChunk struct {
    Delta        string      // Text increment
    ToolCalls    []ToolCall  // Tool calls in this chunk (if any)
    FinishReason string      // "stop", "tool_calls", etc.
    Err          error       // Error (if any)
}
```

## Response Object

Non-streaming providers return a complete response:

```go
type Response struct {
    Content   string     // Text content
    ToolCalls []ToolCall // Tool calls requested by the LLM
}
```

## Extending with Custom Providers

To add a new LLM provider, implement the `Provider` (and optionally `StreamProvider`) interface and register it with the agent.
