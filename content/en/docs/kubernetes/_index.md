---
title: "Kubernetes"
linkTitle: "Kubernetes"
weight: 7
description: "Deploy ClawHive on Kubernetes"
---

## Overview

ClawHive provides a Kubernetes operator that manages agents as custom resources. This enables declarative agent management, automatic scaling, and cloud-native deployment.

## Prerequisites

- Kubernetes 1.28+
- `kubectl` configured
- [`kind`](https://kind.sigs.k8s.io/) for local development

## Custom Resource Definitions

ClawHive defines the following CRDs:

| CRD | Description |
|-----|-------------|
| `Agent` | Individual agent with LLM, tools, and memory |
| `AgentGroup` | Group of agents with shared channels |
| `Platform` | Top-level platform managing agent groups |
| `LLMProvider` | LLM provider credentials and configuration |
| `NotifyTransport` | Notification transport definition |
| `Skill` | Reusable skill prompt declaration |

## Quick Start with Kind

### 1. Create a Cluster

```bash
make dev-setup
```

This creates a kind cluster, installs CRDs, and deploys the operator.

### 2. Create an Agent

```bash
kubectl apply -f config/samples/clawhive_v1alpha1_agent.yaml
```

### 3. Check Agent Status

```bash
kubectl get agents
kubectl describe agent my-agent
```

### 4. Attach to Agent REPL

```bash
clawhive attach my-agent
```

## Teardown

```bash
make dev-teardown
```

## Operator Development

Build and deploy the operator to your kind cluster:

```bash
make docker-build
make kind-load
make deploy-operator
```

## Configuration

See the [`config/samples/`](https://github.com/clawhive/clawhive/tree/main/config/samples) directory for example configurations.
