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

## Platform Configuration

A **Platform** manages multiple agent groups and provides shared infrastructure including an MQTT broker, agent registry, and task dispatcher.

```yaml
apiVersion: clawhive/v1
kind: Platform
metadata:
  name: clawhive-platform
spec:
  mqtt:
    host: "0.0.0.0"         # MQTT broker bind address
    port: 1883               # MQTT broker port
    maxConnections: 1000     # Max concurrent connections
  registry:
    persistence:
      path: "/tmp/clawhive/registry"  # Agent registry storage path
  taskManager:
    staleTimeout: "1h"       # Timeout for stale task detection
  dispatcher:
    strategy: "first-available"  # Task dispatch strategy
```

### Platform Fields

| Field | Description |
|-------|-------------|
| `mqtt.host` | MQTT broker bind address |
| `mqtt.port` | MQTT broker port |
| `mqtt.maxConnections` | Maximum concurrent MQTT connections |
| `registry.persistence.path` | Filesystem path for agent registry persistence |
| `taskManager.staleTimeout` | Duration after which tasks are considered stale |
| `dispatcher.strategy` | Strategy for routing tasks to agents (`first-available`, etc.) |

### Running a Platform

```bash
clawhive platform run ./config/platform.yaml
```

## AgentGroup Configuration

An **AgentGroup** organizes multiple agents that communicate through channels using the A2A protocol.

```yaml
apiVersion: clawhive/v1
kind: AgentGroup
metadata:
  name: code-review-team
  labels:
    domain: engineering
spec:
  description: "A team of agents collaborating on code review"
  version: "1.0.0"
  members:
    - agentId: alpha
      role: reviewer
      description: "Senior code reviewer, focuses on architecture and design patterns"
    - agentId: beta
      role: developer
      description: "Backend developer responsible for auth and user management"
    - agentId: gamma
      role: tester
      description: "QA specialist focusing on integration tests and edge cases"
  communication:
    transport: mqtt
    config:
      broker:
        host: localhost
        port: 1883
    defaultChannel:
      enabled: true
      name: code-review-team
    dynamicChannels: true
```

### AgentGroup Fields

| Field | Description |
|-------|-------------|
| `metadata.name` | Group name (unique identifier) |
| `metadata.labels` | Key-value labels for grouping and discovery |
| `spec.description` | Human-readable description of the group |
| `spec.version` | Group configuration version |
| `spec.members` | List of agent members with IDs, roles, and descriptions |
| `spec.members[].agentId` | References an agent by its ID |
| `spec.members[].role` | Role of the agent within the group |
| `spec.communication.transport` | Transport protocol (`mqtt`) |
| `spec.communication.config.broker` | MQTT broker connection settings |
| `spec.communication.defaultChannel` | Default channel for group communication |
| `spec.communication.dynamicChannels` | Whether agents can create channels dynamically |

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

Each agent package requires a `package.yaml` manifest:

```yaml
apiVersion: clawhive/v1
kind: Package
metadata:
  name: my-agent
  version: "1.0.0"
  description: "A sample agent package"
agent: agent.yaml
```

| Field | Description |
|-------|-------------|
| `apiVersion` | API version, always `clawhive/v1` |
| `kind` | Resource type, always `Package` |
| `metadata.name` | Package name |
| `metadata.version` | Package version (semver) |
| `metadata.description` | Human-readable description |
| `agent` | Path to the agent configuration file (relative to the package directory) |

## Validation

Use the `validate` command to check your configuration:

```bash
clawhive validate ./my-agent/
```
