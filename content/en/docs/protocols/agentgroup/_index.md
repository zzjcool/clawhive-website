---
title: "AgentGroup Protocol"
linkTitle: "AgentGroup"
weight: 9
description: "Multi-agent group lifecycle, membership, channels, and communication"
---

## Overview

The AgentGroup Protocol describes how multiple agents organize into groups, communicate through channels, and coordinate via the A2A (Agent-to-Agent) protocol.

## AgentGroup Configuration

```yaml
apiVersion: clawhive/v1
kind: AgentGroup
metadata:
  name: code-review-team
  labels:
    domain: engineering
spec:
  description: "Agents collaborating on code review"
  version: "1.0.0"
  members:
    - agentId: alpha
      role: reviewer
      description: "Senior code reviewer"
    - agentId: beta
      role: developer
      description: "Backend developer"
    - agentId: gamma
      role: tester
      description: "QA specialist"
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

## Members

Each agent in a group has:
- **agentId**: References an agent by its ID
- **role**: Functional role within the group (e.g., `reviewer`, `developer`, `tester`)
- **description**: Human-readable description of the agent's responsibilities

## Communication

### Transport

Groups use MQTT as the transport layer for inter-agent communication. Each group connects to an MQTT broker configured in the `communication.config` section.

### Channels

Channels provide topic-based communication within a group:

| Channel Type | Description |
|-------------|-------------|
| Default channel | Automatically created for the group. All members can use it. |
| Dynamic channels | When `dynamicChannels: true`, agents can create ad-hoc channels. |

### Message Routing

Messages flow through channels:

```
Agent A → Channel "code-review-team" → Agent B
Agent A → Channel "alpha-beta"       → Agent B (direct)
Agent A → Broadcast                  → All group members
```

## A2A Protocol

Agent-to-Agent communication uses MQTT with JSON-RPC:

1. Agent connects to MQTT broker with its unique client ID
2. Agent subscribes to relevant channels
3. Agent publishes messages to channels
4. Receiving agents process messages through their standard pipeline

## Lifecycle

1. **Creation**: AgentGroup CRD is applied (Kubernetes) or YAML is loaded (local)
2. **Initialization**: MQTT connection established, default channel created
3. **Member Registration**: Each agent connects and registers with the group
4. **Communication**: Agents exchange messages via channels
5. **Teardown**: Group is deleted, connections closed

## Example: Code Review Team

See [`examples/agents/code-review-team.yaml`](https://github.com/clawhive/clawhive/tree/main/examples/agents) for a complete example of three agents collaborating on code review.
