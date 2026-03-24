---
title: "Getting Started"
linkTitle: "Getting Started"
weight: 2
description: "Install ClawHive and run your first agent"
---

## Prerequisites

- **Go** 1.23+
- **Docker** (for containerized agent execution)
- **Kubernetes** cluster with `kind` (optional, for K8s-native mode)

## Installation

### From Source

```bash
git clone https://github.com/clawhive/clawhive.git
cd clawhive
make build
```

### Using Go Install

```bash
go install github.com/clawhive/clawhive/cmd/clawhive@latest
```

## Quick Start

### 1. Create an Agent Package

Create a directory with a `package.yaml` manifest and an `agent.yaml` configuration:

```
my-agent/
├── package.yaml       # Package manifest
└── agent.yaml         # Agent configuration
```

**package.yaml:**

```yaml
apiVersion: clawhive/v1
kind: Package
metadata:
  name: my-agent
  version: "1.0.0"
  description: "My first ClawHive agent"
agent: agent.yaml
```

**agent.yaml:**

```yaml
apiVersion: clawhive/v1
kind: Agent
metadata:
  name: my-agent
  description: "My first ClawHive agent"
spec:
  llm:
    provider: openai
    model: ${LLM_MODEL}
    apiKey: ${API_KEY}
  soul:
    system: "You are a helpful assistant."
```

### 2. Set Environment Variables

Create a `.env` file:

```bash
LLM_MODEL=gpt-4
API_KEY=your-api-key
```

### 3. Run the Agent

**Local mode** (runs on host machine, best for development):

```bash
clawhive run --local ./my-agent
```

**Docker mode** (runs inside an isolated container, best for production):

```bash
clawhive run ./my-agent
```

The agent starts an interactive REPL where you can chat with it directly. Use `/help` to see available commands.

### 4. Using the REPL

Once the REPL is running, you can:

- Type messages directly to chat with the agent
- Use `/help` to see available slash commands
- Use `/skills`, `/memory`, `/cron` to inspect agent state
- Use `/clear` to reset conversation history
- Use `/quit` to exit

## Next Steps

- Learn about [core concepts](../concepts/)
- Explore [configuration options](../configuration/)
- Check out the [examples](https://github.com/clawhive/clawhive/tree/main/examples) in the repository
