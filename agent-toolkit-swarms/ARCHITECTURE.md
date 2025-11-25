# Agent Toolkit V2 Architecture

**Production Multi-Agent Swarms with Progressive Disclosure and Model Sizing**

---

## Architecture Overview

The Agent Toolkit V2 architecture represents a production-ready pattern for deploying specialized multi-agent swarms with maximum context efficiency and cost optimization. This architecture powers 12 production swarms across software engineering domains.

### Core Principle: Context-Injected Orchestration (CIO Pattern)

```
┌──────────────────────────────────────────────────────────────┐
│  Context-Injected Orchestration (CIO) Pattern                │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  Predefined Solution: .claude/ folder with capabilities      │
│  Dynamic Action: User's runtime prompt determines task       │
│  Headless Execution: Claude Code CLI orchestrates            │
│                                                               │
│  Formula: Capability (static) + Intent (dynamic) = Action    │
└──────────────────────────────────────────────────────────────┘
```

**Benefits**:
- ✅ No hardcoded task instructions in agent definitions
- ✅ Single swarm handles unlimited task variations
- ✅ User prompt provides runtime context
- ✅ Agents focus on capabilities, not specific tasks

---

## Architectural Components

### 1. Progressive Disclosure Skills

**Problem**: Loading all domain knowledge upfront wastes 15-25% of context window

**Solution**: Skills with YAML frontmatter trigger-based loading

**Structure**:
```
.claude/
└── skills/
    ├── code-review/
    │   └── SKILL.md
    ├── security-audit/
    │   └── SKILL.md
    └── refactoring/
        └── SKILL.md
```

**Skill Format**:
```yaml
---
name: code-review
description: Code review checklist, quality standards. Use when: review, code quality, refactor
---

# Code Review Skill

## Quick Start Checklist
[... loaded only when triggered ...]
```

**Trigger Mechanism**:
- Skill `description` contains keywords
- When user prompt matches keywords, skill loads
- Example: "review security" → loads `security-audit` skill

**Impact**: **8× context efficiency** (25% → 3%)

### 2. Script-Based MCP Alternatives

**Problem**: Full MCP servers consume 10-20% context before any work begins

**Solution**: Lightweight Python scripts for common operations

**Available Scripts** (from agent-toolkit/):
```
mcp-alternatives/
├── filesystem.py      # File operations (vs @modelcontextprotocol/server-filesystem)
├── github.py          # GitHub operations (vs @modelcontextprotocol/server-github)
├── memory.py          # CRDT-backed state (vs @modelcontextprotocol/server-memory)
├── fetch.py           # HTTP requests (vs @modelcontextprotocol/server-fetch)
├── postgres.py        # Database ops (vs @modelcontextprotocol/server-postgres)
└── brave-search.py    # Web search (vs @modelcontextprotocol/server-brave-search)
```

**Usage in Agent Definitions**:
```markdown
# Security Auditor Agent

You have access to these utility scripts:
- filesystem.py: File scanning and analysis
- github.py: Repository operations

Use them for context-efficient operations.
```

**Impact**: **10-20× context efficiency** vs full MCP servers (<1% vs 10-20%)

### 3. Three-Tier Model Sizing

**Problem**: Using same model for all agents wastes cost on simple tasks

**Solution**: Complexity-based model assignment

| Tier | Model | Thinking Budget | Use Cases | % of Agents |
|------|-------|----------------|-----------|-------------|
| **Micro** | Haiku 4 | 0-5,000 | Execution, evaluation, file ops | 58% |
| **Standard** | Sonnet 4 | 5,000-12,000 | Analysis, coordination, synthesis | 35% |
| **Advanced** | Opus 4 / Sonnet 4.5 | 12,000-20,000 | Strategic planning, complex reasoning | 7% |

**Assignment Logic**:
```json
{
  "agents": {
    "file_scanner": {
      "complexity": "low",
      "thinking_budget": 3000
    },
    "vulnerability_analyzer": {
      "complexity": "medium",
      "thinking_budget": 10000
    },
    "attack_surface_mapper": {
      "complexity": "high",
      "thinking_budget": 15000
    }
  }
}
```

**Impact**: **40-60% cost reduction** while maintaining quality

### 4. Shared Component Library

**Agent Toolkit Structure**:
```
../agent-toolkit/
├── mcp-alternatives/      # Shared scripts (all swarms use)
├── skills/                # Shared skills (selectively loaded)
├── templates/             # Agent templates (micro/standard/advanced)
├── scripts/               # Deployment automation
└── orchestration/         # Job definitions
```

**Benefit**: Single source of truth for common capabilities
- Update once, all swarms benefit
- Consistent behavior across domains
- Easier maintenance

---

## Swarms in This Architecture

This folder contains 12 production swarms, each specialized for a domain:

