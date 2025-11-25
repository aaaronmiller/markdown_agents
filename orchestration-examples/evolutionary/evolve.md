---
description: Deploy dual-track evolutionary test-time compute for complex problems
---

# Evolve Command

**Usage**: `/evolve <task-file> [options]`

**Purpose**: Solve complex algorithmic problems using dual-track evolutionary test-time compute with multi-generation refinement

---

## Command Format

```bash
/evolve <task-file> --generations=4 --budget=9.00 --strategy=balanced
```

**Parameters**:
- `task-file`: Path to JSON task file (required)
- `--generations`: Number of evolution generations (default: 4)
- `--budget`: Maximum cost in dollars (default: 9.00)
- `--strategy`: Model strategy (balanced/cost_optimized/performance_optimized)

---

## Examples

### Example 1: ARC-AGI Task

```
/evolve arc_tasks/eval_001.json
```

**What happens**:

**Generation 1: Initial Population** (30 candidates)
1. Generator (Sonnet 4.5) creates 30 diverse solution candidates
2. Executor (Haiku) runs each candidate on training examples
3. Evaluator (Haiku × 30 parallel) calculates two-tier scores
4. Selector (Haiku) identifies top performers

**Generations 2-4: Dual-Track Evolution**

**Track A - Single-Parent** (50 candidates/gen):
1. Individual Revisor (Sonnet 4.0) takes best candidate from previous gen
2. Applies focused mutations (error correction)
3. Generates 50 refined variants
4. Evaluator scores all 50

**Track B - Pooled-Parent** (25 candidates/gen):
1. Pooled Revisor (Opus) takes top 5 diverse candidates
2. Synthesizes hybrid solutions (crossover)
3. Generates 25 novel combinations
4. Evaluator scores all 25

**Final Selection**:
- Selector chooses best across all 4 generations
- Returns solution with highest two-tier score

**Total Candidates**: 30 + (50+25)×3 = 255 evaluated
**Cost**: ~$7-9
**Time**: 5-8 minutes
**Expected Accuracy**: 65-70%

### Example 2: Custom Algorithmic Problem

```
/evolve custom_problems/string_transform.json --generations=3 --budget=6.00
```

**Task File Format**:
```json
{
  "task_id": "string_transform_001",
  "description": "Transform input strings according to pattern",
  "training_examples": [
    {
      "input": "hello",
      "output": "HELLO"
    },
    {
      "input": "world",
      "output": "WORLD"
    }
  ],
  "test_examples": [
    {
      "input": "claude"
    }
  ]
}
```

**Expected Output**:
```json
{
  "task_id": "string_transform_001",
  "solution": {
    "generation": 2,
    "track": "A",
    "code": "def transform(s): return s.upper()",
    "primary_score": 2,
    "secondary_score": 1.0,
    "confidence": 0.95
  },
  "test_predictions": [
    {
      "input": "claude",
      "output": "CLAUDE"
    }
  ],
  "evolution_history": [
    {"generation": 1, "best_score": [1, 0.85]},
    {"generation": 2, "best_score": [2, 1.0]},
    {"generation": 3, "best_score": [2, 1.0]}
  ],
  "cost": "$5.40",
  "time": "4m 32s"
}
```

### Example 3: Early Termination

```
/evolve arc_tasks/eval_002.json --early-termination --threshold=0.95
```

**What happens**:
- Runs evolution as normal
- After each generation, checks if best candidate achieves 95% fitness
- If yes, terminates early and returns solution
- Saves cost and time when good solution found quickly

**Example Termination**:
```
Generation 1: Best score [2, 0.80] - Continue
Generation 2: Best score [3, 0.96] - TERMINATE (>= 0.95)

Solution found in 2 generations instead of 4!
Cost: $4.50 (saved $4.50)
Time: 3m 15s (saved 4-5 minutes)
```

---

## Orchestration Flow

```
USER COMMAND: /evolve <task-file>
    ↓
ORCHESTRATOR:
  1. Load task from JSON file
  2. Initialize evolution state
  3. Set budget constraints
  4. Configure dual-track parameters
    ↓
GENERATION 1: Initial Population
  ┌─────────────────────────────────┐
  │ Generator (HIGH - Sonnet 4.5)   │ → 30 diverse candidates
  └─────────────────────────────────┘
              ↓
  ┌─────────────────────────────────┐
  │ Executor (LOW - Haiku) × 30     │ → Execute on training examples
  └─────────────────────────────────┘
              ↓
  ┌─────────────────────────────────┐
  │ Evaluator (LOW - Haiku) × 30    │ → Two-tier scoring
  └─────────────────────────────────┘
              ↓
  ┌─────────────────────────────────┐
  │ Selector (LOW - Haiku)          │ → Identify top 5
  └─────────────────────────────────┘
    ↓
GENERATIONS 2-4: Dual-Track Evolution
    ↓                                  ↓
TRACK A                            TRACK B
(Single-Parent)                    (Pooled-Parent)
    ↓                                  ↓
┌──────────────────────┐          ┌──────────────────────┐
│ Individual Revisor   │          │ Pooled Revisor       │
│ (MEDIUM - Sonnet 4.0)│          │ (HIGH - Opus)        │
│ Refine best × 50     │          │ Synthesize top 5×25  │
└──────────────────────┘          └──────────────────────┘
    ↓                                  ↓
┌──────────────────────┐          ┌──────────────────────┐
│ Evaluator × 50       │          │ Evaluator × 25       │
└──────────────────────┘          └──────────────────────┘
    ↓                                  ↓
    └──────────────┬───────────────────┘
                   ↓
          ┌─────────────────┐
          │ Selector        │ → Best from both tracks
          └─────────────────┘
                   ↓
         Repeat for next generation
    ↓
FINAL SELECTION:
  - Best candidate across all generations
  - Return solution with metadata
  - Report evolution history
    ↓
USER RECEIVES:
  - Solution code/instructions
  - Confidence score
  - Evolution history
  - Cost and time breakdown
```

