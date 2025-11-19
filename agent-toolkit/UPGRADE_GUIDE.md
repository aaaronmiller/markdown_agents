# Swarm Upgrade Guide - Agent Toolkit Integration

**Version 1.0.0** | Upgrading Existing Swarms to Agent Toolkit Architecture

## Overview

This guide explains how to upgrade existing swarm systems (Refactoring, Security, Documentation, Test, Performance, API, Database, CI/CD, Migration, Observability, Data Pipeline, MLOps) to use the new Agent Toolkit architecture with:

- Script-based MCP alternatives (context-efficient)
- Progressive disclosure skills framework
- Dynamic agent assembly
- Model sizing optimization
- Thinking budget allocation

## Benefits of Upgrading

### Context Efficiency

**Before**: MCP servers consume 10-20% context
**After**: Script alternatives consume <1% context

**Before**: All skills loaded at once
**After**: Progressive disclosure - only load when needed

### Flexibility

- Dynamic agent assembly based on task
- Right-sized models for subtasks
- Precise tool palette per agent
- Optimized thinking budgets

### Maintainability

- Centralized toolkit components
- Version-controlled agent definitions
- Reusable skills across swarms
- Consistent patterns

## Upgrade Process

### Step 1: Understand Current Architecture

Each swarm currently has:
```
[swarm-name]/
├── .claude/
│   ├── CLAUDE.md (orchestrator)
│   ├── settings.json
│   ├── agents/ (agent definitions)
│   ├── hooks/
│   └── scripts/
└── memory/
```

### Step 2: Map to Agent Toolkit

The upgrade maps existing components to toolkit equivalents:

| Current Component | Toolkit Equivalent | Notes |
|---|---|---|
| MCP servers | `mcp-alternatives/*.py` | Script-based |
| Agent definitions | Assembled via `assemble-agent.py` | Dynamic |
| Skills (implicit) | `skills/*/SKILL.md` | Explicit, progressive |
| Model (single) | Model sizing (per agent) | Optimized |
| Settings | Enhanced with thinking budgets | Per-agent config |

### Step 3: Create Skills Mapping

Identify domain knowledge in your swarm and map to skills:

**Example: Refactoring Swarm**

| Implicit Knowledge | Skill |
|---|---|
| Code smell patterns | `code-review` |
| Refactoring techniques | `code-review` |
| Testing validation | `testing-strategies` |

**Example: Security Swarm**

| Implicit Knowledge | Skill |
|---|---|
| OWASP Top 10 | `security-audit` |
| Vulnerability patterns | `security-audit` |
| Remediation strategies | `security-audit` |

### Step 4: Determine Model Sizing

Assign appropriate models to agents based on complexity:

**Haiku (Micro)**: Simple, fast operations
- File scanning
- Pattern detection
- Quick validation

**Sonnet (Standard)**: Balanced, general-purpose
- Code analysis
- Refactoring
- Test generation
- Orchestration

**Opus (Advanced)**: Complex reasoning
- Architecture analysis
- Strategic planning
- Research synthesis

### Step 5: Replace MCP Servers

Replace MCP server references with script alternatives:

**Before**:
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path"]
    }
  }
}
```

**After**:
```yaml
tools:
  - name: filesystem
    type: script
    path: agent-toolkit/mcp-alternatives/filesystem.py
```

### Step 6: Add Skills to Agents

**Before** (skills implicit in prompt):
```markdown
# Code Analyzer

Analyze code for complexity, smells, and refactoring opportunities.
Look for: long functions, duplicated code, tight coupling, etc.
```

**After** (skills explicit and loadable):
```yaml
---
name: code-analyzer
skills: [code-review]
---

# Code Analyzer

Load code review skill for analysis guidelines:
`cat agent-toolkit/skills/code-review/SKILL.md`
```

### Step 7: Update Orchestrator

Enhance orchestrator with toolkit integration:

**Add** to CLAUDE.md:
```markdown
## Agent Toolkit Integration