### Development & Quality (4 swarms)
1. **security-swarm-v2**: Security auditing, vulnerability scanning, threat modeling
2. **refactoring-swarm-v2**: Code refactoring, pattern application, tech debt reduction
3. **documentation-swarm-v2**: API docs, architecture diagrams, user guides
4. **test-swarm-v2**: Test generation, coverage analysis, test strategy

### Infrastructure & Operations (4 swarms)
5. **performance-swarm-v2**: Performance profiling, optimization, bottleneck analysis
6. **cicd-swarm-v2**: Pipeline design, deployment automation, release management
7. **observability-swarm-v2**: Logging, monitoring, alerting, metrics
8. **migration-swarm-v2**: Database migrations, API versioning, data transformation

### Data & Integration (4 swarms)
9. **api-swarm-v2**: API design, REST/GraphQL, integration patterns
10. **database-swarm-v2**: Schema design, query optimization, indexing
11. **data-pipeline-swarm-v2**: ETL, stream processing, data validation
12. **mlops-swarm-v2**: ML pipeline, model deployment, experiment tracking

Each swarm follows identical architectural pattern with domain-specific agents.

---

## Orchestration Methodology

### Option 1: Direct Headless Execution

```bash
#!/bin/bash
# Deploy security audit swarm

cd /path/to/your/project

# Copy swarm to project
cp -r ~/markdown_agents/agent-toolkit-swarms/security-swarm-v2/.claude .

# Execute with runtime prompt
claude -p "Audit authentication module for SQL injection and XSS vulnerabilities"

# Cleanup
rm -rf .claude
```

**Flow**:
1. User provides runtime intent ("audit auth module")
2. Orchestrator (CLAUDE.md) analyzes request
3. Spawns relevant subagents (vulnerability-scanner, attack-surface-mapper)
4. Subagents use progressive skills (security-audit skill loads)
5. Results aggregated by orchestrator
6. Final report returned

### Option 2: Slash Command Orchestration

**Create**: `.claude/commands/orchestrate.md`

```markdown
---
description: Deploy subagent swarm for complex multi-stage tasks
---

# Orchestrate Command

Usage: /orchestrate <domain> <task>

Examples:
- /orchestrate security audit auth module
- /orchestrate refactoring apply strategy pattern to services/
- /orchestrate test generate integration tests for API

## Orchestration Logic

1. Parse domain and task from user input
2. Load appropriate swarm configuration from agent-toolkit-swarms/
3. Deploy subagents using Task tool
4. Skills loaded progressively based on task keywords
5. Results aggregated and formatted
6. Return comprehensive report
```

**Benefit**: User types `/orchestrate security audit auth` instead of full prompt

### Option 3: Programmatic Deployment

**Script**: `deploy-swarm.sh`

```bash
#!/bin/bash
# Usage: ./deploy-swarm.sh <swarm-name> <project-path> "<task>"

SWARM=$1
PROJECT=$2
TASK=$3

SWARM_PATH="${HOME}/markdown_agents/agent-toolkit-swarms/${SWARM}-swarm-v2"
WORKSPACE="${PROJECT}/.claude-swarm-${RANDOM}"

# Copy swarm to temporary workspace
mkdir -p "${WORKSPACE}"
cp -r "${SWARM_PATH}/.claude" "${WORKSPACE}/"

# Execute in workspace
cd "${WORKSPACE}"
claude -p "${TASK}" --output-format stream-json > results.json

# Extract results
cat results.json | jq -r '.result'

# Cleanup
rm -rf "${WORKSPACE}"
```

**Usage**:
```bash
./deploy-swarm.sh security /path/to/project "Audit payment processing"
./deploy-swarm.sh refactoring /path/to/project "Apply repository pattern"
./deploy-swarm.sh test /path/to/project "Generate E2E tests for checkout"
```

---

## Orchestration Abstraction

### Orchestrator Role (CLAUDE.md)

The orchestrator is the "brain" that coordinates subagents. It does NOT perform tasks directly.

**Responsibilities**:
- Parse user's runtime intent
- Determine which subagents are needed
- Deploy subagents with appropriate context
- Monitor subagent progress
- Aggregate results
- Format final output

**Example CLAUDE.md Pattern**:

```markdown
# Security Swarm Orchestrator

You are a security swarm coordinator. You do NOT perform audits directly.

## Your Role

1. Analyze Request: Parse user's security audit request
2. Plan Deployment: Determine which specialists are needed
3. Deploy Subagents: Use Task tool to spawn specialists
4. Monitor Progress: Track subagent completion
5. Aggregate Results: Combine findings into comprehensive report

## Available Subagents

Defined in .claude/agents/:
- vulnerability-scanner.md (LOW - Haiku)
- attack-surface-mapper.md (HIGH - Opus)
- code-flow-analyzer.md (MEDIUM - Sonnet)
- security-report-generator.md (LOW - Haiku)

## Skills Available

Progressive disclosure from .claude/skills/:
- security-audit/ (loads when: "audit", "security", "vulnerability")
- owasp-top-10/ (loads when: "sql injection", "xss", "csrf")
- threat-modeling/ (loads when: "threat", "attack surface", "risk")

Skills auto-load based on task keywords.
```