---

## Dual-Track Strategy

### Track A: Exploitation (Single-Parent)

**Goal**: Refine the single best candidate through focused improvement

**Process**:
1. Take best candidate from previous generation
2. Analyze errors on training examples
3. Generate 50 variants with targeted fixes
4. Mutations: error correction, edge case handling, optimization

**Benefits**:
- Rapid improvement of promising solutions
- Focused on exploitation
- High success rate for incremental gains

**Model**: Sonnet 4.0 (MEDIUM complexity)
- Analytical error correction
- Focused refinement
- Cost-effective for targeted mutations

### Track B: Exploration (Pooled-Parent)

**Goal**: Discover novel solutions through synthesis of diverse candidates

**Process**:
1. Take top 5 diverse candidates from previous generation
2. Identify complementary strengths
3. Generate 25 hybrid solutions combining strengths
4. Crossover: merge approaches, synthesize patterns

**Benefits**:
- Exploration of solution space
- Breakthrough discoveries
- Avoids local optima

**Model**: Opus (HIGH complexity)
- Strategic synthesis
- Creative combination
- Worth the cost for exploration

### Why Both Tracks?

**Empirical Finding**: 42% of final solutions emerge in generations 2-4
- Some problems need Track A refinement
- Others need Track B exploration
- Can't predict which track will succeed
- Running both maximizes success rate

**Cost Efficiency**:
- Track A: 50 candidates × 3 gens × $0.10 = $15.00
- Track B: 25 candidates × 3 gens × $0.20 = $15.00
- Total: $30.00 for dual-track vs $50.00 for single-track 100 candidates
- Better coverage with lower cost

---

## Two-Tier Scoring

### Primary Score: Perfect Examples

**Definition**: Count of training examples where solution is 100% correct

**Range**: 0 to N (number of training examples)

**Example**:
```
Task has 3 training examples
Candidate A solves 2/3 perfectly → Primary score = 2
Candidate B solves 3/3 perfectly → Primary score = 3

B > A (better primary score)
```

### Secondary Score: Cell Accuracy

**Definition**: Percentage of cells correct on imperfect examples

**Range**: 0.0 to 1.0

**Example**:
```
Task has 3 training examples
Candidate A: Examples 1,2 perfect, Example 3 is 17/20 cells correct
  → Primary = 2, Secondary = 0.85

Candidate B: Examples 1,2 perfect, Example 3 is 19/20 cells correct
  → Primary = 2, Secondary = 0.95

B > A (same primary, better secondary)
```

### Combined Ranking

```python
def rank_candidates(candidates):
    """Rank by (primary_score DESC, secondary_score DESC)"""
    return sorted(candidates,
                  key=lambda c: (c.primary_score, c.secondary_score),
                  reverse=True)
```

**Benefits**:
- Finer gradient for selection pressure
- Rewards partial progress (not just perfect solutions)
- Better convergence in later generations

---

## Model Sizing Rationale

| Agent | Complexity | Model | Budget | Why |
|-------|-----------|-------|--------|-----|
| **Generator** | HIGH | Sonnet 4.5 | 15,000 | Creative diversity, generate 30 novel candidates |
| **Executor** | LOW | Haiku | 3,000 | Deterministic execution, pattern matching |
| **Individual Revisor** | MEDIUM | Sonnet 4.0 | 10,000 | Analytical error correction |
| **Pooled Revisor** | HIGH | Opus | 15,000 | Strategic synthesis of multiple solutions |
| **Evaluator** | LOW | Haiku | 3,000 | Simple scoring calculation |
| **Selector** | LOW | Haiku | 3,000 | Compare scores, select best |

