---
title: "CLI Reference"
linkTitle: "CLI"
weight: 8
description: "ClawHive command-line interface reference"
---

## Overview

ClawHive provides a unified CLI for managing agents in both Docker and Kubernetes environments. Commands automatically detect the runtime mode (Docker or K8s) when applicable.

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

Validate an agent package or YAML configuration.

```bash
clawhive validate ./my-agent/
clawhive validate config.yaml
```

### list

List available agent packages in a directory.

```bash
clawhive list ./agents/
```

### chat

Start a chat session with a running agent. Auto-detects Kubernetes or Docker mode.

```bash
clawhive chat my-agent
```

**Behavior:**
- If `KUBECONFIG` is set and Agent CR exists → K8s mode (SPDY exec to Pod)
- Otherwise → Docker mode (existing behavior)
- User experience identical in both modes

### health

Check the health status of a running agent.

```bash
clawhive health                    # Quick health check
clawhive health --ready            # Deep readiness check (used by K8s probes)
```

**Kubernetes usage:** Called by Pod livenessProbe and readinessProbe to verify agent health.

### attach

Attach to a running agent's REPL (used internally by `clawhive chat`).

```bash
clawhive attach <agent-name>
```

**Note:** Usually invoked automatically by `clawhive chat`. Direct use is rare.

### platform

Manage the multi-agent platform.

```bash
# Run a platform locally
clawhive platform run ./config/platform.yaml
```

### operator

Start the ClawHive Kubernetes operator (controller-manager).

```bash
clawhive operator
clawhive operator --metrics-addr :8080
clawhive operator --health-probe-addr :8081
clawhive operator --leader-elect
```

**Flags:**
- `--metrics-addr` - Prometheus metrics address (default `:8080`)
- `--health-probe-addr` - Health probe address (default `:8081`)
- `--leader-elect` - Enable leader election for high availability

### apply

Apply a configuration file to Kubernetes. Automatically creates a Secret from `.env` files.

```bash
clawhive apply -f config/samples/full-stack.yaml
clawhive apply -f myconfig/    # auto-detects .env
```

**Behavior:**
- If `.env` file exists in the same directory, creates a K8s Secret from it
- Applies all YAML resources using `kubectl apply`
- Credentials not exposed in YAML files

### get

Query Kubernetes resources. Lists resources of a given kind.

```bash
clawhive get agents                # List all agents
clawhive get agents -o wide        # Wide output with extra columns
clawhive get agentgroups           # List agent groups
clawhive get platforms             # List platforms
clawhive get llmproviders          # List LLM providers
clawhive get skills                # List skills
clawhive get notifytransports      # List notification transports
```

| Flag | Description |
|------|-------------|
| `-o wide` | Show additional columns (status, pod, etc.) |
| `-n <namespace>` | Query specific namespace |

### delete

Delete Kubernetes resources.

```bash
clawhive delete agent my-agent
clawhive delete agentgroup review-team
clawhive delete platform clawhive
clawhive delete skill web-search
```

### logs

Stream logs from an agent's Pod.

```bash
clawhive logs my-agent             # Stream all logs
clawhive logs my-agent --tail 50   # Last 50 lines
clawhive logs my-agent -f          # Follow logs (tail -f)
```

**Kubernetes only:** Works with Pods created by Agent CRs.

### version

Print the ClawHive version.

```bash
clawhive version
```
