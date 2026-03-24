---
title: "Configuration"
linkTitle: "Configuration"
weight: 4
description: "How to configure ClawHive agents and platforms"
---

## Agent Configuration

Agent configuration uses Kubernetes-style YAML format:

```yaml
apiVersion: clawhive/v1
kind: Agent
metadata:
  name: agent-name
  description: "Agent description"
spec:
  # Sandbox configuration (Docker container)
  sandbox:
    image: debian:bookworm-slim
    workdir: /workspace

  # LLM provider settings
  llm:
    provider: openai  # openai | anthropic | deepseek
    model: ${LLM_MODEL}
    apiKey: ${API_KEY}
    baseURL: ${API_BASE_URL}  # Optional, for custom endpoints

  # System prompt
  soul:
    system: "You are a helpful assistant."
    traits: [helpful, concise]

  # Memory configuration
  memory:
    backend: filesystem
    config:
      path: ./data/agent/memory

  # Skills
  skills:
    - name: skill-name
      path: ./skills/skill.md

  # Cron jobs
  cron:
    - name: daily-summary
      schedule: "0 8 * * *"
      prompt: "Generate a daily summary"
      notify:
        channels: [terminal]
        priority: normal

  # Notifications
  notify:
    defaults: [terminal]
    transports:
      - name: terminal
        type: terminal
      - name: webhook
        type: webhook
        config:
          url: "https://example.com/webhook"
```

## Environment Variables

ClawHive supports `${ENV_VAR}` syntax in configuration values. Environment variables are loaded from:

- `.env` file in the working directory
- `.env` file in the config directory
- System environment variables

| Variable | Purpose |
|----------|---------|
| `API_KEY` | LLM provider API key |
| `API_BASE_URL` | Custom API base URL (OpenRouter, etc.) |
| `LLM_MODEL` | Model name to use |

## Package Manifest

```yaml
name: my-agent
version: 1.0.0
description: "A sample agent package"
agent:
  path: ./agent.yaml
```

## Validation

Use the `validate` command to check your configuration:

```bash
clawhive validate ./my-agent/
```
