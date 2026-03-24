---
title: "Package Protocol"
linkTitle: "Package"
weight: 8
description: "Agent package structure, manifest, and path resolution"
---

## Overview

The Package Protocol defines the structure of agent packages — self-contained directories that encapsulate everything needed to run an agent: configuration, skills, and metadata.

## Package Structure

```
my-agent/
├── package.yaml       # Package manifest
├── agent.yaml         # Agent configuration
└── skills/            # Co-located skill files (optional)
    ├── code-review.md
    └── summarize.md
```

## Package Manifest

```yaml
apiVersion: clawhive/v1
kind: Package
metadata:
  name: jarvis
  version: "1.0.0"
  description: "A helpful personal assistant"
agent: agent.yaml
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `apiVersion` | string | Yes | Always `clawhive/v1` |
| `kind` | string | Yes | Always `Package` |
| `metadata.name` | string | Yes | Package name (unique identifier) |
| `metadata.version` | string | Yes | Semantic version |
| `metadata.description` | string | No | Human-readable description |
| `agent` | string | Yes | Path to agent YAML (relative to package directory) |

## Agent Configuration

The `agent.yaml` file defines the agent's behavior. See the [Configuration](../configuration/) page for the full schema.

```yaml
apiVersion: clawhive/v1
kind: Agent
metadata:
  name: jarvis
  description: "A helpful personal assistant"
spec:
  sandbox:
    image: debian:bookworm-slim
    workdir: /workspace
  llm:
    provider: openai
    model: ${LLM_MODEL}
    apiKey: ${API_KEY}
  soul:
    system: "You are Jarvis, a helpful personal assistant."
  memory:
    backend: filesystem
    config:
      path: ./data/agent/memory
  skills:
    - name: code-review
      path: ./skills/code-review.md
```

## Skills

Skills are markdown files that provide domain-specific instructions injected into the agent's system prompt. They are co-located with the agent package.

```markdown
# Code Review

When reviewing code, focus on:
1. Architecture and design patterns
2. Error handling
3. Performance considerations
4. Code readability and naming conventions

Provide constructive, actionable feedback.
```

## Path Resolution

The package system resolves paths relative to the package directory:

| Reference | Resolved To |
|-----------|-------------|
| `agent: agent.yaml` | `<package-dir>/agent.yaml` |
| `skills[].path: ./skills/code-review.md` | `<package-dir>/skills/code-review.md` |
| `memory.config.path: ./data/agent/memory` | `<package-dir>/data/agent/memory` |

## CLI Commands

| Command | Description |
|---------|-------------|
| `clawhive run ./my-agent/` | Run an agent package (directory) |
| `clawhive run ./my-agent/agent.yaml` | Run from a specific agent YAML file |
| `clawhive validate ./my-agent/` | Validate package configuration |
| `clawhive list ./agents/` | List agent packages in a directory |

## Example: Jarvis Package

A complete example is available at [`examples/jarvis/`](https://github.com/clawhive/clawhive/tree/main/examples/jarvis):

```
examples/jarvis/
├── package.yaml
├── agent.yaml
└── skills/
    ├── code-review.md
    └── summarize.md
```

Run it with:

```bash
clawhive run --local examples/jarvis/
```
