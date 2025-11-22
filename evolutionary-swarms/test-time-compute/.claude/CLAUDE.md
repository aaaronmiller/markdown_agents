# Evolutionary Test-Time Compute Swarm

**Architecture**: Plugin-based evolutionary compute with high/med/low model selection
**Version**: 1.0.0
**Based on**: Jeremy Berman's ARC-AGI solution methodology

## Architecture Overview

This swarm implements **Evolutionary Test-Time Compute** - an approach where multiple solution candidates are generated, evaluated, and evolved through selective breeding of high-performing solutions.

### Core Principle

Instead of generating a single solution, we:
1. Generate a **population** of diverse solution candidates
2. **Evaluate fitness** of each candidate against training examples
3. **Evolve** top performers through individual and pooled revisions
4. **Iterate** until optimal solution found or compute budget exhausted

### Evolutionary Cycle

```
┌─────────────────────────────────────────────────────────────┐
│                    EVOLUTIONARY CYCLE                        │
└─────────────────────────────────────────────────────────────┘

Phase 1: INITIAL GENERATION (Population Size: 30)
┌──────────────────────────────────────────────────────────────┐
│  Generator Agent (HIGH)                                       │
│  ├─ Generate 30 diverse solution candidates                  │
│  ├─ Each candidate is a natural language instruction         │
│  └─ Diversity prompting ensures exploration                  │
└──────────────────────────────────────────────────────────────┘
                           ↓
┌──────────────────────────────────────────────────────────────┐
│  Evaluator Agent (LOW) - Parallel Execution                  │
│  ├─ Test each candidate against training examples            │
│  ├─ Calculate fitness score (% correct cells)                │
│  └─ Rank candidates by fitness                               │
└──────────────────────────────────────────────────────────────┘
                           ↓
                   Perfect Solution? → YES → DONE
                           ↓ NO

Phase 2: INDIVIDUAL REVISION (Top 5)
┌──────────────────────────────────────────────────────────────┐
│  Individual Revisor Agent (MEDIUM)                           │
│  ├─ Take top 5 candidates                                    │
│  ├─ Show each its outputs vs. ground truth                   │
│  ├─ Generate refined version addressing errors               │
│  └─ Produces 5 new candidates                                │
└──────────────────────────────────────────────────────────────┘
                           ↓
┌──────────────────────────────────────────────────────────────┐
│  Evaluator Agent (LOW) - Re-evaluate                         │
│  └─ Test revised candidates, update rankings                 │
└──────────────────────────────────────────────────────────────┘
                           ↓
                   Perfect Solution? → YES → DONE
                           ↓ NO

Phase 3: POOLED REVISION (Top 5 Combined)
┌──────────────────────────────────────────────────────────────┐
│  Pooled Revisor Agent (HIGH)                                 │
│  ├─ Take top 5 candidates from all generations               │
│  ├─ Show all outputs + ground truth in single context        │
│  ├─ Synthesize new solutions combining best elements         │
│  └─ Generate 5 new hybrid candidates                         │
└──────────────────────────────────────────────────────────────┘
                           ↓
┌──────────────────────────────────────────────────────────────┐
│  Evaluator Agent (LOW) - Final evaluation                    │
│  └─ Test pooled candidates, select best                      │
└──────────────────────────────────────────────────────────────┘
                           ↓
                     Return Best Solution

Total Candidates: 30 initial + 5 individual + 5 pooled = 40 max
```

## Model Selection Strategy

### HIGH Complexity (Opus / Sonnet 4.5)
**Use for**: Strategic generation, creative synthesis
- **Generator Agent**: Requires creative diversity in solution generation
- **Pooled Revisor**: Must synthesize insights from multiple solutions
- **Thinking Budget**: 15,000-20,000 tokens

### MEDIUM Complexity (Sonnet 4.0)
**Use for**: Focused refinement, analytical comparison
- **Individual Revisor**: Analyze single solution and improve it
- **Fitness Analyzer**: Interpret why solutions fail/succeed
- **Thinking Budget**: 8,000-12,000 tokens

### LOW Complexity (Haiku)
**Use for**: Deterministic evaluation, fast execution
- **Evaluator Agent**: Execute instructions and compare outputs
- **Scorer**: Calculate fitness metrics
- **Thinking Budget**: 2,000-5,000 tokens

## Plugin Architecture

### Configuration Files

**`plugins/model-config.yaml`** - Swappable model configurations:
```yaml
strategies:
  cost_optimized:
    high: sonnet-4.0
    medium: sonnet-3.5
    low: haiku

  performance_optimized:
    high: opus
    medium: sonnet-4.5
    low: sonnet-4.0

  balanced:
    high: sonnet-4.5
    medium: sonnet-4.0
    low: haiku
```

**`plugins/evolution-config.yaml`** - Evolutionary parameters:
```yaml
parameters:
  initial_population: 30
  individual_revision_count: 5
  pooled_revision_count: 5
  max_generations: 3
  fitness_threshold: 1.0  # Perfect score
  parallel_evaluations: true
```

**`plugins/problem-types.yaml`** - Problem-specific strategies:
```yaml
problem_types:
  pattern_recognition:
    generator_prompts: "diverse_patterns"
    emphasis: "visual_reasoning"

  logical_deduction:
    generator_prompts: "logical_rules"
    emphasis: "step_by_step_reasoning"
```

## Agent Roles

