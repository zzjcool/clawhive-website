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
| `Agent` | Individual agent with LLM, tools, and memory config |
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

### 2. Deploy Resources

Apply the full-stack sample which includes all necessary resources:

```bash
kubectl apply -f config/samples/full-stack.yaml
```

Or deploy individual resources:

```bash
kubectl apply -f config/samples/clawhive_v1alpha1_agent.yaml
kubectl apply -f config/samples/clawhive_v1alpha1_agentgroup.yaml
```

### 3. Check Status

```bash
kubectl get agents
kubectl get agentgroups
kubectl get platforms

kubectl describe agent my-agent
```

### 4. Attach to Agent REPL

```bash
clawhive attach my-agent
```

### 5. View Logs

```bash
clawhive logs my-agent
```

## Teardown

```bash
make dev-teardown
```

## Operator Development

Build and deploy the operator to your kind cluster:

```bash
make docker-build     # Build operator Docker image
make kind-load        # Load image into kind cluster
make deploy-operator  # Deploy/update the operator
```

## CRD Examples

### Agent

```yaml
apiVersion: clawhive.io/v1alpha1
kind: Agent
metadata:
  name: my-agent
spec:
  agentConfig:
    llm:
      provider: openai
      model: gpt-4
    soul:
      system: "You are a helpful assistant."
```

### AgentGroup

```yaml
apiVersion: clawhive.io/v1alpha1
kind: AgentGroup
metadata:
  name: code-review-team
spec:
  members:
    - agentId: alpha
      role: reviewer
    - agentId: beta
      role: developer
  communication:
    transport: mqtt
    config:
      broker:
        host: mqtt-broker
        port: 1883
```

### LLMProvider

```yaml
apiVersion: clawhive.io/v1alpha1
kind: LLMProvider
metadata:
  name: openai-provider
spec:
  provider: openai
  apiKey:
    secretRef:
      name: llm-secrets
      key: api-key
```

## Configuration

See the [`config/samples/`](https://github.com/clawhive/clawhive/tree/main/config/samples) directory for all example configurations. See [Examples](../examples/) for walkthroughs.
