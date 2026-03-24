---
title: "Kubernetes"
linkTitle: "Kubernetes"
weight: 7
description: "Deploy ClawHive on Kubernetes"
---

## Overview

ClawHive is a **Kubernetes-native operator** that transforms agent management from imperative Docker-based control to declarative, cloud-native resource management. Every agent is a Pod, every configuration is a CRD, and the entire system benefits from Kubernetes' self-healing, reconciliation, and operational maturity.

### Architecture

```
┌─────────────────────────────────────────────────┐
│           Custom Resources (user creates)        │
│  AgentTemplate  AgentGroup  Platform             │
│  LLMProvider    Skill       NotifyTransport      │
└─────────────────────────────────────────────────┘
                  │ watch & reconcile
                  ▼
┌─────────────────────────────────────────────────┐
│     ClawHive Operator (controller-manager)       │
│  PlatformController    AgentGroupController      │
│  AgentController       LLMProviderController     │
│  SkillController       NotifyTransportController │
└─────────────────────────────────────────────────┘
                  │ creates & manages
                  ▼
┌─────────────────────────────────────────────────┐
│         Auto-managed Kubernetes Resources        │
│  Agent CRs (by AgentGroup)                      │
│  Pods + ConfigMaps (by Agent)                   │
│  MQTT Deployment + Service (by Platform)        │
└─────────────────────────────────────────────────┘
```

### Key Concepts

- **Resource Hierarchy**: `AgentGroup` → `Agent` → `Pod` (mirrors K8s patterns: Deployment → ReplicaSet → Pod)
- **Declarative Management**: Users write YAML CRs; the operator reconciles state continuously
- **CLI Transparency**: `clawhive chat <name>` auto-detects K8s mode and connects via SPDY exec (no command changes needed)
- **Template-Instance Model**: `AgentTemplate` is a reusable blueprint, `AgentGroup` instantiates `Agent` CRs from templates

## Prerequisites

