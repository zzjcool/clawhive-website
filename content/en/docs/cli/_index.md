---
title: "CLI Reference"
linkTitle: "CLI"
weight: 8
description: "ClawHive command-line interface reference"
---

## Overview

ClawHive provides a CLI with multiple commands for running agents, managing resources, and deploying to Kubernetes.

```bash
clawhive <command> [flags]
```

## Commands

### run

Run an agent interactively.

```bash
# Run in Docker sandbox (default)
clawhive run ./my-agent/

# Run locally on the host
clawhive run --local ./my-agent/

# Run from a specific agent.yaml file
clawhive run ./my-agent/agent.yaml
```

| Flag | Description |
|------|-------------|
| `--local` | Run agent on the host machine instead of Docker |

### validate

Validate an agent package configuration.

```bash
clawhive validate ./my-agent/
```

### list

List available agent packages in a directory.

```bash
clawhive list ./agents/
```

### chat

Start a chat session with a running agent.

```bash
clawhive chat <agent-name>
```

### health

Check the health status of a running agent.

```bash
clawhive health <agent-name>
```

### attach

Attach to a running Kubernetes agent's REPL.

```bash
clawhive attach <agent-name>
```

### platform

Manage the multi-agent platform.

```bash
# Run a platform locally
clawhive platform run ./config/platform.yaml
```

### operator

Manage the Kubernetes operator.

```bash
# Operator development subcommands
clawhive operator <subcommand>
```

### apply

Apply a configuration file to Kubernetes.

```bash
clawhive apply -f config/samples/full-stack.yaml
```

### get

Get Kubernetes resources.

```bash
clawhive get agents
clawhive get agentgroups
clawhive get platforms
```

### delete

Delete Kubernetes resources.

```bash
clawhive delete agent <agent-name>
clawhive delete agentgroup <group-name>
```

### logs

View logs for a Kubernetes resource.

```bash
clawhive logs <agent-name>
```

### version

Print the ClawHive version.

```bash
clawhive version
```
