# Multi-Agent Orchestration with Claude Code

**Deployment Pattern**: Context-Injected Orchestration (CIO)
**Orchestrator**: Claude Code (headless CLI)
**Architecture**: Multi-agent swarms with dynamic prompt injection

## How to Deploy Multi-Agent Systems with Claude Code

This document shows how to use **Claude Code as a headless multi-agent orchestration system** using the Context-Injected Orchestration (CIO) Pattern.

### The CIO Pattern: What You Need to Know

```
Predefined Solution + Runtime Prompt = Executed Action
      ↓                    ↓                ↓
  .claude folder      User's intent    Claude Code runs
```

**Three components**:
1. **Static Context**: `.claude/` folder with agent definitions
2. **Dynamic Intent**: User's runtime prompt (what to do)
3. **Orchestrator**: Claude Code CLI (headless execution)

## Quick Start: Run Your First Agent

### 1. Navigate to Agent Directory
```bash
cd /path/to/your/agent-folder
```

### 2. Execute with Claude Code Headless
```bash
claude -p "Your specific task here" --output-format stream-json
```

### 3. Claude Code Executes
- Reads `.claude/` configuration
- Loads `CLAUDE.md` identity
- Processes your prompt
- Returns results

## Headless Claude Code Syntax

### Basic Execution

```bash
# Syntax
claude -p "<prompt>" [options]

# Example
claude -p "Analyze the authentication module for security issues"
```

### Common Options

```bash
# Stream JSON output (recommended for headless)
claude -p "Scan code for bugs" --output-format stream-json

# Specify thinking budget
claude -p "Complex reasoning task" --thinking-budget 15000

# Set temperature
claude -p "Creative task" --temperature 0.9

# Verbose logging
claude -p "Debug this issue" --verbose

# Save output to file
claude -p "Generate report" > output.json
```

### Multi-Line Prompts

```bash
# Using heredoc
claude -p "$(cat <<'EOF'
Task: Audit the payment processing module

Requirements:
1. Check for SQL injection
2. Verify input validation
3. Test authentication bypass
4. Generate security report
EOF
)"

# Using file input
claude -p "$(cat task-description.txt)"
```

## CIO Pattern: Folder Structure

Drop this structure into any project to enable multi-agent orchestration:

```
your-project/
├── .claude/                    # THE CAPABILITIES
│   ├── CLAUDE.md              # Identity & orchestration logic
│   │
│   ├── settings.json          # Configuration
│   │   # {
│   │   #   "model": "claude-sonnet-4-20250514",
│   │   #   "thinking_budget": 12000,
│   │   #   "agents": { ... }
│   │   # }
│   │
│   └── agents/                # Sub-agent definitions
│       ├── agent-1.md
│       ├── agent-2.md
│       └── agent-3.md
│
└── (your project files)
```

## Real-World Deployment Examples

### Example 1: Security Audit Agent

**Setup**:
```bash
# Create agent folder
mkdir -p my-security-agent/.claude/agents

# Add identity
cat > my-security-agent/.claude/CLAUDE.md <<'EOF'
# Security Audit Agent

You are a Security Audit Agent specializing in vulnerability detection.

## Your Capabilities
- Scan code for SQL injection, XSS, CSRF vulnerabilities
- Test authentication and authorization flows
- Generate security reports with remediation steps

## Workflow
1. Analyze provided code/module
2. Identify security issues
3. Test for exploitability
4. Generate report with fixes
EOF

# Add configuration
cat > my-security-agent/.claude/settings.json <<'EOF'
{
  "model": "claude-sonnet-4-20250514",
  "thinking_budget": 12000,
  "temperature": 0.5
}
EOF
```

**Execute**:
```bash
cd my-security-agent

# Single-module audit
claude -p "Audit auth.py for SQL injection vulnerabilities" \
  --output-format stream-json

# Comprehensive audit
claude -p "$(cat <<'TASK'
Perform comprehensive security audit:
1. Scan all Python files in src/auth/
2. Check for: SQL injection, XSS, CSRF, auth bypass
3. Generate report with severity ratings
4. Provide fix recommendations
TASK
)"
```