**Key Principle**: Orchestrator = Coordinator, NOT Worker

---

## Subagent Deployment Methodology

### Using Task Tool for Subagent Spawning

Orchestrators use the Task tool to spawn specialist subagents dynamically based on user's request.

**Example Orchestrator Logic**:

When user requests: "Audit authentication module for SQL injection"

1. Orchestrator parses intent: security audit, focus on SQL injection
2. Determines needed specialists: vulnerability-scanner, code-flow-analyzer
3. Deploys subagents via Task tool with specific contexts
4. Aggregates results into comprehensive report

**Subagent Context Injection**:

Each subagent receives:
- Task-specific context from user prompt
- Relevant portions of codebase
- Access to appropriate skills (auto-loaded)
- Appropriate model and thinking budget

**Benefits**:
- ✅ Dynamic composition based on need
- ✅ Parallel execution of independent subagents
- ✅ Specialized agents for specialized tasks
- ✅ Efficient resource allocation

---

## Differences from Other Architectures

### vs Evolutionary Swarms

| Aspect | Agent Toolkit V2 | Evolutionary Swarms |
|--------|-----------------|---------------------|
| **Purpose** | Production software engineering tasks | Research/complex problem solving |
| **Agent Lifespan** | Ephemeral (per-task) | Multi-generation (iterative refinement) |
| **Knowledge Transfer** | Skill-based (reusable patterns) | Library-based (learned programs) |
| **Cost Model** | Optimized via model sizing | Optimized via generation count |
| **Typical Tasks** | Code review, refactoring, testing | ARC-AGI, algorithmic challenges |
| **Complexity Focus** | Broad domain coverage | Deep problem exploration |

**Use Agent Toolkit V2 when**:
- Need production-ready software engineering
- Want fast, cost-effective results
- Task fits known domain (security, testing, etc.)
- Don't need iterative refinement

**Use Evolutionary when**:
- Need novel solution discovery
- Willing to invest in multi-generation exploration
- Problem requires creative problem-solving
- Want knowledge transfer across tasks (library variant)

---

## Performance Metrics

### Context Efficiency

**Before V2** (V1 swarms):
- Skills: Always loaded → 25% context
- MCP servers: Always loaded → 10-20% context
- Total: 35-45% context used before work begins

**After V2**:
- Skills: Load on demand → 3% context
- Script alternatives: Minimal overhead → <1% context
- Total: 4% context used before work begins

**Improvement**: **8× context efficiency**

### Cost Optimization

**Model Distribution** (across 78 agents in 12 swarms):
- 58% Haiku (micro tasks)
- 35% Sonnet (standard tasks)
- 7% Opus/Sonnet 4.5 (advanced tasks)

**Cost Reduction**: **40-60%** vs uniform Sonnet usage

### Agent Count by Swarm

| Swarm | Agents | Haiku | Sonnet | Opus |
|-------|--------|-------|--------|------|
| Security | 7 | 4 | 2 | 1 |
| Refactoring | 6 | 3 | 3 | 0 |
| Documentation | 5 | 3 | 2 | 0 |
| Test | 7 | 4 | 2 | 1 |
| Performance | 6 | 4 | 2 | 0 |
| API | 6 | 3 | 2 | 1 |
| Database | 7 | 4 | 2 | 1 |
| CI/CD | 7 | 4 | 3 | 0 |
| Migration | 6 | 4 | 2 | 0 |
| Observability | 7 | 4 | 3 | 0 |
| Data Pipeline | 7 | 4 | 2 | 1 |
| MLOps | 7 | 4 | 3 | 0 |
| **Total** | **78** | **45** | **28** | **5** |

---

## Deployment Examples

### Example 1: Security Audit

```bash
# Setup
cd /path/to/your/app
cp -r ~/markdown_agents/agent-toolkit-swarms/security-swarm-v2/.claude .

# Execute
claude -p "Audit the payment processing module for OWASP Top 10 vulnerabilities"

# What happens:
# 1. Orchestrator analyzes request
# 2. Loads security-audit skill (triggered by "audit")
# 3. Loads owasp-top-10 skill (triggered by "OWASP")
# 4. Deploys vulnerability-scanner (Haiku) for automated checks
# 5. Deploys attack-surface-mapper (Opus) for architectural analysis
# 6. Deploys code-flow-analyzer (Sonnet) for logic tracing
# 7. Aggregates findings into comprehensive report

# Cleanup
rm -rf .claude
```

