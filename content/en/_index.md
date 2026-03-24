---
title: "ClawHive"
linkTitle: "ClawHive"
description: "An agentic AI assistant framework for building autonomous AI agents"

type: docs
---

## What is ClawHive?

ClawHive is a Go-based agentic AI assistant framework for defining, configuring, and running autonomous AI agents. It provides a Kubernetes-native architecture with support for multiple LLM providers, tool execution, memory persistence, agent-to-agent communication, and more.

## Key Features

- **Multi-LLM Support** - OpenAI, Anthropic, DeepSeek, and any OpenAI-compatible API
- **Tool System** - Extensible tool registry with built-in exec, file, memory, and notification tools
- **Agent-to-Agent (A2A)** - MQTT-based communication protocol between agents
- **Agent Groups** - Multi-agent orchestration with channels, subscriptions, and lifecycle management
- **Kubernetes-Native** - Run as a Kubernetes operator with custom resource definitions
- **Memory & Cron** - Persistent knowledge memory and scheduled prompt injection
- **Skills** - Markdown-based skill files for extending agent capabilities

## Quick Links

| | |
|---|---|
| **[Getting Started](/docs/getting-started/)** | Install ClawHive and run your first agent |
| **[Concepts](/docs/concepts/)** | Understand the core concepts and architecture |
| **[Configuration](/docs/configuration/)** | Learn how to configure agents and platforms |
| **[Kubernetes](/docs/kubernetes/)** | Deploy ClawHive on Kubernetes |