### Example 2: Multi-Agent Refactoring Swarm

**Setup**:
```bash
mkdir -p refactoring-swarm/.claude/agents

# Orchestrator identity
cat > refactoring-swarm/.claude/CLAUDE.md <<'EOF'
# Refactoring Swarm Orchestrator

You manage a team of specialized refactoring agents.

## Available Agents
- code-analyzer.md: Analyzes code quality
- smell-detector.md: Identifies code smells
- refactoring-executor.md: Applies refactorings

## Orchestration Logic
1. Deploy code-analyzer to understand current state
2. Deploy smell-detector to find issues
3. Deploy refactoring-executor to fix issues
4. Validate changes maintain functionality
EOF

# Sub-agent: code-analyzer
cat > refactoring-swarm/.claude/agents/code-analyzer.md <<'EOF'
# Code Analyzer

**Role**: Analyze code structure and quality

## Mission
Examine code and identify:
- Complexity metrics
- Design pattern violations
- Coupling and cohesion issues
EOF

# Configuration
cat > refactoring-swarm/.claude/settings.json <<'EOF'
{
  "model": "claude-sonnet-4-20250514",
  "thinking_budget": 12000,
  "agents": {
    "code-analyzer": {"complexity": "high"},
    "smell-detector": {"complexity": "medium"},
    "refactoring-executor": {"complexity": "medium"}
  }
}
EOF
```

**Execute**:
```bash
cd refactoring-swarm

claude -p "Refactor UserService.java to follow SOLID principles" \
  --output-format stream-json

# Save results
claude -p "Refactor payment module for testability" > refactoring-plan.json
```

### Example 3: Evolutionary Problem Solver

**Setup**:
```bash
mkdir -p problem-solver/.claude/agents

cat > problem-solver/.claude/CLAUDE.md <<'EOF'
# Evolutionary Problem Solver

You use evolutionary algorithms to solve complex problems.

## Approach
1. Generate population of solution candidates
2. Evaluate fitness of each candidate
3. Evolve top performers through revision
4. Return best solution

## Available Strategies
- Pure evolution (40 candidates, 3 generations)
- Library evolution (10 candidates, uses learned patterns)
EOF

cat > problem-solver/.claude/settings.json <<'EOF'
{
  "model": "claude-sonnet-4-5-20250929",
  "thinking_budget": 15000,
  "temperature": 0.8,
  "evolutionary_config": {
    "initial_population": 30,
    "max_generations": 4
  }
}
EOF
```

**Execute**:
```bash
cd problem-solver

# Solve pattern recognition task
claude -p "$(cat arc-task-001.json)" --thinking-budget 20000

# With specific strategy
claude -p "Solve optimization problem: minimize f(x,y,z) = x² + y² + z²"
```

## Deployment Automation

### Arsenal-Based Deployment

Create reusable agent templates:

```bash
# Setup arsenal
mkdir -p ~/agent-arsenal
cd ~/agent-arsenal

# Copy templates
cp -r /path/to/markdown_agents/security-swarm-v2 ./
cp -r /path/to/markdown_agents/refactoring-swarm-v2 ./
cp -r /path/to/markdown_agents/evolutionary-compute-test ./
```

### Deployment Script

Create `deploy-agent.sh`:

```bash
#!/bin/bash
# deploy-agent.sh <template-name> "<prompt>"

set -euo pipefail

TEMPLATE="${1:?Template name required}"
PROMPT="${2:?Prompt required}"
ARSENAL_DIR="${AGENT_ARSENAL:-$HOME/agent-arsenal}"
SESSION_ID="$(date +%s)-$$"
WORKSPACE="/tmp/agent-session-${SESSION_ID}"

echo "[$(date)] Deploying agent: ${TEMPLATE}"

# 1. Create isolated workspace
mkdir -p "${WORKSPACE}"
trap "rm -rf '${WORKSPACE}'" EXIT

# 2. Inject template
if [[ ! -d "${ARSENAL_DIR}/${TEMPLATE}" ]]; then
    echo "Error: Template '${TEMPLATE}' not found in ${ARSENAL_DIR}"
    exit 1
fi

cp -r "${ARSENAL_DIR}/${TEMPLATE}"/* "${WORKSPACE}/"

# 3. Execute
cd "${WORKSPACE}"
echo "[$(date)] Executing prompt..."

claude -p "${PROMPT}" \
  --output-format stream-json \
  2>&1 | tee "/tmp/agent-${SESSION_ID}.log"

echo "[$(date)] Execution complete"
```

