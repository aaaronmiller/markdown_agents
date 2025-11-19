# Agent Toolkit - Dynamic Multi-Agent Assembly Framework

**Version 1.0.0** | Production-Ready Meta-Orchestration System

## Overview

The Agent Toolkit is a meta-framework for dynamically assembling custom agents with precise tool palettes, skills, and configurations based on job requirements. It provides script-based alternatives to common MCP servers and a methodology for toolkit-based agent deployment.

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│         META-ORCHESTRATOR (Agent Assembly Engine)             │
│  Input: Job Requirements → Output: Custom Agent Configuration │
└────────────┬─────────────────────────────────────────────────┘
             │
     ┌───────┴────────┬──────────────┬──────────────┬────────────┐
     ↓                ↓              ↓              ↓            ↓
┌─────────┐    ┌──────────┐   ┌──────────┐   ┌──────────┐  ┌──────────┐
│ Script- │    │  Skills  │   │Templates │   │  Model   │  │  Agent   │
│  Based  │    │Framework │   │  System  │   │Selector  │  │Assembler │
│   MCP   │    │          │   │          │   │          │  │          │
└─────────┘    └──────────┘   └──────────┘   └──────────┘  └──────────┘
```

## Key Components

### 1. Script-Based MCP Alternatives

Lightweight, context-efficient alternatives to common MCP servers:
- **filesystem** - File operations
- **github** - GitHub integration
- **postgres** - Database operations
- **brave-search** - Web search
- **puppeteer** - Browser automation
- **slack** - Team communication
- **google-drive** - Cloud storage
- **memory** - Persistent state
- **fetch** - HTTP requests
- **gitlab** - GitLab operations

### 2. Skills Framework

Progressive disclosure system for domain expertise:
- Code analysis skills
- Testing skills
- Documentation skills
- Security skills
- Performance skills
- Data processing skills

### 3. Agent Templates

Pre-configured agent blueprints:
- **Micro** (Haiku) - Fast, focused tasks
- **Standard** (Sonnet) - Balanced general-purpose
- **Advanced** (Opus) - Complex reasoning tasks

### 4. Toolkit-Based Assembly

Dynamic agent construction using:
- Job type definitions
- Tool palette selection
- Skill bundling
- Model sizing
- Thinking budget allocation

## Quick Start

### Assemble a Custom Agent

```bash
# Basic assembly
python agent-toolkit/scripts/assemble-agent.py \
  --job-type backend-api \
  --tools filesystem,github,postgres \
  --skills api-patterns,database-optimization \
  --model sonnet \
  --output .claude/agents/backend-specialist.md

# Advanced assembly with thinking budget
python agent-toolkit/scripts/assemble-agent.py \
  --job-type ml-ops \
  --tools filesystem,github,memory \
  --skills mlops,data-processing \
  --model opus \
  --thinking-budget 15000 \
  --output .claude/agents/mlops-specialist.md
```

### Deploy an Orchestration System

```bash
# Create orchestrated swarm
python agent-toolkit/scripts/deploy-swarm.py \
  --swarm-type refactoring \
  --agents code-analyzer,smell-detector,executor \
  --orchestrator-model sonnet \
  --agent-model haiku \
  --output refactoring-swarm/
```

## Usage Patterns

### Pattern 1: Single Agent Assembly

Assemble one specialized agent for a specific task.

```bash
python scripts/assemble-agent.py \
  --template standard \
  --tools filesystem,github \
  --skills code-review \
  --name code-reviewer
```

### Pattern 2: Swarm Orchestration

Assemble multiple agents with a coordinating orchestrator.

```bash
python scripts/deploy-swarm.py \
  --swarm-type custom \
  --agents agent1.yaml,agent2.yaml,agent3.yaml \
  --orchestrator orchestrator.yaml
```

### Pattern 3: Job-Based Assembly

Automatically select tools and skills based on job type.

```bash
python scripts/assemble-from-job.py \
  --job security-audit \
  --complexity high
