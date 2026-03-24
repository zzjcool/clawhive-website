---
title: "LLM Providers"
linkTitle: "LLM Providers"
weight: 9
description: "Configuring LLM providers in ClawHive"
---

## Overview

ClawHive supports multiple LLM providers through a unified interface. Configure the provider in your agent's `spec.llm` section.

## Supported Providers

### OpenAI

Full streaming support via Server-Sent Events (SSE).

```yaml
llm:
  provider: openai
  model: ${LLM_MODEL}        # e.g. gpt-4, gpt-4o, gpt-3.5-turbo
  apiKey: ${API_KEY}
  baseURL: ${API_BASE_URL}   # Optional, for custom endpoints
```

- **Streaming**: Supported (SSE)
- **Retry**: Exponential backoff on transient errors
- **Default model**: Configured via `LLM_MODEL` environment variable

### Anthropic

Non-streaming mode using the Messages API format.

```yaml
llm:
  provider: anthropic
  model: ${LLM_MODEL}        # e.g. claude-3-sonnet, claude-3-opus
  apiKey: ${API_KEY}
```

- **Streaming**: Not supported (non-streaming mode)
- **API Format**: Anthropic Messages API

### DeepSeek

Uses an OpenAI-compatible API wrapper.

```yaml
llm:
  provider: deepseek
  model: ${LLM_MODEL}        # e.g. deepseek-chat, deepseek-coder
  apiKey: ${API_KEY}
```

- **Streaming**: Depends on the DeepSeek API configuration
- **Compatible**: Works with any OpenAI-compatible API endpoint

## Using OpenAI-Compatible APIs

Any OpenAI-compatible API (OpenRouter, Together AI, local LLMs via Ollama/vLLM, etc.) can be used by setting a custom `baseURL`:

```yaml
llm:
  provider: openai
  model: openai/gpt-4o
  apiKey: ${API_KEY}
  baseURL: https://openrouter.ai/api/v1
```

```bash
API_KEY=sk-or-...
API_BASE_URL=https://openrouter.ai/api/v1
LLM_MODEL=openai/gpt-4o
```

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `API_KEY` | LLM provider API key | `sk-...` |
| `API_BASE_URL` | Custom API base URL (optional) | `https://openrouter.ai/api/v1` |
| `LLM_MODEL` | Model name | `gpt-4`, `claude-3-sonnet`, `deepseek-chat` |

Environment variables are loaded from:
1. `.env` file in the working directory
2. `.env` file in the agent's config directory
3. System environment variables

Use `${VAR_NAME}` syntax in YAML configuration to reference environment variables.

## Provider Interface

ClawHive defines two Go interfaces for LLM providers:

- `Provider` — basic `Chat(ctx, messages, tools)` method (non-streaming)
- `StreamProvider` — extends Provider with `ChatStream(ctx, messages, tools)` for streaming responses

Providers that implement `StreamProvider` automatically use streaming when available.
