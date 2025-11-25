---
description: Deploy Agent Toolkit swarm for domain-specific tasks
---

# Orchestrate Command

**Usage**: `/orchestrate <domain> <task-description>`

**Purpose**: Deploy specialized Agent Toolkit V2 swarms for production software engineering tasks

---

## Available Domains

- `security` - Security auditing, vulnerability scanning, threat modeling
- `refactoring` - Code refactoring, pattern application, tech debt reduction
- `documentation` - API docs, architecture diagrams, user guides
- `test` - Test generation, coverage analysis, test strategy
- `performance` - Performance profiling, optimization, bottleneck analysis
- `cicd` - Pipeline design, deployment automation, release management
- `observability` - Logging, monitoring, alerting, metrics
- `migration` - Database migrations, API versioning, data transformation
- `api` - API design, REST/GraphQL, integration patterns
- `database` - Schema design, query optimization, indexing
- `data-pipeline` - ETL, stream processing, data validation
- `mlops` - ML pipeline, model deployment, experiment tracking

---

## Examples

### Example 1: Security Audit

```
/orchestrate security audit authentication module for SQL injection and XSS
```

**What happens**:
1. Loads `security-swarm-v2` from `agent-toolkit-swarms/`
2. Triggers `security-audit` skill (keyword: "audit")
3. Triggers `owasp-top-10` skill (keywords: "SQL injection", "XSS")
4. Deploys subagents:
   - `vulnerability-scanner` (Haiku) - Automated pattern detection
   - `attack-surface-mapper` (Opus) - Architectural analysis
   - `code-flow-analyzer` (Sonnet) - Logic tracing
5. Aggregates findings into security report
6. Returns recommendations and severity ratings

**Cost**: ~$1.50-2.00 (mixed model sizing)
**Time**: 2-3 minutes

### Example 2: Refactoring

```
/orchestrate refactoring apply repository pattern to data access layer in services/
```

**What happens**:
1. Loads `refactoring-swarm-v2`
2. Triggers `refactoring` skill (keyword: "refactoring")
3. Triggers `design-patterns` skill (keyword: "repository pattern")
4. Deploys subagents:
   - `pattern-analyzer` (Sonnet) - Identify variation points
   - `code-transformer` (Sonnet) - Apply pattern
   - `test-updater` (Haiku) - Adjust tests
6. Returns refactored code with tests
7. Provides migration guide

**Cost**: ~$1.00-1.50
**Time**: 3-4 minutes

### Example 3: Test Generation

```
/orchestrate test generate integration tests for checkout flow API endpoints
```

**What happens**:
1. Loads `test-swarm-v2`
2. Triggers `test-strategy` skill (keywords: "integration tests")
3. Deploys subagents:
   - `endpoint-analyzer` (Haiku) - Map API surface
   - `test-generator` (Sonnet) - Generate test cases
   - `assertion-designer` (Sonnet) - Create assertions
   - `coverage-analyzer` (Haiku) - Verify coverage
4. Returns comprehensive test suite
5. Provides coverage report

**Cost**: ~$1.20-1.80
**Time**: 2-3 minutes

---

## Orchestration Flow

```
USER COMMAND: /orchestrate <domain> <task>
    ↓
ORCHESTRATOR:
  1. Parse domain and task
  2. Load swarm: agent-toolkit-swarms/<domain>-swarm-v2/
  3. Analyze task keywords
  4. Auto-load relevant skills (progressive disclosure)
  5. Determine required subagents
    ↓
SUBAGENT DEPLOYMENT:
  For each required subagent:
    - Determine complexity (low/medium/high)
    - Assign model (Haiku/Sonnet/Opus)
    - Set thinking budget
    - Inject task context
    - Deploy via Task tool
    ↓
EXECUTION:
  - Subagents work in parallel (where possible)
  - Use script-based MCP alternatives for efficiency
  - Skills provide domain knowledge
  - Results stream back to orchestrator
    ↓
AGGREGATION:
  - Orchestrator combines subagent results
  - Formats comprehensive report
  - Returns to user
    ↓
USER RECEIVES:
  - Complete analysis/solution
  - Recommendations
  - Cost breakdown
  - Next steps
```

---

## Subagent Context Injection

Each subagent receives dynamically composed context:

```markdown
# <Subagent Name> Agent

**Task Context** (from user prompt):
Domain: security
Task: audit authentication module for SQL injection and XSS
Target: src/auth/

**Skills Available** (auto-loaded):
- security-audit (triggered by "audit")
- owasp-top-10 (triggered by "SQL injection", "XSS")

**Tools Available**:
- filesystem.py (for file scanning)
- github.py (for PR operations if needed)

**Your Role**:
You are the vulnerability scanner. Focus on automated detection of:
- SQL injection patterns
- XSS vulnerabilities
- Input validation issues

Scan src/auth/ directory and report findings in JSON format.

**Model**: Haiku
**Thinking Budget**: 3,000 tokens
**Complexity**: LOW (pattern matching)
```