```

## Agent Assembly Methodology

### Step 1: Define Job Requirements

```yaml
# job-definitions/backend-api.yaml
job_type: backend-api
description: Backend API development and maintenance
tools:
  required:
    - filesystem
    - github
    - postgres
  optional:
    - slack
    - memory
skills:
  required:
    - api-patterns
    - database-optimization
  optional:
    - testing-strategies
model_recommendation: sonnet
thinking_budget: 12000
```

### Step 2: Assemble Agent Configuration

The assembly script generates:
1. Agent definition (`agents/[name].md`)
2. Skills bundle (`skills/[job-type]/`)
3. MCP alternatives (`scripts/mcp-[tool].py`)
4. Settings configuration (`settings.json` fragment)
5. Hooks (if needed)

### Step 3: Deploy to Swarm

The orchestrator integrates the agent:
1. Loads agent definition
2. Activates skills
3. Configures tool access
4. Sets model and thinking budget
5. Registers with orchestration CLAUDE.md

## Model Sizing Strategy

### Haiku (Micro Agents)

**Use for:**
- Fast, focused tasks
- Simple validation
- File operations
- Quick searches

**Characteristics:**
- Low cost
- Fast response
- Limited context (200K)
- Thinking budget: 0-5000

### Sonnet (Standard Agents)

**Use for:**
- General-purpose tasks
- Code generation
- Analysis and review
- Orchestration

**Characteristics:**
- Balanced cost/performance
- Good reasoning
- Full context (200K)
- Thinking budget: 5000-12000

### Opus (Advanced Agents)

**Use for:**
- Complex reasoning
- Architecture design
- Research synthesis
- Strategic planning

**Characteristics:**
- Higher cost
- Best reasoning
- Full context (200K)
- Thinking budget: 12000-20000

## Thinking Budget Guidelines

| Task Complexity | Budget | Model |
|---|---|---|
| Simple operations | 0-2000 | Haiku |
| Standard tasks | 2000-5000 | Haiku/Sonnet |
| Complex analysis | 5000-10000 | Sonnet |
| Deep reasoning | 10000-15000 | Sonnet/Opus |
| Strategic planning | 15000-20000 | Opus |

## Directory Structure

```
agent-toolkit/
├── README.md                         # This file
├── scripts/
│   ├── assemble-agent.py            # Agent assembly script
│   ├── deploy-swarm.py              # Swarm deployment script
│   ├── assemble-from-job.py         # Job-based assembly
│   └── validate-config.py           # Configuration validator
├── mcp-alternatives/
│   ├── README.md                     # MCP alternatives guide
│   ├── filesystem.py                 # File operations
│   ├── github.py                     # GitHub integration
│   ├── postgres.py                   # Database operations
│   ├── brave-search.py               # Web search
│   ├── puppeteer.py                  # Browser automation
│   ├── slack.py                      # Slack integration
│   ├── google-drive.py               # Google Drive access
│   ├── memory.py                     # Persistent memory
│   ├── fetch.py                      # HTTP requests
│   └── gitlab.py                     # GitLab operations
├── skills/
│   ├── README.md                     # Skills framework guide
│   ├── api-patterns/
│   │   └── SKILL.md
│   ├── database-optimization/
│   │   └── SKILL.md
│   ├── testing-strategies/
│   │   └── SKILL.md
│   ├── code-review/
│   │   └── SKILL.md
│   ├── security-audit/
│   │   └── SKILL.md
│   ├── performance-profiling/
│   │   └── SKILL.md
│   ├── data-processing/
│   │   └── SKILL.md
│   └── mlops/
│       └── SKILL.md
├── templates/
│   ├── agent-micro.yaml              # Haiku agent template
│   ├── agent-standard.yaml           # Sonnet agent template
│   ├── agent-advanced.yaml           # Opus agent template
│   ├── orchestrator.yaml             # Orchestrator template
│   └── swarm-config.yaml             # Swarm configuration template
├── orchestration/
│   ├── ORCHESTRATOR.md               # Meta-orchestrator prompt
│   ├── job-definitions/              # Job type definitions
│   │   ├── backend-api.yaml
│   │   ├── frontend-ui.yaml
│   │   ├── data-pipeline.yaml
│   │   ├── ml-ops.yaml
│   │   ├── security-audit.yaml
│   │   └── devops.yaml
│   └── assembly-rules.yaml           # Agent assembly rules
└── examples/
    ├── custom-agent/                 # Example custom agent
    ├── custom-swarm/                 # Example custom swarm
    └── job-based-deploy/             # Example job-based deployment