Make executable:
```bash
chmod +x deploy-agent.sh
```

**Usage**:

```bash
# Security audit
./deploy-agent.sh security-swarm-v2 \
  "Audit payment processing for vulnerabilities"

# Code refactoring
./deploy-agent.sh refactoring-swarm-v2 \
  "Refactor authentication module for dependency injection"

# Problem solving
./deploy-agent.sh evolutionary-compute-test \
  "Solve pattern recognition task: [data]"

# With custom arsenal location
AGENT_ARSENAL=/custom/path ./deploy-agent.sh security-swarm-v2 "Scan auth.py"
```

## Advanced Orchestration Patterns

### Pattern 1: Sequential Agent Chain

Execute multiple agents in sequence:

```bash
#!/bin/bash
# chain-agents.sh

# 1. Analyze code
claude -p "Analyze codebase structure" > analysis.json

# 2. Refactor based on analysis
claude -p "Refactor based on: $(cat analysis.json)"

# 3. Generate tests
claude -p "Generate tests for refactored code"

# 4. Run validation
claude -p "Validate all changes maintain functionality"
```

### Pattern 2: Parallel Agent Execution

Run multiple agents concurrently:

```bash
#!/bin/bash
# parallel-agents.sh

# Launch agents in parallel
(cd security-agent && claude -p "Scan for vulnerabilities" > sec.json) &
(cd performance-agent && claude -p "Profile performance" > perf.json) &
(cd test-agent && claude -p "Run test suite" > tests.json) &

# Wait for all to complete
wait

# Combine results
echo "Security: $(cat sec.json)"
echo "Performance: $(cat perf.json)"
echo "Tests: $(cat tests.json)"
```

### Pattern 3: Conditional Agent Dispatch

Execute different agents based on conditions:

```bash
#!/bin/bash
# conditional-dispatch.sh

FILE_TYPE="$1"

case "${FILE_TYPE}" in
    *.py)
        cd python-agent
        claude -p "Analyze Python file: ${FILE_TYPE}"
        ;;
    *.java)
        cd java-agent
        claude -p "Analyze Java file: ${FILE_TYPE}"
        ;;
    *.ts|*.js)
        cd typescript-agent
        claude -p "Analyze TypeScript/JavaScript file: ${FILE_TYPE}"
        ;;
    *)
        echo "Unknown file type: ${FILE_TYPE}"
        exit 1
        ;;
esac
```

### Pattern 4: Interactive Agent Loop

Create interactive sessions:

```bash
#!/bin/bash
# interactive-agent.sh

AGENT_DIR="$1"
cd "${AGENT_DIR}"

echo "Agent ready. Type 'exit' to quit."

while true; do
    echo -n "> "
    read -r PROMPT

    [[ "${PROMPT}" == "exit" ]] && break

    claude -p "${PROMPT}" --output-format stream-json
done
```

## Monitoring and Logging

### Structured Logging

```bash
# Log all agent executions
claude -p "Task description" \
  --output-format stream-json \
  2>&1 | tee -a agent-executions.log

# Parse JSON logs
jq '.type,.content' < agent-executions.log

# Filter errors
grep -A5 'error' agent-executions.log
```

### Cost Tracking