- Kubernetes 1.28+
- `kubectl` configured
- [`kind`](https://kind.sigs.k8s.io/) for local development (recommended)

## Custom Resource Definitions

ClawHive defines **7 CRDs** under the `clawhive.io/v1alpha1` API group:

| CRD | Scope | Description |
|-----|-------|-------------|
| `LLMProvider` | Namespace | LLM connection credentials, model, and API base URL |
| `Skill` | Namespace | Reusable skill definition (inline markdown or ConfigMap reference) |
| `NotifyTransport` | Namespace | Notification channel config (webhook, terminal, etc.) |
| `Platform` | Namespace | Singleton MQTT broker config (managed or external) |
| `AgentTemplate` | Namespace | Reusable agent config blueprint (LLM, soul, memory, skills, triage, A2A) |
| `AgentGroup` | Namespace | Orchestration resource that instantiates Agent CRs from templates |
| `Agent` | Namespace | Running agent instance (auto-created by AgentGroup, maps 1:1 to Pod) |

## Quick Start with Kind

### 1. Create and Setup Cluster

```bash
make dev-setup
```

This command:
- Creates a kind cluster named `clawhive`
- Installs CRDs into the cluster
- Runs the operator locally (not in a Pod, for easy debugging)

### 2. Create LLMProvider Secret

If not already present, create a Kubernetes Secret with your LLM API credentials:

```bash
kubectl create secret generic llm-secrets \
  --from-literal=api-key=$API_KEY \
  --from-literal=api-base-url=$API_BASE_URL
```

Or use `clawhive apply` with a `.env` file (see below).

### 3. Deploy Resources

Apply the full-stack sample which includes all necessary resources:

```bash
clawhive apply -f config/samples/full-stack.yaml
```

Or deploy individual resources step by step. Create a `config.yaml` with:

```yaml
---
# LLMProvider
apiVersion: clawhive.io/v1alpha1
kind: LLMProvider
metadata:
  name: openai-gpt4
spec:
  provider: openai
  model: gpt-4
  secretRef:
    name: llm-secrets
    key: api-key
---
# Platform with managed MQTT
apiVersion: clawhive.io/v1alpha1
kind: Platform
metadata:
  name: clawhive
spec:
  mqtt:
    mode: managed
    managed:
      image: eclipse-mosquitto:2
      replicas: 1
---
# AgentTemplate
apiVersion: clawhive.io/v1alpha1
kind: AgentTemplate
metadata:
  name: code-reviewer
spec:
  sandbox:
    image: debian:bookworm-slim
    resources:
      requests:
        memory: 256Mi
        cpu: 200m
  llmProviderRef:
    name: openai-gpt4
  soul:
    system: "You are a code reviewer"
---
# AgentGroup
apiVersion: clawhive.io/v1alpha1
kind: AgentGroup
metadata:
  name: review-team
spec:
  platformRef:
    name: clawhive
  members:
    - templateRef:
        name: code-reviewer
      role: reviewer
      instanceName: reviewer-1
```

Then apply:

```bash
clawhive apply -f config.yaml
```

### 4. Check Status

List agents, groups, and templates:

```bash
clawhive get agents
clawhive get agentgroups
clawhive get platforms
```

Detailed information:

```bash
clawhive get agents -o wide
kubectl describe agent review-team-reviewer-1
kubectl get pods -l clawhive-agent=review-team-reviewer-1
```

### 5. Chat with Agent

Connect to an agent's REPL:

```bash
clawhive chat reviewer-1
```

The command automatically:
- Detects K8s mode (if KUBECONFIG is present)
- Finds the Agent CR
- Locates the Pod
- Attaches via SPDY exec
- User never sees the complexity

### 6. View Logs

Stream pod logs:

```bash
clawhive logs reviewer-1
```

Or use kubectl:

```bash
kubectl logs -f deployment/review-team-reviewer-1
```

## Using `.env` for Secrets

When running `clawhive apply`, if a `.env` file exists in the same directory:

```bash
# myconfig/.env
API_KEY=sk-...
API_BASE_URL=https://api.openai.com/v1
LLM_MODEL=gpt-4
```

`clawhive apply -f myconfig/` will:
1. Create a K8s Secret from the `.env` file
2. Apply the YAML resources

This simplifies credential management without exposing secrets in YAML.

## Teardown

```bash
make dev-teardown
```

This deletes the kind cluster and all resources.

## CRD Reference

### LLMProvider

Defines shared LLM connection configuration. Multiple AgentTemplates can reference the same LLMProvider.

```yaml
apiVersion: clawhive.io/v1alpha1
kind: LLMProvider
metadata:
  name: openai-gpt4
spec:
  provider: openai              # openai | anthropic | deepseek
  model: gpt-4
  baseURL: https://api.openai.com/v1   # optional
  secretRef:
    name: llm-api-keys          # K8s Secret name
    key: openai-api-key         # key within the Secret
status:
  ready: true
  lastVerified: "2026-03-23T09:00:00Z"
```

### Skill

Defines a reusable skill. Supports inline content or ConfigMap reference.

```yaml
apiVersion: clawhive.io/v1alpha1
kind: Skill
metadata:
  name: web-search
spec:
  # Option 1: Inline content
  inline: |
    # Web Search
    You can search the web using...
  # Option 2: Reference external ConfigMap
  # configMapRef:
  #   name: skill-web-search
  #   key: search.md
status:
  ready: true
  contentHash: "sha256:abc123..."
```

### NotifyTransport

Defines a notification channel configuration.

```yaml
apiVersion: clawhive.io/v1alpha1
kind: NotifyTransport
metadata:
  name: slack-webhook
spec:
  type: webhook
  config:
    url: https://hooks.slack.com/services/xxx
status:
  ready: true
  conditions:
    - type: WebhookValid
      status: "True"
```

### Platform

Singleton resource declaring MQTT broker infrastructure. Supports managed (operator deploys) or external (user-provided) modes.

```yaml
apiVersion: clawhive.io/v1alpha1
kind: Platform
metadata:
  name: clawhive
spec:
  mqtt:
    mode: managed               # managed | external
    managed:
      image: eclipse-mosquitto:2
      replicas: 1
      resources:
        requests:
          memory: 64Mi
          cpu: 100m
    external:
      host: mqtt.example.com
      port: 1883
status:
  mqtt:
    ready: true
    endpoint: clawhive-mqtt-broker.default.svc:1883
```

### AgentTemplate

Reusable agent configuration blueprint. Does not create Pods directly—must be referenced by an AgentGroup.

```yaml
apiVersion: clawhive.io/v1alpha1
kind: AgentTemplate
metadata:
  name: code-reviewer
spec:
  sandbox:
    image: debian:bookworm-slim
    workdir: /workspace
    resources:
      requests:
        memory: 256Mi
        cpu: 200m
  llmProviderRef:
    name: openai-gpt4
  soul:
    system: "You are a code reviewer"
    traits:
      - thorough
      - concise
  memory:
    path: /data/memory
  skillRefs:
    - name: web-search
    - name: code-analysis
  notifyTransportRefs:
    - name: slack-webhook
  cron:
    - name: daily-review
      schedule: "0 9 * * *"
      prompt: "Check for pending reviews"
  triage:
    enabled: true
    llmProviderRef:
      name: openai-gpt4-turbo
  a2a:
    enabled: true
status:
  refsValid: true
  conditions:
    - type: RefsResolved
      status: "True"
```

### AgentGroup

Orchestrates Agent instantiation from templates. Each member references an AgentTemplate.

```yaml
apiVersion: clawhive.io/v1alpha1
kind: AgentGroup
metadata:
  name: review-team
spec:
  platformRef:
    name: clawhive
  members:
    - templateRef:
        name: code-reviewer
      role: reviewer
      instanceName: reviewer-1
    - templateRef:
        name: code-reviewer
      role: reviewer
      instanceName: reviewer-2
    - templateRef:
        name: code-author
      role: author
      instanceName: author-1
  defaultChannels:
    - general
    - reviews
status:
  phase: Active
  readyMembers: 3
  totalMembers: 3
```

### Agent (Auto-created)

Running agent instance. Automatically created by AgentGroup Controller—users never create this directly.

```yaml
apiVersion: clawhive.io/v1alpha1
kind: Agent
metadata:
  name: review-team-reviewer-1
  ownerReferences:
    - apiVersion: clawhive.io/v1alpha1
      kind: AgentGroup
      name: review-team
spec:
  templateRef:
    name: code-reviewer
  role: reviewer
status:
  phase: Running              # Pending | Running | Failed | CrashLoopBackOff
  podName: review-team-reviewer-1-xyz
  conditions:
    - type: Ready
      status: "True"
    - type: LLMConnected
      status: "True"
  subscribedChannels:
    - review-team/general
    - review-team/reviews
```

## Kubernetes-Native Commands

The ClawHive CLI includes Kubernetes-aware commands for resource management:

### `clawhive apply`

Deploy resources from YAML files. Automatically creates a K8s Secret from `.env` files if present:

```bash
# Apply resources and create Secret from .env
clawhive apply -f config.yaml
clawhive apply -f myconfig/    # auto-detects .env
```

### `clawhive get`

Query cluster resources:

```bash
clawhive get agents                 # List all agents
clawhive get agents -o wide         # Wide output
clawhive get agentgroups            # List groups
clawhive get platforms              # List platforms
clawhive get llmproviders           # List LLM providers
clawhive get skills                 # List skills
```

### `clawhive delete`

Delete resources:

```bash
clawhive delete agent my-agent
clawhive delete agentgroup review-team
clawhive delete platform clawhive
```

### `clawhive logs`

Stream pod logs:

```bash
clawhive logs reviewer-1            # Stream logs from pod
clawhive logs reviewer-1 --tail 50  # Last 50 lines
```

### `clawhive health`

Health check probe (used in Pod livenessProbe/readinessProbe):

```bash
clawhive health                     # Check if agent is ready
clawhive health --ready             # Deep readiness check
```

### `clawhive operator`

Start the controller-manager to reconcile CRDs:

```bash
clawhive operator                   # Run with defaults
clawhive operator --metrics-addr :8080
```

## Agent Lifecycle

When you create an AgentGroup, the operator manages the complete lifecycle:

```
User creates AgentGroup
        │
        ▼
AgentGroup Controller watches & creates Agent CRs
        │
        ▼
Agent Controller resolves all references (LLMProvider, Skills, etc.)
        │
        ├─ Any missing? → status.phase = Failed
        └─ All valid? → create ConfigMap + Pod
        │
        ▼
Pod starts, mounts ConfigMap with agent config
        │
        ▼
readinessProbe passes → Agent status.phase = Running
        │
        ▼
clawhive chat <name> auto-detects K8s → SPDY exec to Pod
```

### Pod Structure

Each Agent Pod includes:

- **ConfigMap volumes**: Agent configuration, skills content
- **emptyDir volume**: Ephemeral memory storage
- **Environment variables**: API keys, LLM settings, MQTT broker endpoint
- **Probes**: livenessProbe and readinessProbe execute `clawhive health`

### Resource Requests

Define CPU and memory in AgentTemplate:

```yaml
spec:
  sandbox:
    resources:
      requests:
        memory: 256Mi
        cpu: 200m
      limits:
        memory: 512Mi
        cpu: 500m
```

## Operator Development

Build and develop the operator locally:

```bash
# Build operator binary
make build

# Build operator Docker image
make docker-build

# Load image into kind cluster
make kind-load

# Install CRDs
make install

# Run operator locally (for debugging)
make run
```

For end-to-end testing with kind:

```bash
make test-e2e
```

## Configuration Examples

See the [`config/samples/`](https://github.com/clawhive/clawhive/tree/main/config/samples) directory for all example configurations. Key files:

- `full-stack.yaml` - Complete example with Platform, LLMProvider, AgentTemplate, AgentGroup
- `clawhive_v1alpha1_llmprovider.yaml` - LLMProvider example
- `clawhive_v1alpha1_agenttemplate.yaml` - AgentTemplate example
- `clawhive_v1alpha1_agentgroup.yaml` - AgentGroup example

See [Examples](../examples/) for detailed walkthroughs.
