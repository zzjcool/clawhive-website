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

When running in Kubernetes mode, ClawHive provides the following custom resources:

| CRD | Description |
|-----|-------------|
| `Agent` | Defines an individual agent with LLM, tools, and memory config |
| `AgentGroup` | Manages a group of agents with shared channels |
| `Platform` | Top-level resource managing the multi-agent platform |
| `LLMProvider` | Configures LLM provider credentials and endpoints |
| `NotifyTransport` | Defines notification transport (terminal, webhook, etc.) |
| `Skill` | Declares a reusable skill prompt |

## Message Flow

1. Input arrives via REPL, API, or cron-injected prompt
2. System prompt is assembled from soul + memory + skills + notify capabilities
3. LLM is called (with streaming if supported)
4. Tool calls are executed in a loop (max 20 rounds), results fed back to LLM
5. Response is rendered to the user or sent via notification transport