---

## Configuration

### settings.json

```json
{
  "orchestrate_command": {
    "enabled": true,
    "max_parallel_subagents": 5,
    "skill_auto_load": true,
    "budget_per_orchestration": 3.00,
    "default_strategy": "balanced"
  },
  "model_strategies": {
    "balanced": {
      "low": "claude-haiku-4-20250514",
      "medium": "claude-sonnet-4-20250514",
      "high": "claude-opus-4-20250514"
    },
    "cost_optimized": {
      "low": "claude-haiku-4-20250514",
      "medium": "claude-sonnet-3-5-20241022",
      "high": "claude-sonnet-4-20250514"
    }
  }
}
```

### Swarm Selection Logic

```python
# Map user domain to swarm directory
SWARM_MAP = {
    "security": "agent-toolkit-swarms/security-swarm-v2",
    "refactoring": "agent-toolkit-swarms/refactoring-swarm-v2",
    "documentation": "agent-toolkit-swarms/documentation-swarm-v2",
    # ... etc
}

domain = parse_domain_from_user_input(user_command)
swarm_path = SWARM_MAP[domain]

# Load swarm configuration
swarm_config = load_config(f"{swarm_path}/.claude/settings.json")
available_agents = list_agents(f"{swarm_path}/.claude/agents/")
available_skills = list_skills(f"{swarm_path}/.claude/skills/")
```

---

## Skill Auto-Loading

Skills auto-load based on keyword matching:

```yaml
# .claude/skills/security-audit/SKILL.md
---
name: security-audit
description: Security audit checklist, OWASP guidelines. Use when: audit, security, vulnerability, threat
---

# Security Audit Skill
[... loaded when keywords match user prompt ...]
```

**Trigger Logic**:
```python
user_prompt = "audit authentication module for SQL injection"
keywords = ["audit", "authentication", "SQL injection"]

# Check all skills
for skill in available_skills:
    skill_triggers = skill.description.split("Use when:")[1].split(",")
    skill_triggers = [t.strip() for t in skill_triggers]

    if any(kw in keyword for kw in keywords for keyword in skill_triggers):
        load_skill(skill)

# Results: security-audit skill loaded, owasp-top-10 skill loaded
```

---

## Cost Breakdown Example

```
Orchestration: /orchestrate security audit payment module

Subagents Deployed:
1. vulnerability-scanner (Haiku, 3000 budget) - $0.20
2. attack-surface-mapper (Opus, 15000 budget) - $1.20
3. code-flow-analyzer (Sonnet, 10000 budget) - $0.50
4. security-report-generator (Haiku, 3000 budget) - $0.10

Skills Loaded:
- security-audit (progressive disclosure) - $0.05
- owasp-top-10 (progressive disclosure) - $0.05

Total Cost: $2.10
Total Time: 3 minutes 12 seconds
Subagents: 4 deployed (2 parallel, 2 sequential)
Context Efficiency: 4% (vs 35% without progressive disclosure)
```

---

## Advanced Usage

### Chaining Orchestrations

```
/orchestrate security audit payment module

# Review results, then:

/orchestrate refactoring fix identified security issues in payment module

# After refactoring:

/orchestrate test generate security-focused tests for payment module
```

### Custom Orchestration Parameters

```
/orchestrate security audit payment module --strategy=cost_optimized --max-budget=1.50
```

### Exporting Results

```
/orchestrate documentation generate API docs for payment module --format=openapi --output=docs/payment-api.yaml
```

---

## Troubleshooting

### Issue: Skill not auto-loading

**Cause**: Keywords in user prompt don't match skill triggers

**Solution**: Check skill `description` field, add more trigger keywords

### Issue: Wrong subagents deployed

**Cause**: Orchestrator misunderstood task intent

**Solution**: Be more explicit in task description

**Example**:
- Bad: `/orchestrate security check code`
- Good: `/orchestrate security audit authentication module for injection vulnerabilities`

### Issue: Budget exceeded

**Cause**: Too many subagents or high-complexity models

**Solution**: Use `--strategy=cost_optimized` or reduce scope

---

## Integration with CI/CD

```yaml
# .github/workflows/swarm-check.yml
name: Swarm Quality Check

on: [pull_request]

jobs:
  security-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Security Audit
        run: |
          claude /orchestrate security audit changed files for vulnerabilities \
            --output-format json > security-report.json

  refactoring-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Code Quality
        run: |
          claude /orchestrate refactoring analyze changed files for tech debt \
            --output-format json > refactoring-report.json
```

---

## See Also

- [Agent Toolkit Architecture](../agent-toolkit-swarms/ARCHITECTURE.md)
- [All Available Swarms](../agent-toolkit-swarms/)
- [Deployment Scripts](../deployment-scripts/)

---

**Command Version**: 1.0.0
**Compatible Swarms**: All 12 Agent Toolkit V2 swarms
**Last Updated**: 2025-11-22
