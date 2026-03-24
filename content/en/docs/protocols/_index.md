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
| [Message Protocol](#message-protocol) | Message structure, roles, streaming events, conversation history |
| [Agent Pipeline](#agent-pipeline) | Agent lifecycle, processing pipeline, system prompt assembly |
| [LLM Provider](#llm-provider) | Provider interface, multi-model adaptation, streaming |
| [Tool Invocation](#tool-invocation) | Tool definition schema, registration, invocation lifecycle |
| [Triage](#triage) | Two-stage message classification, processing strategies |
| [Memory](#memory) | Knowledge memory, conversation persistence, JSONL storage |
| [Notification](#notification) | Notification routing, transport abstraction, reminders |
| [Package](#package) | Agent package structure, manifest, path resolution |
| [AgentGroup](#agentgroup) | Multi-agent group lifecycle, membership, channels |

## Message Protocol {#message-protocol}

Defines the core message structure used throughout ClawHive. Messages have roles (user, assistant, system, tool), support streaming, and maintain conversation history.

## Agent Pipeline Protocol {#agent-pipeline}

Describes how an agent processes a message end-to-end: from system prompt assembly through LLM invocation to tool call loops and response rendering.

## LLM Provider Protocol {#llm-provider}

Specifies the interface contract for LLM providers. ClawHive supports OpenAI, Anthropic, and DeepSeek out of the box, with an extensible interface for custom providers.

## Tool Invocation Protocol {#tool-invocation}

Defines how tools are registered, discovered, and invoked. Each tool has a JSON Schema definition for parameter validation and a handler function for execution.

## Triage Protocol {#triage}

A two-stage message classification system that routes incoming messages to appropriate processing strategies.

## Memory Protocol {#memory}

Describes the memory interface for persistent knowledge storage and conversation history, using JSONL format on the filesystem.

## Notification Protocol {#notification}

Specifies how notifications are routed through transports (terminal, webhook) and how scheduled reminders work.

## Package Protocol {#package}

Defines the structure of agent packages: self-contained directories with a manifest, agent configuration, and optional skill files.

## AgentGroup Protocol {#agentgroup}

Describes multi-agent group lifecycle management, including membership, channels, subscriptions, and inter-agent communication.
