---
title: "Examples"
linkTitle: "Examples"
weight: 10
description: "Example agent packages, multi-agent teams, and platform configurations"
---

## Jarvis — Personal Assistant

A complete agent package with skills for code review and summarization.

**Location:** [`examples/jarvis/`](https://github.com/clawhive/clawhive/tree/main/examples/jarvis)

**Structure:**

```
examples/jarvis/
├── package.yaml
├── agent.yaml
└── skills/
    ├── code-review.md
    └── summarize.md
```

**Run it:**

```bash
# Local mode
clawhive run --local examples/jarvis/

# Docker mode
clawhive run examples/jarvis/
```

## Code Review Team — Multi-Agent Collaboration

Three agents collaborating on code review through channels.

**Location:** [`examples/agents/`](https://github.com/clawhive/clawhive/tree/main/examples/agents)

**Members:**

| Agent | Role | Description |
|-------|------|-------------|
| `alpha` | Reviewer | Senior code reviewer, focuses on architecture and design patterns |
| `beta` | Developer | Backend developer responsible for auth and user management |
| `gamma` | Tester | QA specialist focusing on integration tests and edge cases |

**Run the agents individually:**

```bash
clawhive run --local examples/agents/alpha/
clawhive run --local examples/agents/beta/
clawhive run --local examples/agents/gamma/
```

**Group configuration:** See [`examples/agents/code-review-team.yaml`](https://github.com/clawhive/clawhive/tree/main/examples/agents/code-review-team.yaml) for the AgentGroup definition.

## Platform Configuration

A full platform configuration with MQTT broker, agent registry, and task dispatcher.

**Location:** [`examples/platform/platform.yaml`](https://github.com/clawhive/clawhive/tree/main/examples/platform/platform.yaml)

**Run it:**

```bash
clawhive platform run examples/platform/platform.yaml
```

## Kubernetes Full-Stack Deployment

A complete Kubernetes deployment with all CRDs pre-configured.

**Location:** [`config/samples/full-stack.yaml`](https://github.com/clawhive/clawhive/tree/main/config/samples/full-stack.yaml)

Includes: Namespace, Secret, Platform, LLMProvider, NotifyTransport, Skill, AgentTemplate, and AgentGroup resources.

```bash
kubectl apply -f config/samples/full-stack.yaml
```

## Individual CRD Samples

Separate sample files for each CRD are available in [`config/samples/`](https://github.com/clawhive/clawhive/tree/main/config/samples):

```bash
kubectl apply -f config/samples/clawhive_v1alpha1_agent.yaml
kubectl apply -f config/samples/clawhive_v1alpha1_agentgroup.yaml
kubectl apply -f config/samples/clawhive_v1alpha1_platform.yaml
kubectl apply -f config/samples/clawhive_v1alpha1_llmprovider.yaml
kubectl apply -f config/samples/clawhive_v1alpha1_notifytransport.yaml
kubectl apply -f config/samples/clawhive_v1alpha1_skill.yaml
```