### Available Tools
- filesystem: `python agent-toolkit/mcp-alternatives/filesystem.py`
- github: `python agent-toolkit/mcp-alternatives/github.py`
- memory: `python agent-toolkit/mcp-alternatives/memory.py`

### Available Skills
- code-review: `agent-toolkit/skills/code-review/`
- testing-strategies: `agent-toolkit/skills/testing-strategies/`
- security-audit: `agent-toolkit/skills/security-audit/`

### Model Sizing
- Micro tasks (Haiku): File operations, scanning
- Standard tasks (Sonnet): Analysis, refactoring
- Advanced tasks (Opus): Architecture, strategy
```

### Step 8: Add Thinking Budgets

Update settings.json with per-agent thinking budgets:

**Before**:
```json
{
  "model": "claude-sonnet-4-20250514"
}
```

**After**:
```json
{
  "model": "claude-sonnet-4-20250514",
  "thinking_budget": 12000,
  "agents": {
    "code-analyzer": {
      "model": "sonnet",
      "thinking_budget": 8000
    },
    "refactor-executor": {
      "model": "haiku",
      "thinking_budget": 2000
    },
    "architecture-reviewer": {
      "model": "opus",
      "thinking_budget": 18000
    }
  }
}
```

## Upgrade Example: Refactoring Swarm

### Current Architecture

```
refactoring-swarm/
├── .claude/
│   ├── CLAUDE.md (5000 lines, includes all knowledge)
│   ├── settings.json (single model config)
│   ├── agents/
│   │   ├── code-analyzer.md
│   │   ├── smell-detector.md
│   │   ├── refactoring-planner.md
│   │   ├── refactoring-executor.md
│   │   ├── test-validator.md
│   │   ├── code-reviewer.md
│   │   └── commit-generator.md
│   ├── hooks/
│   │   ├── session-start.py
│   │   └── memory-manager.py
│   └── scripts/
│       └── analyze-complexity.py
└── memory/
```

### Upgraded Architecture

```
refactoring-swarm/
├── .claude/
│   ├── CLAUDE.md (2000 lines, references toolkit)
│   ├── settings.json (enhanced with model sizing)
│   ├── agents/ (assembled from toolkit)
│   ├── skills/ (symlinks to toolkit skills)
│   └── scripts/
│       ├── mcp-filesystem.py -> ../../agent-toolkit/mcp-alternatives/filesystem.py
│       ├── mcp-github.py -> ../../agent-toolkit/mcp-alternatives/github.py
│       └── analyze-complexity.py
└── memory/
```

### Upgrade Steps for Refactoring Swarm

#### 1. Identify Skills

Domain knowledge in Refactoring Swarm:
- Code quality patterns → `code-review` skill
- Testing strategies → `testing-strategies` skill

#### 2. Assign Models

| Agent | Current | Upgraded | Reason |
|---|---|---|---|
| code-analyzer | sonnet | sonnet | Complex analysis |
| smell-detector | sonnet | haiku | Pattern matching |
| refactoring-planner | sonnet | sonnet | Strategic planning |
| refactoring-executor | sonnet | haiku | Mechanical changes |
| test-validator | sonnet | haiku | Run tests |
| code-reviewer | sonnet | opus | Quality judgment |
| commit-generator | sonnet | haiku | Format messages |

#### 3. Replace Tools

**MCP Servers** → **Script Alternatives**

```bash
# Remove MCP server config from settings.json

# Add script references to agent definitions
tools:
  - filesystem  # Uses agent-toolkit/mcp-alternatives/filesystem.py
  - github      # Uses agent-toolkit/mcp-alternatives/github.py
  - memory      # Uses agent-toolkit/mcp-alternatives/memory.py
```

#### 4. Extract Skills

Move implicit knowledge to explicit skills:

**From CLAUDE.md**:
```markdown
## Code Smells to Detect

