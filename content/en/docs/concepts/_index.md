---
title: "Concepts"
linkTitle: "Concepts"
weight: 3
description: "Core concepts of the ClawHive framework"
---

## Architecture Overview

ClawHive is built around the **Agent** as the central orchestrator:

```
Config (YAML) → Agent → LLM Provider (OpenAI/Anthropic/DeepSeek)
                  ↓
            ┌────┴────┬────────┬─────────┬──────────┐
            │         │        │         │          │
          Soul     Memory   Tools    Cron      Notifier
        (prompt)  (persist) (exec)  (schedule)  (push)
```

## Agent

An **Agent** is the core abstraction in ClawHive. Each agent has:

- A **system prompt** (soul) that defines its personality and capabilities
- An **LLM provider** for language model inference
- A **memory** backend for persistent knowledge
- A set of **tools** it can invoke
- Optional **skills** (markdown-based prompt extensions)
- Optional **cron jobs** for scheduled tasks

## Agent Package

An **Agent Package** is a self-contained directory that defines an agent:

```
my-agent/
├── package.yaml       # Package manifest (name, version, description)
├── agent.yaml         # Agent configuration
└── skills/            # Co-located skill files
    ├── code-review.md
    └── summarize.md
```

## Platform

A **Platform** manages multiple agent groups and provides shared infrastructure:

- Agent registry and discovery
- Inter-group communication broker
- Shared configuration

## Agent Group

An **AgentGroup** organizes multiple agents that communicate through **channels**. Agents can subscribe to channels and exchange messages using the A2A (Agent-to-Agent) protocol.

## A2A Protocol

The **A2A Protocol** enables communication between agents over MQTT using JSON-RPC. Agents can:

- Send direct messages to other agents
- Broadcast to agent groups
- Subscribe to channels for topic-based communication

## Kubernetes CRDs

ClawHive transforms into a **Kubernetes-native operator** when running on K8s. Instead of imperative Docker commands, every resource becomes a declarative CRD:

| CRD | Scope | Purpose |
|-----|-------|---------|
| `LLMProvider` | Namespace | Shared LLM credentials and config |
| `Skill` | Namespace | Reusable skill definitions |
| `NotifyTransport` | Namespace | Notification channel configs |
| `Platform` | Namespace | Singleton MQTT broker infrastructure |
| `AgentTemplate` | Namespace | Reusable agent config blueprint |
| `AgentGroup` | Namespace | Orchestrates multiple Agent instances |
| `Agent` | Namespace | Running agent instance (auto-created, maps 1:1 to Pod) |

### Kubernetes Resource Hierarchy

ClawHive mirrors Kubernetes native patterns:

```
AgentGroup → Agent → Pod
(like Deployment → ReplicaSet → Pod)
```

- **AgentTemplate**: User creates. Reusable blueprint for agent configuration.
- **AgentGroup**: User creates. References AgentTemplates and specifies members.
- **Agent**: Auto-created by AgentGroup Controller from template instances.
- **Pod**: Auto-created by Agent Controller. Actual running container.

See [Kubernetes documentation](../kubernetes/) for detailed CRD specifications.

## Triage System

ClawHive includes a **two-stage message classification** system (triage) that optimizes cost and latency by routing messages to appropriate processing strategies:

| Strategy | Behavior |
|----------|----------|
| `silent` | Message produces no output. Useful for acknowledgments. |
| `memory_only` | Message is saved to memory but no LLM response is generated. |
| `brief` | A short, lightweight response is generated. |
| `tool_only` | Response is limited to tool invocations without explanatory text. |
| `full` | Standard full LLM processing with all capabilities. |

The triage classifier uses a lightweight LLM call to evaluate the incoming message context (last 5 messages) and selects the appropriate strategy. If the triage LLM fails, the system **fails open** to `full` processing, ensuring no messages are lost.

## Streaming Events

When processing messages, agents emit a sequence of **streaming events** through a channel:

| Event | Description |
|-------|-------------|
| `token` | Text increment from the LLM's streaming response |
| `triage_decision` | Triage classification result (strategy + reasoning) |
| `skipped` | Message was skipped by triage (silent/memory_only) |
| `tool_start` | Tool invocation has begun |
| `tool_result` | Tool execution has completed |
| `error` | An error occurred during processing |
| `done` | Stream is complete, no more events |

A typical event sequence: `token → token → ... → tool_start → tool_result → token → ... → done`

## REPL

The interactive **REPL** (Read-Eval-Print Loop) is the primary way to interact with agents. When you run an agent, it starts a REPL session with these slash commands:

| Command | Description |
|---------|-------------|
| `/help` | Show available commands |
| `/skills` | List loaded skills |
| `/memory` | Show current memory entries |
| `/cron` | Show configured cron jobs |
| `/clear` | Clear conversation history |
| `/quit` or `/exit` | Exit the REPL |

The REPL also handles cron-injected prompts automatically — when a cron job fires, its output appears inline with the conversation.

## Sandbox Modes

ClawHive supports two execution modes for agents:

| Mode | Command | Description |
|------|---------|-------------|
| **Local** | `clawhive run --local ./agent` | Agent runs directly on the host machine. Tools execute in the local filesystem. Best for development. |
| **Docker** | `clawhive run ./agent` | Agent runs inside an isolated Docker container. The `sandbox.image` and `sandbox.workdir` from agent config determine the container environment. Best for production and untrusted code. |

## Message Flow

1. Input arrives via REPL, API, or cron-injected prompt
2. System prompt is assembled from soul + memory + skills + notify capabilities
3. Optional triage classification (if triage LLM is configured)
4. LLM is called (with streaming if supported)
5. Tool calls are executed in a loop (max 20 rounds), results fed back to LLM
6. Response is rendered to the user or sent via notification transport
