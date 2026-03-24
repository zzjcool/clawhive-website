---
title: "Configuration"
linkTitle: "Configuration"
weight: 4
description: "How to configure ClawHive agents and platforms"
---

## Configuration Modes

ClawHive supports two operational modes:

### 1. Docker Mode (Legacy)

Run agents locally or in Docker containers with imperative CLI commands. Configuration uses YAML files.

### 2. Kubernetes Mode (Current)

Declarative resource management using Kubernetes CRDs. Recommended for production and multi-agent scenarios.

## Kubernetes Configuration (Recommended)

When running on Kubernetes, all resources are declarative CRs. See the [Kubernetes](../kubernetes/) documentation for detailed examples.

### LLMProvider

```yaml
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
```

### AgentTemplate

```yaml
apiVersion: clawhive.io/v1alpha1
kind: AgentTemplate
metadata:
  name: my-agent
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
    system: "You are a helpful assistant"
  skillRefs:
    - name: web-search
```

### AgentGroup

```yaml
apiVersion: clawhive.io/v1alpha1
kind: AgentGroup
metadata:
  name: my-group
spec:
  platformRef:
    name: clawhive
  members:
    - templateRef:
        name: my-agent
      role: assistant
```

See [Kubernetes documentation](../kubernetes/#crd-reference) for complete CRD specifications.

## Docker Configuration (Local Development)

For local development without Kubernetes, you can use the traditional Docker-based configuration:

### Agent YAML

```yaml
apiVersion: clawhive/v1
kind: Agent
metadata:
  name: my-agent
  description: "Local test agent"
spec:
  sandbox:
    image: debian:bookworm-slim
    workdir: /workspace

  llm:
    provider: openai
    model: ${LLM_MODEL}
    apiKey: ${API_KEY}
    baseURL: ${API_BASE_URL}  # Optional

  soul:
    system: "You are a helpful assistant."
    traits: [helpful, concise]

  memory:
    backend: filesystem
    config:
      path: ./data/agent/memory

  skills:
    - name: web-search
      path: ./skills/search.md

  cron:
    - name: daily-summary
      schedule: "0 8 * * *"
      prompt: "Generate daily summary"

  notify:
    defaults: [terminal]
    transports:
      - name: terminal
        type: terminal
```

Run with:

```bash
clawhive run my-agent/
clawhive run --local my-agent/  # Local (no Docker)
```

## Environment Variables

Both Kubernetes and Docker modes support environment variable substitution. Variables are loaded from:

1. System environment
2. `.env` file in the working directory
3. `.env` file in the config directory

### Common Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `API_KEY` | LLM provider API key | `sk-...` |
| `API_BASE_URL` | LLM API endpoint | `https://api.openai.com/v1` |
| `LLM_MODEL` | Model name | `gpt-4` |
| `MQTT_BROKER` | MQTT endpoint (K8s auto-set) | `mqtt:1883` |

## Agent Package Structure

When using Docker mode, organize agents in packages:

```
my-agent/
├── package.yaml       # Package metadata
├── agent.yaml         # Agent configuration
└── skills/            # Skill definitions
    ├── search.md
    └── analysis.md
```

### package.yaml

```yaml
apiVersion: clawhive/v1
kind: Package
metadata:
  name: my-agent-pkg
  version: "1.0.0"
spec:
  description: "My agent package"
  agentRef:
    path: agent.yaml
```

### Skills

Skills are markdown files that extend the agent's capabilities:

```markdown
# Web Search

You can search the web for information using the `web_search` tool.

## Usage

When asked to search for something, use the tool:

\`\`\`
web_search(query: "your search query")
\`\`\`
```

Reference skills in your agent config:

```yaml
spec:
  skills:
    - name: web-search
      path: ./skills/search.md
```

## Secrets Management

### Kubernetes Mode

Use K8s Secrets for sensitive data:

```bash
kubectl create secret generic llm-secrets \
  --from-literal=api-key=$API_KEY
```

Reference in CRs:

```yaml
spec:
  secretRef:
    name: llm-secrets
    key: api-key
```

Or use `clawhive apply` with `.env` files (auto-creates Secret).

### Docker Mode

Use `.env` files or environment variables:

```bash
export API_KEY=sk-...
clawhive run my-agent/
```

**Do not commit `.env` files to version control.**

### Running a Platform

```bash
clawhive platform run ./config/platform.yaml
```

## AgentGroup Configuration

An **AgentGroup** organizes multiple agents that communicate through channels using the A2A protocol.

```yaml
apiVersion: clawhive/v1
kind: AgentGroup
metadata:
  name: code-review-team
  labels:
    domain: engineering
spec:
  description: "A team of agents collaborating on code review"
  version: "1.0.0"
  members:
    - agentId: alpha
      role: reviewer
      description: "Senior code reviewer, focuses on architecture and design patterns"
    - agentId: beta
      role: developer
      description: "Backend developer responsible for auth and user management"
    - agentId: gamma
      role: tester
      description: "QA specialist focusing on integration tests and edge cases"
  communication:
    transport: mqtt
    config:
      broker:
        host: localhost
        port: 1883
    defaultChannel:
      enabled: true
      name: code-review-team
    dynamicChannels: true
```

### AgentGroup Fields

| Field | Description |
|-------|-------------|
| `metadata.name` | Group name (unique identifier) |
| `metadata.labels` | Key-value labels for grouping and discovery |
| `spec.description` | Human-readable description of the group |
| `spec.version` | Group configuration version |
| `spec.members` | List of agent members with IDs, roles, and descriptions |
| `spec.members[].agentId` | References an agent by its ID |
| `spec.members[].role` | Role of the agent within the group |
| `spec.communication.transport` | Transport protocol (`mqtt`) |
| `spec.communication.config.broker` | MQTT broker connection settings |
| `spec.communication.defaultChannel` | Default channel for group communication |
| `spec.communication.dynamicChannels` | Whether agents can create channels dynamically |

## Environment Variables

ClawHive supports `${ENV_VAR}` syntax in configuration values. Environment variables are loaded from:

- `.env` file in the working directory
- `.env` file in the config directory
- System environment variables

| Variable | Purpose |
|----------|---------|
| `API_KEY` | LLM provider API key |
| `API_BASE_URL` | Custom API base URL (OpenRouter, etc.) |
| `LLM_MODEL` | Model name to use |

## Package Manifest

Each agent package requires a `package.yaml` manifest:

```yaml
apiVersion: clawhive/v1
kind: Package
metadata:
  name: my-agent
  version: "1.0.0"
  description: "A sample agent package"
agent: agent.yaml
```

| Field | Description |
|-------|-------------|
| `apiVersion` | API version, always `clawhive/v1` |
| `kind` | Resource type, always `Package` |
| `metadata.name` | Package name |
| `metadata.version` | Package version (semver) |
| `metadata.description` | Human-readable description |
| `agent` | Path to the agent configuration file (relative to the package directory) |

## Validation

Use the `validate` command to check your configuration:

```bash
clawhive validate ./my-agent/
```