```

## Benefits

### Context Efficiency

- **Script-based MCPs**: <1% context vs. 10-20% for full MCP servers
- **Progressive disclosure**: Skills load only when needed
- **Modular assembly**: Only necessary components loaded

### Flexibility

- **Dynamic composition**: Assemble agents for specific tasks
- **Tool selection**: Precise tool palette per agent
- **Model optimization**: Right-size model for task complexity

### Maintainability

- **Centralized toolkit**: Single source for agent components
- **Version control**: Track toolkit evolution
- **Reusability**: Components used across multiple agents

### Performance

- **Right-sized models**: Cost optimization
- **Thinking budgets**: Control inference depth
- **Parallel execution**: Independent agent operations

## Integration with Existing Swarms

All 12 existing swarm systems can be upgraded to use the Agent Toolkit:

```bash
# Upgrade existing swarm
python scripts/upgrade-swarm.py \
  --swarm refactoring-swarm \
  --enable-toolkit \
  --optimize-models
```

Upgrades include:
- Replace MCP servers with script alternatives
- Add skills framework
- Implement model sizing
- Configure thinking budgets
- Update orchestration logic

## Advanced Features

### Conditional Assembly

Assemble agents based on runtime conditions:

```python
from agent_toolkit import Assembler

assembler = Assembler()

if project_size > 100000:
    agent = assembler.assemble(model='opus', thinking_budget=20000)
elif project_complexity == 'high':
    agent = assembler.assemble(model='sonnet', thinking_budget=15000)
else:
    agent = assembler.assemble(model='haiku', thinking_budget=5000)
```

### Multi-Agent Coordination

Orchestrate multiple agents with different capabilities:

```yaml
# coordination.yaml
orchestrator:
  model: sonnet
  thinking_budget: 10000

agents:
  - name: analyzer
    model: haiku
    tools: [filesystem, github]
    skills: [code-analysis]

  - name: refactor
    model: sonnet
    tools: [filesystem, github]
    skills: [refactoring-patterns]

  - name: reviewer
    model: opus
    tools: [filesystem]
    skills: [code-review]
```

### Skill Composition

Combine multiple skills for complex domains:

```bash
python scripts/compose-skills.py \
  --base api-patterns \
  --add database-optimization \
  --add security-best-practices \
  --output api-security-skill/
```

## Testing and Validation

```bash
# Validate agent configuration
python scripts/validate-config.py \
  --config .claude/agents/my-agent.md

# Test agent assembly
python scripts/test-assembly.py \
  --job-type backend-api \
  --dry-run

# Verify swarm orchestration
python scripts/verify-swarm.py \
  --swarm refactoring-swarm
```

## Troubleshooting

### Agent Not Loading

Check:
1. Agent definition has valid YAML frontmatter
2. Required tools are available
3. Skills are correctly referenced
4. Model is supported

### Tool Not Found

Verify:
1. Script exists in `mcp-alternatives/`
2. Script is executable
3. Dependencies are installed
4. Path is correct in agent config

### Skill Not Activating

Ensure:
1. Skill directory has `SKILL.md`
2. Description includes trigger keywords
3. Skill is listed in agent configuration
4. Progressive disclosure is working

## Contributing

See `CONTRIBUTING.md` for guidelines on:
- Adding new MCP alternatives
- Creating skills
- Defining job types
- Extending templates

## License

MIT License - See LICENSE file

---

**Built for Claude Code v1.0+** | **Requires Python 3.8+**