```bash
#!/bin/bash
# track-costs.sh

LOG_FILE="/tmp/agent-costs.csv"
echo "timestamp,agent,tokens,cost" > "${LOG_FILE}"

# Wrapper around deploy-agent.sh
deploy_with_tracking() {
    local AGENT="$1"
    local PROMPT="$2"
    local TIMESTAMP="$(date -Iseconds)"

    # Execute and capture output
    OUTPUT=$(./deploy-agent.sh "${AGENT}" "${PROMPT}")

    # Parse tokens from output (example)
    TOKENS=$(echo "${OUTPUT}" | jq -r '.usage.total_tokens // 0')

    # Estimate cost (example: $0.015 per 1K tokens)
    COST=$(echo "scale=4; ${TOKENS} * 0.015 / 1000" | bc)

    echo "${TIMESTAMP},${AGENT},${TOKENS},${COST}" >> "${LOG_FILE}"

    echo "${OUTPUT}"
}

# Usage
deploy_with_tracking security-swarm-v2 "Audit code"
deploy_with_tracking refactoring-swarm-v2 "Refactor module"

# View costs
column -t -s',' "${LOG_FILE}"
```

## Integration Examples

### CI/CD Pipeline Integration

```yaml
# .github/workflows/agent-audit.yml
name: Security Audit with Claude Agent

on: [push, pull_request]

jobs:
  security-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Claude Code
        run: |
          # Install Claude Code CLI
          curl -fsSL https://install.claude.ai | sh

      - name: Deploy Security Agent
        run: |
          cd security-swarm-v2
          claude -p "Audit all Python files for vulnerabilities" \
            --output-format stream-json > audit-report.json
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}

      - name: Check Results
        run: |
          # Fail if critical vulnerabilities found
          if jq -e '.vulnerabilities[] | select(.severity == "critical")' audit-report.json; then
            echo "Critical vulnerabilities found!"
            exit 1
          fi

      - name: Upload Report
        uses: actions/upload-artifact@v3
        with:
          name: security-audit
          path: audit-report.json
```

### Pre-commit Hook Integration

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run code quality agent before commit
cd /path/to/refactoring-agent

CHANGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py$')

if [[ -n "${CHANGED_FILES}" ]]; then
    echo "Running code quality check..."

    RESULT=$(claude -p "Analyze these files for quality issues: ${CHANGED_FILES}")

    if echo "${RESULT}" | grep -q "CRITICAL"; then
        echo "Critical code quality issues found. Commit blocked."
        echo "${RESULT}"
        exit 1
    fi
fi
```

## Structure of CIO-Compliant Agents

Each agent template follows this structure

```
<swarm-name>/
├── CLAUDE.md              # The Identity (who the agent is)
├── .claude/
│   ├── settings.json      # The Capabilities (tools, models, config)
│   ├── agents/            # Sub-agent definitions (if multi-agent)
│   │   ├── agent-1.md
│   │   ├── agent-2.md
│   │   └── ...
│   └── plugins/           # Optional: strategy configs, parameters
│       ├── model-strategies.yaml
│       └── evolution-config.yaml
└── README.md              # Documentation (optional)
```

### Example: Security Swarm

**The Identity** (`CLAUDE.md`):
```markdown
# Security Audit Swarm - Orchestrator

You are the **Security Audit Swarm Orchestrator**, managing autonomous
security analysis with optimized model sizing.

[persona definition, workflow, quality standards...]
```

**The Capabilities** (`.claude/settings.json`):
```json
{
  "model": "claude-sonnet-4-20250514",
  "agents": {
    "vulnerability-scanner": { "complexity": "low" },
    "exploit-tester": { "complexity": "medium" },
    "fix-generator": { "complexity": "high" }
  }
}
```

**The Action** (Runtime):
```bash
# User prompt determines specific action
claude -p "Scan the authentication module for SQL injection vulnerabilities"
```

**The Execution**:
1. Claude Code starts in `security-swarm/` directory
2. Reads `CLAUDE.md`: "I am a Security Audit Orchestrator"
3. Loads capabilities from `.claude/settings.json`
4. Processes user prompt: "Scan authentication for SQL injection"
5. Deploys appropriate sub-agents based on prompt
6. Returns results

## Deployment as CIO Templates

### The Arsenal Structure

```
~/agent-arsenal/
├── security-swarm-v2/
│   ├── CLAUDE.md
│   └── .claude/
│       ├── settings.json
│       └── agents/
├── refactoring-swarm-v2/
│   ├── CLAUDE.md
│   └── .claude/
├── documentation-swarm-v2/
│   ├── CLAUDE.md
│   └── .claude/
├── evolutionary-compute-test/
│   ├── CLAUDE.md
│   └── .claude/
└── evolutionary-compute-library/
    ├── CLAUDE.md
    └── .claude/
