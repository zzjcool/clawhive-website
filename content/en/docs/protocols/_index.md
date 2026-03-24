---
title: "Protocols"
linkTitle: "Protocols"
weight: 6
description: "ClawHive protocol specifications"
---

ClawHive defines a set of formal protocols that govern how agents communicate, process messages, and interact with external systems.

## Protocol List

| Protocol | Description |
|----------|-------------|
| [Message Protocol](message/) | Message structure, roles, streaming events, conversation history |
| [Triage Protocol](triage/) | Two-stage message classification, 5 processing strategies |
| [Agent Pipeline](agent-pipeline/) | Agent lifecycle, processing pipeline, system prompt assembly |
| [LLM Provider](llm-provider/) | Provider interface, multi-model adaptation, streaming |
| [Tool Invocation](tool-invocation/) | Tool definition schema, registration, invocation lifecycle |
| [Memory](memory/) | Knowledge memory, conversation persistence, JSONL storage |
| [Notification](notification/) | Notification routing, transport abstraction, reminders |
| [Package](package/) | Agent package structure, manifest, path resolution |
| [AgentGroup](agentgroup/) | Multi-agent group lifecycle, membership, channels |

## Architecture Map

```
                    ┌─────────────────────────────────┐
                    │         Message Protocol         │
                    │   (core data structures)         │
                    └──────┬──────────┬───────────────┘
                           │          │
              ┌────────────▼──┐  ┌─────▼──────────────┐
              │ Agent Pipeline │  │  Tool Invocation   │
              │   Protocol     │  │    Protocol        │
              └──┬──────┬─────┘  └────────────────────┘
                 │      │
    ┌────────────▼┐  ┌─▼──────────────┐
    │   Triage    │  │  LLM Provider   │
    │   Protocol  │  │    Protocol      │
    └────────────┘  └──────────────────┘
         │
    ┌────┴────────────────────┐
    │                         │
┌───▼────┐  ┌──────────┐  ┌──▼──────────┐
│ Memory │  │Notification│ │  Package    │
│Protocol│  │ Protocol   │ │  Protocol   │
└────────┘  └────────────┘ └─────────────┘
                                       │
                              ┌────────▼────────┐
                              │  AgentGroup     │
                              │  Protocol       │
                              └─────────────────┘
```