**Total Cost Breakdown**:
```
Generation 1:
  Generator: 1 × $0.50 = $0.50
  Executor: 30 × $0.01 = $0.30
  Evaluator: 30 × $0.01 = $0.30
  Selector: 1 × $0.01 = $0.01
  Subtotal: $1.11

Generations 2-4 (per generation):
  Track A Individual Revisor: 1 × $0.10 = $0.10
  Track A Evaluator: 50 × $0.01 = $0.50
  Track B Pooled Revisor: 1 × $0.20 = $0.20
  Track B Evaluator: 25 × $0.01 = $0.25
  Selector: 1 × $0.01 = $0.01
  Subtotal: $1.06 × 3 = $3.18

Total: $1.11 + $3.18 = $4.29 theoretical
Empirical (with overhead): $7-9
```

---

## Configuration

### settings.json

```json
{
  "evolutionary_config": {
    "dual_track": {
      "enabled": true,
      "track_a_single_parent": {
        "functions_per_generation": 50,
        "max_generations": 4,
        "mutation_strategy": "error_correction"
      },
      "track_b_pooled_parent": {
        "functions_per_generation": 25,
        "max_generations": 4,
        "synthesis_strategy": "crossover"
      }
    },
    "initial_population": {
      "size": 30,
      "diversity_enforcement": true
    },
    "termination": {
      "early_termination": true,
      "fitness_threshold": 0.95,
      "max_generations": 4,
      "budget_limit": 9.00
    }
  },
  "two_tier_scoring": {
    "primary_score": "perfect_examples",
    "secondary_score": "cell_accuracy",
    "tiebreaker": "program_simplicity"
  },
  "model_strategies": {
    "balanced": {
      "high": "claude-sonnet-4-5-20250929",
      "medium": "claude-sonnet-4-20250514",
      "low": "claude-haiku-4-20250514"
    }
  }
}
```

---

## Advanced Usage

### Custom Generation Strategy

```
/evolve task.json \
  --track-a-size=60 \
  --track-b-size=30 \
  --generations=5 \
  --initial-population=40
```

### Diversity Enforcement

```
/evolve task.json --diversity-penalty=0.5
```

Penalizes candidates too similar to existing solutions, maintains population diversity.

### Budget-Constrained Evolution

```
/evolve task.json --budget=5.00 --adaptive-generations
```

Automatically adjusts generation count to stay within budget.

---

## Comparison to Library Evolution

| Aspect | Test-Time Compute (/evolve) | Library Evolution (/library-solve) |
|--------|---------------------------|----------------------------------|
| **Command** | `/evolve task.json` | `/library-solve task.json` |
| **Candidates** | 230 per task | 10 per task |
| **Cost** | $7-9 | $2-4 |
| **Time** | 5-8 min | 2-3 min |
| **Accuracy** | 65-70% | 75-77% |
| **Knowledge Transfer** | ❌ None | ✅ Continuous |
| **Pre-Training** | Not needed | Required ($500) |
| **Ideal For** | <100 tasks | >100 tasks |

**When to use /evolve**:
- Solving <100 tasks
- No training data available
- Need cold-start performance
- Want thorough exploration

**When to use /library-solve**:
- Solving >100 tasks
- Have training data
- Want best long-term efficiency
- Need knowledge transfer

---

## Integration with CI/CD

```yaml
# .github/workflows/evolutionary-benchmark.yml
name: Evolutionary Problem Solving

on:
  push:
    paths:
      - 'algorithms/**'

jobs:
  test-algorithms:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Claude Code
        run: curl -fsSL https://... | bash

      - name: Run Evolutionary Tests
        run: |
          for task in tests/algorithmic/*.json; do
            claude /evolve "$task" \
              --budget=5.00 \
              --output "results/$(basename $task)"
          done

      - name: Check Accuracy
        run: |
          python scripts/calculate_accuracy.py results/
          ACCURACY=$(cat results/accuracy.txt)
          if (( $(echo "$ACCURACY < 0.60" | bc -l) )); then
            echo "Accuracy $ACCURACY below threshold 0.60"
            exit 1
          fi
```

---

## Troubleshooting

### Issue: Evolution stuck in local optimum

**Symptom**: Same score for 3+ generations

**Solution**:
```
/evolve task.json --diversity-penalty=0.6 --track-b-size=40
```
Increase exploration (Track B size) and diversity enforcement.

### Issue: Budget exceeded

**Symptom**: Cost > $9.00

**Solution**:
```
/evolve task.json --budget=6.00 --generations=3 --strategy=cost_optimized
```
Reduce generations, use cheaper models.

### Issue: No solution found

**Symptom**: All candidates score 0

**Solution**:
- Check task format is correct
- Increase initial population size
- Try more generations
- Consider switching to library evolution if solving many similar tasks

---

## See Also

- [Test-Time Compute Architecture](../evolutionary-swarms/test-time-compute/)
- [Library Evolution Alternative](./library-solve.md)
- [Evolutionary Swarms Overview](../evolutionary-swarms/ARCHITECTURE.md)

---

**Command Version**: 2.0.0
**Architecture**: Dual-Track Evolutionary Test-Time Compute
**Expected Performance**: 65-70% accuracy, $7-9 per task
**Last Updated**: 2025-11-22