```

### Generic Deployment Script

```bash
#!/bin/bash
# deploy-agent.sh <template-name> "<user-prompt>"

TEMPLATE=$1
PROMPT=$2
SESSION_ID=$(uuidgen)
WORKSPACE="/tmp/agent-session-${SESSION_ID}"

# 1. Isolate: Create ephemeral workspace
mkdir -p "${WORKSPACE}"

# 2. Inject: Copy template into workspace
cp -r ~/agent-arsenal/${TEMPLATE}/* "${WORKSPACE}/"

# 3. Execute: Run Claude Code in that context
cd "${WORKSPACE}"
claude -p "${PROMPT}" --output-format stream-json

# 4. Monitor: Stream results
# (Output is already streamed via stream-json)

# 5. Cleanup (optional)
# rm -rf "${WORKSPACE}"
```

### Usage Examples

#### Example 1: Security Audit

```bash
deploy-agent security-swarm-v2 \
  "Audit the payment processing module for security vulnerabilities"
```

**What happens**:
- Claude wakes up as "Security Audit Orchestrator"
- Has access to: vulnerability-scanner, exploit-tester, fix-generator
- Executes: Scans payment module, tests exploits, generates fixes
- Returns: Security report with findings and patches

#### Example 2: Code Refactoring

```bash
deploy-agent refactoring-swarm-v2 \
  "Refactor the user authentication service to follow SOLID principles"
```

**What happens**:
- Claude wakes up as "Refactoring Swarm Orchestrator"
- Has access to: code-analyzer, smell-detector, refactoring-executor
- Executes: Analyzes auth service, identifies violations, refactors code
- Returns: Refactored code with SOLID compliance

#### Example 3: Evolutionary Problem Solving

```bash
deploy-agent evolutionary-compute-test \
  "Solve this ARC-AGI task: [task JSON]"
```

**What happens**:
- Claude wakes up as "Evolutionary Compute Orchestrator"
- Has access to: generator, evaluator, revisors
- Executes: Generates 30 candidates, evolves through 4 generations
- Returns: Best solution with fitness scores

## CIO Pattern Components

### 1. The Identity (CLAUDE.md)

**Purpose**: Defines the persona, boundaries, and orchestration logic

**Key Sections**:
```markdown
# [Swarm Name] - Orchestrator

You are the **[Role]**, managing [responsibilities].

## Agent Toolkit Integration
[Tools and capabilities available]

## Model Sizing Strategy
[Which agents use which model complexity]

## Workflow
[How to orchestrate sub-agents]

## Quality Standards
[What constitutes success]
```

**What it does**:
- Sets identity and boundaries ("You are X, not Y")
- Explains available capabilities
- Provides orchestration logic
- Defines quality standards

### 2. The Capabilities (.claude/)

**Purpose**: Actual tools, configurations, and sub-agents

**settings.json** - Core Configuration:
```json
{
  "model": "claude-sonnet-4-20250514",
  "thinking_budget": 12000,
  "temperature": 0.7,
  "swarm_config": {
    "name": "example-swarm",
    "architecture": "multi_agent_orchestration"
  },
  "agents": {
    "agent-1": { "complexity": "high" },
    "agent-2": { "complexity": "low" }
  }
}
```

**agents/** - Sub-Agent Definitions:
```markdown
# Agent Name

**Complexity**: HIGH/MEDIUM/LOW
**Role**: Specific responsibility

## Mission
[What this agent does]

## Integration
[How it fits in the swarm]
```

**plugins/** (Optional) - Strategy Configurations:
```yaml
# model-strategies.yaml
strategies:
  cost_optimized: { high: sonnet, medium: haiku }
  performance_optimized: { high: opus, medium: sonnet }
```

### 3. The User Prompt (Runtime)

**Purpose**: Determines the specific action

**Characteristics**:
- Dynamic (changes per execution)
- Specific (concrete task, not vague)
- Actionable (agent can fulfill with available tools)

**Examples**:
- ✅ Good: "Scan auth.py for SQL injection vulnerabilities"
- ✅ Good: "Refactor UserService to use dependency injection"
- ❌ Bad: "Make the code better" (too vague)
- ❌ Bad: "Write a novel" (outside capabilities)

## Benefits of CIO Pattern

### 1. Modularity
Each swarm is self-contained and reusable

### 2. Composability
Mix and match swarms for different projects

### 3. Safety
Predefined boundaries prevent scope creep

### 4. Flexibility
Same swarm, infinite specific actions via prompts

### 5. Cost Control
Model complexity defined statically, not per-prompt

### 6. Version Control
Templates are just folders - git commit them!

## Cross-Compatibility: Generic Anthropic Format

Our swarms follow Claude Code conventions but can be adapted:

### Claude Code Native
```
swarm-name/
├── CLAUDE.md              # Identity
└── .claude/               # Capabilities
    ├── settings.json      # Config
    └── agents/            # Sub-agents
```

### Generic Anthropic Format (if different)
```
swarm-name/
├── system-prompt.md       # Identity (different name)
├── config.json            # Capabilities (different structure)
└── agents/                # Sub-agents (same)
```

**Conversion**: Minimal - just rename/restructure, logic stays same

## Swarm Catalog

### Production-Ready Swarms (12 total)

1. **security-swarm-v2** - Security auditing and vulnerability fixing
2. **refactoring-swarm-v2** - Code quality and refactoring
3. **documentation-swarm-v2** - Documentation generation
4. **test-swarm-v2** - Test generation and validation
5. **performance-swarm-v2** - Performance optimization
6. **api-swarm-v2** - API development
7. **database-swarm-v2** - Database migrations
8. **cicd-swarm-v2** - CI/CD pipeline creation
9. **migration-swarm-v2** - Code migration
10. **observability-swarm-v2** - System observability
11. **data-pipeline-swarm-v2** - Data pipeline development
12. **mlops-swarm-v2** - ML operations

### Experimental Swarms (2 total)

1. **evolutionary-compute-test** - Pure evolutionary problem solving
2. **evolutionary-compute-library** - Meta-learning with knowledge transfer

## Quality Standards for CIO Templates

A well-designed CIO template must have:

### ✅ Clear Identity
- Specific role definition
- Explicit boundaries
- Orchestration logic

### ✅ Self-Contained Capabilities
- All necessary tools in `.claude/`
- No external dependencies
- Model complexity defined

### ✅ Documented Workflows
- Step-by-step orchestration
- Success criteria
- Error handling

### ✅ Composability
- Works standalone
- Can combine with other swarms
- Clean interfaces

### ✅ Cost Transparency
- Model usage specified
- Budget limits defined
- Efficiency metrics tracked

## Future Extensions

### Planned Enhancements

1. **Dynamic Swarm Composition**
   ```bash
   compose-swarm security-swarm refactoring-swarm \
     -p "Audit and refactor the authentication module"
   ```

2. **Swarm Chaining**
   ```bash
   chain-swarms \
     "security-swarm -> refactoring-swarm -> test-swarm" \
     -p "End-to-end security hardening"
   ```

3. **Swarm Marketplace**
   - Community-contributed swarms
   - Versioned templates
   - Quality ratings

4. **Auto-Discovery**
   ```bash
   claude --discover-swarms ~/agent-arsenal/
   claude --recommend-swarm "I need to optimize database queries"
   ```

## Conclusion

The **Context-Injected Orchestration (CIO) Pattern** enables:
- **Predefined Solutions** (safe, controlled)
- **User-Driven Actions** (infinite variety)
- **Modular Deployment** (reusable templates)

Our 14 agent swarms are production-ready CIO templates for Claude Code.

---

**Pattern**: Context-Injected Orchestration (CIO)
**Orchestrator**: Claude Code
**Templates**: 14 production-ready swarms
**Status**: Production-ready, cross-compatible
│   ├── CLAUDE.md              # - Persona definition
│   │                          # - Orchestration logic
│   │                          # - Quality standards
│   │
├── .claude/               # The Capabilities
│   ├── settings.json      # - Model configuration
│   │                      # - Agent assignments
│   │                      # - Tool specifications
│   │
│   ├── agents/            # Sub-agent definitions
│   │   ├── agent-1.md     # - Specific responsibilities
│   │   ├── agent-2.md     # - Model complexity
│   │   └── ...            # - Integration patterns
│   │
│   └── plugins/           # Strategy configurations (optional)
│       ├── model-strategies.yaml
│       └── evolution-config.yaml
│
└── README.md              # Documentation
```

## Quick Reference

### Essential Commands

```bash
# Basic execution
claude -p "<prompt>"

# With JSON output (recommended for headless)
claude -p "<prompt>" --output-format stream-json

# With options
claude -p "<prompt>" \
  --thinking-budget 15000 \
  --temperature 0.8 \
  --verbose

# From file
claude -p "$(cat task.txt)"

# Save output
claude -p "<prompt>" > output.json

# Multi-line prompt
claude -p "$(cat <<'EOF'
Line 1
Line 2
Line 3
EOF
)"
```

### Deployment Workflow

```bash
# 1. Setup arsenal
mkdir -p ~/agent-arsenal
cp -r agent-templates/* ~/agent-arsenal/

# 2. Create deployment script
cat > deploy-agent.sh <<'SCRIPT'
#!/bin/bash
TEMPLATE="$1"
PROMPT="$2"
WORKSPACE="/tmp/agent-$(date +%s)"
mkdir -p "${WORKSPACE}"
trap "rm -rf '${WORKSPACE}'" EXIT
cp -r ~/agent-arsenal/${TEMPLATE}/* "${WORKSPACE}/"
cd "${WORKSPACE}"
claude -p "${PROMPT}" --output-format stream-json
SCRIPT
chmod +x deploy-agent.sh

# 3. Deploy
./deploy-agent.sh security-swarm "Audit code"
```

## Available Agent Templates

This repository includes 14 production-ready agent templates:

### Production Swarms (12)
1. security-swarm-v2 - Security auditing
2. refactoring-swarm-v2 - Code refactoring
3. documentation-swarm-v2 - Documentation generation
4. test-swarm-v2 - Test generation
5. performance-swarm-v2 - Performance optimization
6. api-swarm-v2 - API development
7. database-swarm-v2 - Database migrations
8. cicd-swarm-v2 - CI/CD pipelines
9. migration-swarm-v2 - Code migration
10. observability-swarm-v2 - System observability
11. data-pipeline-swarm-v2 - Data pipelines
12. mlops-swarm-v2 - ML operations

### Experimental Swarms (2)
1. evolutionary-compute-test - Evolutionary problem solving
2. evolutionary-compute-library - Meta-learning evolution

## Summary

The **Context-Injected Orchestration (CIO) Pattern** enables:

✅ **Predefined Solutions** - Safe, controlled agent capabilities  
✅ **Dynamic Actions** - Infinite variety via runtime prompts  
✅ **Headless Execution** - Automate via Claude Code CLI  
✅ **Modular Deployment** - Reusable agent templates  
✅ **Cost Control** - Right-sized models per task  
✅ **Easy Integration** - CI/CD, pre-commit hooks, scripts  

**To deploy**:
1. Copy agent template to your project
2. `cd` into the agent directory
3. Run: `claude -p "Your task here"`

That's it. Claude Code handles the rest.

---

**Pattern**: Context-Injected Orchestration (CIO)  
**Orchestrator**: Claude Code (headless CLI)  
**Status**: Production-ready, 14 templates available  
**Last Updated**: 2025-01-19