### 1. Generator Agent (HIGH)
**Role**: Generate diverse solution candidates
**Model**: High complexity (Opus/Sonnet 4.5)
**Input**: Problem statement + training examples
**Output**: Natural language instruction describing solution approach
**Prompt Strategy**: Diversity-focused prompts to explore solution space

### 2. Evaluator Agent (LOW)
**Role**: Test candidates against examples, calculate fitness
**Model**: Low complexity (Haiku)
**Input**: Candidate instruction + test examples
**Output**: Fitness score (0.0-1.0) + execution trace
**Optimization**: Parallel execution across all candidates

### 3. Individual Revisor Agent (MEDIUM)
**Role**: Refine single solutions based on errors
**Model**: Medium complexity (Sonnet 4.0)
**Input**: Candidate + outputs + ground truth + diff
**Output**: Refined candidate instruction
**Strategy**: Focused error correction

### 4. Pooled Revisor Agent (HIGH)
**Role**: Synthesize multiple solutions into improved hybrids
**Model**: High complexity (Opus/Sonnet 4.5)
**Input**: Top N candidates + all outputs + ground truth
**Output**: New candidate combining best elements
**Strategy**: Creative recombination

### 5. Orchestrator Agent (MEDIUM)
**Role**: Manage evolutionary cycles, track fitness, decide next phase
**Model**: Medium complexity (Sonnet 4.0)
**Responsibilities**:
- Initialize population
- Track fitness across generations
- Decide when to transition between phases
- Select candidates for revision
- Manage compute budget

## Fitness Scoring

```python
def calculate_fitness(predicted_output, ground_truth):
    """
    Fitness = (correct_cells / total_cells)

    Perfect match = 1.0
    Partial match = 0.0-1.0
    Complete mismatch = 0.0
    """
    if predicted_output.shape != ground_truth.shape:
        return 0.0

    correct_cells = np.sum(predicted_output == ground_truth)
    total_cells = ground_truth.size

    return correct_cells / total_cells
```

## Evolutionary Operators

### Selection
- **Fitness-based ranking**: Sort candidates by fitness score
- **Top-K selection**: Select best 5 for revision
- **Diversity preservation**: Ensure varied approaches in population

### Mutation (Individual Revision)
- Single candidate + error feedback → refined candidate
- Focused on correcting specific mistakes
- Maintains core approach while fixing flaws

### Crossover (Pooled Revision)
- Multiple candidates → hybrid candidate
- Combines successful patterns from different solutions
- Creative synthesis of approaches

## Compute Budget Management

```
Initial Generation:   30 candidates × HIGH model   = 30 × cost_high
Individual Revision:   5 candidates × MEDIUM model =  5 × cost_medium
Pooled Revision:       5 candidates × HIGH model   =  5 × cost_high

Total: 35×cost_high + 5×cost_medium + 40×cost_low (evaluations)
```

**Budget controls**:
- Early stopping if perfect solution found
- Configurable population sizes
- Optional generation limits
- Parallel evaluation for speed

## Benchmarking Framework

Track performance across:
- **Accuracy**: Final solution correctness
- **Cost**: Total compute spend per problem
- **Speed**: Wall-clock time to solution
- **Generations**: Number of evolutionary cycles
- **Model efficiency**: Performance by model tier

**Benchmark outputs**:
```json
{
  "problem_id": "arc_001",
  "result": "correct",
  "fitness": 1.0,
  "generations": 2,
  "cost": {
    "high": 35,
    "medium": 5,
    "low": 40
  },
  "time_ms": 45000,
  "best_generation": "pooled_revision",
  "model_config": "balanced"
}
```

## Usage

### Standard Mode
```bash
# Run with balanced model configuration
python orchestrator.py --problem arc_problem.json --strategy balanced

# Run with cost optimization
python orchestrator.py --problem arc_problem.json --strategy cost_optimized

# Run with performance optimization
python orchestrator.py --problem arc_problem.json --strategy performance_optimized
```

### Benchmark Mode
```bash
# Test all strategies against problem set
python benchmark.py --problems arc_benchmark/ --all-strategies

# Compare model configurations
python benchmark.py --problems arc_benchmark/ --compare-models
```

## Key Innovations

1. **Plugin Model Selection**: Test arbitrary model combinations
2. **High/Med/Low Abstraction**: Task-appropriate model sizing
3. **Evolutionary Refinement**: Solutions improve through generations
4. **Fitness-Based Selection**: Best solutions propagate
5. **Hybrid Solutions**: Pool best elements from multiple approaches
6. **Benchmarkable**: Track performance across configurations

## Advantages Over Single-Shot Generation

- **Exploration**: 40 diverse attempts vs. 1 attempt
- **Evolution**: Solutions improve through feedback
- **Robustness**: Less sensitive to initial generation quality
- **Efficiency**: Use cheap models for evaluation, expensive models for strategy
- **Hybrid Vigor**: Combine strengths of multiple approaches

## Expected Performance

Based on Jeremy Berman's results:
- **ARC-AGI v1**: 79.6% accuracy
- **ARC-AGI v2**: 29.4% accuracy (previous SoTA: 25%)
- **Cost**: $8.42 per task (25× more efficient than o3)

With high/med/low optimization:
- **Expected cost reduction**: 30-50% vs. all-high-complexity
- **Maintained accuracy**: Within 5% of all-high-complexity
- **Speed improvement**: 2-3× faster through parallel low-complexity evaluation

---

**Ready to evolve solutions. Awaiting problem specification.**