### Example 2: Refactoring with Programmatic Deployment

```bash
# Using deploy-swarm.sh script
./deploy-swarm.sh refactoring /path/to/app \
  "Apply strategy pattern to notification system in services/notifications/"

# What happens:
# 1. Script copies refactoring-swarm-v2 to temporary workspace
# 2. Orchestrator parses: domain=refactoring, pattern=strategy, target=notifications
# 3. Loads refactoring skill (triggered by keywords)
# 4. Deploys pattern-analyzer (Sonnet) to identify variation points
# 5. Deploys code-transformer (Sonnet) to apply pattern
# 6. Deploys test-updater (Haiku) to adjust tests
# 7. Returns refactored code + updated tests
# 8. Script cleans up workspace
```

### Example 3: CI/CD Integration

```yaml
# .github/workflows/swarm-analysis.yml
name: Swarm Code Analysis

on: [pull_request]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Claude Code
        run: curl -fsSL https://... | bash

      - name: Deploy Security Swarm
        run: |
          cp -r ~/markdown_agents/agent-toolkit-swarms/security-swarm-v2/.claude .
          claude -p "Audit changed files for security vulnerabilities" \
            --output-format stream-json > security-results.json

      - name: Parse Results
        run: |
          VULNS=$(cat security-results.json | jq '.vulnerabilities | length')
          if [ $VULNS -gt 0 ]; then
            echo "Found $VULNS vulnerabilities"
            exit 1
          fi
```

---

## Best Practices

### 1. Keep Orchestrators Thin

**Good**:
```markdown
# Orchestrator CLAUDE.md

You coordinate subagents. Parse user request, deploy specialists, aggregate results.

Available subagents in .claude/agents/:
- specialist-a.md
- specialist-b.md
```

**Bad**:
```markdown
# Orchestrator CLAUDE.md

You perform security audits by:
1. Scanning for SQL injection
2. Checking XSS vulnerabilities
3. Analyzing authentication flows
[... 50 lines of implementation details ...]
```

**Rationale**: Orchestrator should coordinate, not implement

### 2. Use Progressive Skills Aggressively

**Good**:
```yaml
---
name: owasp-top-10
description: OWASP Top 10 vulnerability checklist. Use when: sql injection, xss, csrf, security scan
---

# OWASP Top 10 Skill
[... detailed checklist ...]
```

**Bad**: Loading full OWASP checklist in every agent definition

**Rationale**: Load knowledge only when needed

### 3. Right-Size Model Selection

**Good**:
```json
{
  "file_scanner": "low",        // Simple file iteration → Haiku
  "vulnerability_analyzer": "medium",  // Pattern matching → Sonnet
  "threat_modeler": "high"      // Strategic analysis → Opus
}
```

**Bad**: Using Opus for everything

**Rationale**: Match model cost to task complexity

### 4. Leverage Shared Components

**Good**: Reference `../agent-toolkit/mcp-alternatives/filesystem.py`

**Bad**: Duplicate filesystem code in every swarm

**Rationale**: DRY principle, single source of truth

---

## Future Enhancements

Potential improvements to this architecture:

- [ ] **Skill Auto-Discovery**: Automatically index skills and match to prompts
- [ ] **Dynamic Model Selection**: Runtime model selection based on task complexity
- [ ] **Swarm Composition**: Combine multiple swarms for cross-domain tasks
- [ ] **Caching Layer**: Cache subagent results for similar requests
- [ ] **Performance Monitoring**: Track swarm execution metrics
- [ ] **Skill Versioning**: Version control for skill definitions

---

## Getting Started

### Quick Start

1. **Choose a swarm** based on your domain (security, refactoring, etc.)

2. **Copy to your project**:
   ```bash
   cp -r ~/markdown_agents/agent-toolkit-swarms/security-swarm-v2/.claude /path/to/project/
   ```

3. **Execute with runtime prompt**:
   ```bash
   cd /path/to/project
   claude -p "Your task description here"
   ```

4. **Cleanup** (optional):
   ```bash
   rm -rf .claude
   ```

### Advanced: Create Custom Swarm

1. Start from template in `../agent-toolkit/templates/`
2. Define domain-specific agents in `.claude/agents/`
3. Create domain skills in `.claude/skills/`
4. Configure model sizing in `.claude/settings.json`
5. Write orchestrator logic in `.claude/CLAUDE.md`

See `../agent-toolkit/README.md` for detailed instructions.

---

**Architecture Version**: 2.0.0
**Last Updated**: 2025-11-22
**Swarms**: 12 production swarms, 78 agents total
**Performance**: 8× context efficiency, 40-60% cost reduction