- Long functions (>50 lines)
- Duplicated code (>5 lines repeated)
- God objects (>1000 lines)
- Tight coupling
- Magic numbers
```

**To** `skills/code-review/SKILL.md` (already exists in toolkit)

**Update CLAUDE.md**:
```markdown
## Code Smell Detection

Deploy smell-detector agent which uses the code-review skill:
`cat agent-toolkit/skills/code-review/SKILL.md`
```

#### 5. Update Agent Definitions

**Before** (code-analyzer.md):
```markdown
---
name: code-analyzer
model: sonnet
---

# Code Analyzer

Build code graph, analyze complexity, identify smells.

[5000 lines of detailed instructions...]
```

**After** (code-analyzer.md):
```markdown
---
name: code-analyzer
model: sonnet
thinking_budget: 8000
tools: [filesystem, github]
skills: [code-review]
---

# Code Analyzer

Build code graph, analyze complexity using code-review skill.

## Quick Start

1. Load code-review skill: `cat agent-toolkit/skills/code-review/SKILL.md`
2. Scan codebase: `python agent-toolkit/mcp-alternatives/filesystem.py search . "*.py" --recursive`
3. Analyze files using skill guidelines
4. Generate complexity report

[500 lines - references skills instead of duplicating knowledge]
```

#### 6. Enhance Orchestrator

**Add** to refactoring-swarm/.claude/CLAUDE.md:

```markdown
## Agent Toolkit Integration

### Tools
All agents use script-based MCP alternatives for context efficiency:
- filesystem operations: agent-toolkit/mcp-alternatives/filesystem.py
- github operations: agent-toolkit/mcp-alternatives/github.py
- state management: agent-toolkit/mcp-alternatives/memory.py

### Skills
Agents load skills as needed via progressive disclosure:
- code-review: Code quality, smells, patterns
- testing-strategies: Test generation, validation

### Model Assignment
- **Micro (Haiku)**: smell-detector, refactor-executor, test-validator, commit-generator
- **Standard (Sonnet)**: code-analyzer, refactoring-planner
- **Advanced (Opus)**: code-reviewer

### Thinking Budgets
- Haiku agents: 2000-5000 tokens
- Sonnet agents: 8000-12000 tokens
- Opus agents: 15000-20000 tokens
```

#### 7. Update Settings

**Before**:
```json
{
  "model": "claude-sonnet-4-20250514",
  "temperature": 0.7,
  "tools": ["Task", "Read", "Write", "Edit", "Bash"]
}
```

**After**:
```json
{
  "model": "claude-sonnet-4-20250514",
  "thinking_budget": 12000,
  "temperature": 0.7,
  "tools": ["Task", "Read", "Write", "Edit", "Bash"],
  "agent_toolkit": {
    "enabled": true,
    "root": "../agent-toolkit"
  },
  "agents": {
    "code-analyzer": {
      "model": "sonnet",
      "thinking_budget": 8000
    },
    "smell-detector": {
      "model": "haiku",
      "thinking_budget": 3000
    },
    "refactoring-planner": {
      "model": "sonnet",
      "thinking_budget": 10000
    },
    "refactoring-executor": {
      "model": "haiku",
      "thinking_budget": 2000
    },
    "test-validator": {
      "model": "haiku",
      "thinking_budget": 2000
    },
    "code-reviewer": {
      "model": "opus",
      "thinking_budget": 15000
    },
    "commit-generator": {
      "model": "haiku",
      "thinking_budget": 1000
    }
  }
}
```

### Results

**Before Upgrade**:
- Context usage: ~15% (MCP servers + all skills loaded)
- Single model for all agents
- Implicit knowledge in long prompts
- Fixed configuration

**After Upgrade**:
- Context usage: ~3% (script alternatives + progressive skills)
- Optimized model per agent (cost savings)
- Explicit, reusable skills
- Dynamic agent assembly

## Automated Upgrade Script

```bash
#!/bin/bash
# upgrade-swarm.sh - Automated swarm upgrade to Agent Toolkit

SWARM_NAME=$1
SWARM_DIR=$2

echo "Upgrading $SWARM_NAME..."

# 1. Backup existing swarm
cp -r $SWARM_DIR ${SWARM_DIR}.backup

# 2. Create symlinks to MCP alternatives
mkdir -p $SWARM_DIR/.claude/scripts
ln -sf ../../agent-toolkit/mcp-alternatives/filesystem.py $SWARM_DIR/.claude/scripts/
ln -sf ../../agent-toolkit/mcp-alternatives/github.py $SWARM_DIR/.claude/scripts/
ln -sf ../../agent-toolkit/mcp-alternatives/memory.py $SWARM_DIR/.claude/scripts/

# 3. Create symlinks to skills
mkdir -p $SWARM_DIR/.claude/skills
ln -sf ../../agent-toolkit/skills/code-review $SWARM_DIR/.claude/skills/
ln -sf ../../agent-toolkit/skills/testing-strategies $SWARM_DIR/.claude/skills/

# 4. Update settings.json (manual review needed)
echo "Review and update $SWARM_DIR/.claude/settings.json with model sizing"

# 5. Update CLAUDE.md (manual review needed)
echo "Review and update $SWARM_DIR/.claude/CLAUDE.md with toolkit integration"

echo "✅ Upgrade complete. Review changes and test."
```

## Testing Upgraded Swarm

### Validation Checklist

- [ ] All agents reference correct toolkit paths
- [ ] Skills load successfully
- [ ] MCP alternatives work
- [ ] Model sizing is appropriate
- [ ] Thinking budgets are set
- [ ] Orchestrator deploys agents correctly
- [ ] Memory bank functions
- [ ] Quality standards maintained

### Test Commands

```bash
# Test filesystem MCP alternative
python agent-toolkit/mcp-alternatives/filesystem.py list . --recursive

# Test skill loading
cat agent-toolkit/skills/code-review/SKILL.md

# Test agent assembly
python agent-toolkit/scripts/assemble-agent.py \
  --name test-agent \
  --model haiku \
  --tools filesystem \
  --skills code-review \
  --output test-agent.md

# Test swarm deployment
python agent-toolkit/scripts/deploy-swarm.py \
  --swarm-name test-swarm \
  --agents '[{"name": "test-agent", "model": "haiku"}]' \
  --output test-swarm/
```

## Rollback Procedure

If upgrade issues occur:

```bash
# Restore backup
rm -rf $SWARM_DIR
mv ${SWARM_DIR}.backup $SWARM_DIR

# Review errors
# Fix issues
# Re-attempt upgrade
```

## Migration Timeline

Recommended upgrade order:

1. **Test swarms first**: Documentation, Test (simpler)
2. **Core swarms**: Refactoring, Security (most used)
3. **Advanced swarms**: Performance, Migration (complex)
4. **Specialized swarms**: MLOps, Data Pipeline (domain-specific)

## Support and Troubleshooting

### Common Issues

**Issue**: Agent not finding skills
**Fix**: Verify skill symlinks: `ls -la .claude/skills/`

**Issue**: MCP alternative not executing
**Fix**: Check script permissions: `chmod +x agent-toolkit/mcp-alternatives/*.py`

**Issue**: Model sizing not working
**Fix**: Verify settings.json has `agents` section with model configs

**Issue**: Context still high
**Fix**: Ensure progressive disclosure - agents should read skills on-demand, not load all at start

### Getting Help

- Review `agent-toolkit/README.md`
- Check `agent-toolkit/examples/`
- Test with minimal configuration first
- Validate one agent at a time

## Next Steps

After upgrading all swarms:

1. **Document custom patterns**: Capture swarm-specific patterns
2. **Create new skills**: Extract common knowledge
3. **Optimize further**: Fine-tune model sizing and thinking budgets
4. **Share learnings**: Contribute improvements back to toolkit

---

**Upgrade Guide v1.0.0** | Compatible with Claude Code v1.0+
