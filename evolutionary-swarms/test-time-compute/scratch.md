# Evolutionary Test-Time Compute Architecture Audit

**Date**: 2025-01-19
**Purpose**: Compare my initial agent-based implementation against actual Jeremy Berman codebase and derivatives
**Repositories Analyzed**:
1. `jerber/arc-lang-public` (Berman's v2 - natural language instructions)
2. `jerber/arc_agi` (Berman's v1 - Python functions)
3. `epang080516/arc_agi` (C.T. Pang's library-based evolution)

---

## Repository 1: jerber/arc-lang-public (Berman v2)

### Overview
This is Jeremy Berman's **latest implementation** using natural language instructions instead of Python functions. This aligns with the Substack article I based my architecture on.

### Key Findings

#### Architecture Pattern
- **Iterative instruction-generation pipeline**, NOT traditional genetic algorithms
- Uses **feedback-driven revision** instead of mutation/crossover
- **Asynchronous parallel execution** with semaphore-controlled concurrency
- Three refinement mechanisms:
  - `Step`: Initial generation
  - `StepRevision`: Individual repair with error feedback
  - `StepRevisionPool`: Multi-candidate synthesis

#### Model Usage Strategy
- **Pluggable model providers**: Grok, GPT, Claude, Gemini, DeepSeek, OpenRouter
- Each step can use different models (`instruction_model` vs `follow_model`)
- **Two LLM calls per candidate**:
  1. Generate instruction (instruction_model)
  2. Execute instruction on grids (follow_model)
- Concurrency controlled via `MAX_CONCURRENCY` environment variable

#### Evaluation Mechanism
- **Leave-one-out cross-validation** on training grids
- **Cell-wise similarity metrics** for scoring
- Per-example score visibility enables targeted revision

#### Key Files
```
src/run.py              # Async orchestration
src/main.py             # Prompt builders
src/configs/            # RunConfig presets
src/llms/structured.py  # Provider wrappers
src/models.py           # Pydantic models
attempts/               # JSON outputs
```

### Comparison to My Implementation

| Aspect | My Implementation | arc-lang-public |
|--------|------------------|-----------------|
| **Generation** | Single generator agent | Step system with configs |
| **Execution** | Evaluator agent interprets instructions | Separate follow_model LLM call |
| **Revision** | Individual + Pooled revisor agents | StepRevision + StepRevisionPool |
| **Model Selection** | High/Med/Low abstraction | instruction_model + follow_model per step |
| **Concurrency** | Hardcoded 10 parallel evaluators | Configurable semaphore |
| **Output Format** | JSON fitness scores | Structured provider outputs |

### Gaps in My Implementation
❌ **Two-model pattern**: I don't separate instruction generation from execution
❌ **Provider-specific structured output**: No native integration
❌ **Leave-one-out validation**: I evaluate on all training examples simultaneously
❌ **Async execution with semaphore**: I described parallel but didn't implement properly
❌ **Configurable steps**: My phases are hardcoded, not pluggable

### Strengths of My Implementation
✅ **High/Med/Low cost optimization**: More granular than their approach
✅ **Benchmarking framework**: Built-in strategy comparison
✅ **Plugin architecture**: Swappable model strategies
✅ **Clear evolutionary metaphor**: Mutation/crossover language

---

## Repository 2: jerber/arc_agi (Berman v1)

### Overview
This is Jeremy Berman's **original December 2024 solution** that achieved 53.6% on ARC-AGI v1 using **Python functions** instead of natural language instructions. This is the solution described in his first Substack article.

### Key Findings

#### Dual-Track Evolution
- **Track A (Single-Parent)**: ~100 functions per generation × 4 generations
- **Track B (Pooled-Parent)**: Combines multiple successful functions
- **Hybrid allocation**: Computational budget split between both tracks

#### Generational Depth Analysis
- **4 generations × 50 functions** outperformed **1 generation × 200 functions**
- 75% vs 70% accuracy
- **42% of solutions emerged in generations 2-4** (not generation 1!)
- Validates iterative refinement hypothesis

#### Prompt Engineering
- **Chain-of-thought prompting** before code generation
- **One-shot learning** outperformed multi-shot
- **Multi-format grid representation**: ASCII + Base64 images + nested lists + dimensions
- **Revision prompts**: Show parent function code to guide mutations

#### Scoring System
- **Primary score**: Number of training examples solved perfectly
- **Secondary score**: Individual cell accuracy for partial solutions
- Fine-grained selection pressure even without perfect solutions

#### Cost Structure
- Pooled prompts cost **2× single-parent versions**
- Strategic allocation across both tracks

### Comparison to My Implementation

| Aspect | My Implementation | arc_agi (v1) |
|--------|------------------|--------------|
| **Solution Format** | Natural language instructions | Python functions |
| **Track Strategy** | Single evolutionary path | Dual-track (single + pooled) |
| **Generations** | Up to 3 (configurable) | 4 generations optimized |
| **Diversity Mechanism** | 6 diversity prompts | Pooled-parent track |
| **Scoring** | Single fitness metric | Two-tier (perfect + partial) |
| **Grid Format** | Not specified | Multi-format (ASCII + Base64 + lists) |

### Critical Insights

🔑 **Generational depth matters**: 42% of solutions require 2+ evolutionary cycles
🔑 **Dual tracks prevent local maxima**: Single-parent alone converges prematurely
🔑 **Two-tier scoring enables fine selection**: Can rank candidates even when none are perfect
🔑 **Multi-format representation**: Different formats help LLM understand patterns

### Gaps in My Implementation
❌ **Dual-track evolution**: I only have single evolutionary path with individual + pooled
❌ **Multi-format grid encoding**: I don't encode grids in multiple formats
❌ **Two-tier scoring**: My fitness is single-dimensional
❌ **Generational tracking**: I don't specifically optimize for 4 generations
❌ **Cost allocation strategy**: No explicit budget splitting

### Strengths of My Implementation
✅ **More flexible model selection**: High/Med/Low vs uniform
✅ **Plugin strategies**: Can test different approaches
✅ **Natural language**: Easier to debug than Python (v2 approach)

---

## Repository 3: epang080516/arc_agi (C.T. Pang - Library Evolution)

### Overview
Built on Berman's work but introduces **knowledge transfer across tasks** using a **learned library** of programs. Achieved **77.1% on ARC-AGI v1** (vs Berman's 53.6%) and **26.0% on ARC-AGI v2** at **$2.56 per task** (vs Berman's $29).

### Key Findings

#### Library-Based Evolution
- **Maintains expanding library** of Python programs learned across tasks
- **Reuses best programs** from library in prompts for new tasks
- **Transfers knowledge** between problems (unlike Berman's isolated approach)
- Pre-trained library from 1,000 tasks → 538 programs

#### Cost Efficiency
- **~10 LLM calls per task** (vs Berman's ~500)
- **$2.56 per task** (vs Berman's $29)
- **11× cost reduction** while improving accuracy

#### Performance Gains
- **77.1% on ARC-AGI-1** (vs Berman's 53.6%) = **+23.5pp improvement**
- **26.0% on ARC-AGI-2** (vs Berman's 29.4% with v2 approach)

#### Novel Techniques
1. **Empty-start library design**: No handcrafted DSL (avoids human bias)
2. **Score-weighted sampling**: Softmax probability vs deterministic ranking
3. **Program output differences**: Shows expected vs actual to LLM
4. **Multi-format grid encoding**: Dimensions + Base64 + ASCII + lists

#### Two-Phase Process
**Training Phase**:
- Run on 1,000 training tasks
- 1 round, 1 program per task
- Build library of 538 programs

**Evaluation Phase**:
- 2 rounds on eval set
- 5 programs per task per round
- Best program added to library for subsequent tasks

### Comparison to My Implementation

| Aspect | My Implementation | epang's Library Approach |
|--------|------------------|--------------------------|
| **Knowledge Transfer** | None (task-isolated) | Cross-task library |
| **Calls per Task** | 40 (30 init + 5 + 5) | ~10 |
| **Cost per Task** | $7-9 (estimated) | $2.56 |
| **Library** | No persistent knowledge | 538 programs from 1,000 tasks |
| **Sampling** | Fitness ranking | Softmax score-weighted |
| **Approach** | Pure evolution per task | Meta-learning across tasks |

### Critical Insights

🔑 **Knowledge transfer >> pure evolution**: Library approach 11× cheaper and more accurate
🔑 **Meta-learning is key**: Solving task N helps solve task N+1
🔑 **Score-weighted sampling**: Better than deterministic top-K selection
🔑 **Fewer, smarter generations**: 10 calls beat 500 calls when library exists
🔑 **Breaks Pareto frontier**: Superior performance-per-dollar

### Gaps in My Implementation
❌ **No library/memory**: Each task solved from scratch
❌ **No knowledge transfer**: Can't learn from previous tasks
❌ **No meta-learning**: No concept of "useful primitives"
❌ **Deterministic selection**: No probabilistic sampling
❌ **Task isolation**: Each problem treated independently

### Strengths of My Implementation
✅ **Model flexibility**: Can use different models per phase
✅ **Cost transparency**: Track spend per complexity tier
✅ **Benchmarking**: Compare strategies empirically

---

## Critical Architecture Gaps Identified

### Gap 1: Two-Model Pattern (from arc-lang-public)
**Current**: Single model generates and "executes" instructions mentally
**Should be**: One model generates instruction, separate model follows it

**Why it matters**:
- Separates creative generation from deterministic execution
- Can use HIGH for generation, LOW for execution
- Mirrors actual LLM capability separation

### Gap 2: Dual-Track Evolution (from arc_agi v1)
**Current**: Single evolutionary path with individual + pooled phases
**Should be**: Parallel Track A (single-parent) + Track B (pooled-parent)

**Why it matters**:
- Prevents premature convergence
- 42% of solutions require deeper evolution
- Diversity preservation critical

### Gap 3: Two-Tier Fitness Scoring (from arc_agi v1)
**Current**: Single fitness = % correct cells
**Should be**: Primary (perfect examples) + Secondary (cell accuracy)

**Why it matters**:
- Fine-grained selection when no perfect solutions exist
- Prevents ties in ranking
- Guides evolution toward partial improvements

### Gap 4: Multi-Format Grid Encoding (from arc_agi v1)
**Current**: Abstract grid representation
**Should be**: ASCII + Base64 images + nested lists + dimensions simultaneously

**Why it matters**:
- Different formats expose different patterns to LLM
- Visual + symbolic + structural representations
- Increases solution discovery rate

### Gap 5: Knowledge Transfer / Library (from epang's approach)
**Current**: Task-isolated evolution
**Should be**: Maintain library of successful patterns across tasks

**Why it matters**:
- 11× cost reduction ($29 → $2.56)
- 23.5pp accuracy improvement
- Meta-learning >> pure per-task evolution
- Actually achieves what Agent Toolkit V2 aimed for (skill reuse)

### Gap 6: Async Execution with Proper Concurrency (from arc-lang-public)
**Current**: Described parallel execution but not implemented
**Should be**: Semaphore-controlled async with configurable limits

**Why it matters**:
- Actual runtime performance
- API rate limit compliance
- Cost control through concurrency tuning

### Gap 7: Generational Depth Optimization (from arc_agi v1)
**Current**: Up to 3 generations configurable
**Should be**: Optimized for 4 generations based on empirical results

**Why it matters**:
- 4 gen × 50 > 1 gen × 200 (75% vs 70%)
- 42% solutions emerge gen 2-4
- Hardcode based on research

---

## Recommended Actions

### Option A: Enhance Existing Architecture (Incremental)
✅ Add two-model pattern (instruction + follow)
✅ Implement two-tier scoring (primary + secondary)
✅ Add multi-format grid encoding
✅ Improve to 4 generations default
✅ Add dual-track evolution

**Pros**: Builds on existing work, maintains continuity
**Cons**: Still task-isolated, doesn't address biggest gap (library)

### Option B: Create Library-Based v2 (Revolutionary)
✅ Implement persistent library system
✅ Knowledge transfer across tasks
✅ Score-weighted sampling
✅ Meta-learning framework
✅ Two-phase training/evaluation

**Pros**: Addresses biggest performance/cost gap, novel architecture
**Cons**: Complete redesign, more complex

### Option C: Both (Recommended)
1. **Enhance v1** with quick wins:
   - Two-model pattern
   - Two-tier scoring
   - Multi-format encoding
   - Dual-track evolution

2. **Create v2** with library approach:
   - Full meta-learning system
   - Knowledge transfer
   - Score-weighted sampling
   - Persistent library

**Pros**: Compare approaches empirically, maximize learning
**Cons**: More work, but user requested "do both if value"

---

## Architectural Insights for v2 (Library-Based)

### Core Concept
Instead of solving each task independently, maintain a **learned library** of useful transformation primitives that can be composed to solve new tasks.

### Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    LIBRARY-BASED EVOLUTION                   │
└─────────────────────────────────────────────────────────────┘

Initialization:
┌──────────────────────────────────────────────────────────────┐
│  Load Pre-trained Library                                     │
│  └─ 538 programs from 1,000 training tasks                   │
└──────────────────────────────────────────────────────────────┘

For each task:
┌──────────────────────────────────────────────────────────────┐
│  1. Retrieve Relevant Programs from Library                   │
│     └─ Score-weighted sampling based on similarity           │
└──────────────────────────────────────────────────────────────┘
                           ↓
┌──────────────────────────────────────────────────────────────┐
│  2. Generate New Programs (using library as context)          │
│     └─ LLM sees: task + training examples + library programs │
└──────────────────────────────────────────────────────────────┘
                           ↓
┌──────────────────────────────────────────────────────────────┐
│  3. Evaluate Programs (primary + secondary scoring)           │
└──────────────────────────────────────────────────────────────┘
                           ↓
┌──────────────────────────────────────────────────────────────┐
│  4. Select Best Program                                       │
└──────────────────────────────────────────────────────────────┘
                           ↓
┌──────────────────────────────────────────────────────────────┐
│  5. Add to Library (knowledge transfer)                       │
│     └─ Now available for future tasks                        │
└──────────────────────────────────────────────────────────────┘

Result: 11× cheaper, 23.5pp more accurate
```

### Key Mechanisms

1. **Library Initialization**
   - Empty start (no handcrafted DSL)
   - Train on 1,000 tasks → 538 unique programs
   - Programs are Python functions with docstrings

2. **Retrieval Strategy**
   - Score-weighted softmax sampling (not deterministic top-K)
   - Similarity based on grid dimensions, colors, patterns
   - Include diverse programs (not just best)

3. **Context Construction**
   - Task description
   - Training examples (multi-format)
   - Relevant library programs with scores
   - Expected vs actual differences for failures

4. **Generation Strategy**
   - ~10 LLM calls per task (vs 500 in pure evolution)
   - 2 rounds × 5 programs per round
   - HIGH complexity for generation
   - LOW complexity for execution

5. **Library Update**
   - Best program added after each task
   - Continuous expansion
   - No pruning (all programs kept)

### Cost Model
```
Pure Evolution (Berman v1):
  500 LLM calls × $0.058 = $29 per task

Library Evolution (Pang):
  10 LLM calls × $0.256 = $2.56 per task

Savings: 91% reduction
```

### Performance Model
```
Pure Evolution (Berman v1):
  ARC-AGI-1: 53.6%

Library Evolution (Pang):
  ARC-AGI-1: 77.1% (+23.5pp)
  ARC-AGI-2: 26.0%

Improvement: 44% relative improvement
```

---

## Decision Matrix

| Criterion | Enhance v1 | Library v2 | Both |
|-----------|-----------|-----------|------|
| **Cost to implement** | Low | High | High |
| **Performance gain** | Moderate (+10-15%) | Large (+40-50%) | Large |
| **Cost efficiency** | Moderate (2× better) | Excellent (11× better) | Excellent |
| **Novelty** | Incremental | Revolutionary | Both |
| **Risk** | Low | Medium | Medium |
| **Learning value** | Moderate | High | Maximum |
| **User request alignment** | Partial | Partial | Full |

**User said**: "if you see value in it; do both; upgrade the older version and try a new approach using new architectural concepts"

**Recommendation**: **BOTH** - Enhance v1 with quick wins, create library-based v2

---

## Implementation Plan

### Phase 1: Enhance evolutionary-compute-test (v1 improvements)
1. Add two-model pattern (instruction_model + follow_model)
2. Implement two-tier scoring (primary + secondary fitness)
3. Add multi-format grid encoding (ASCII + Base64 + lists + dims)
4. Implement dual-track evolution (Track A + Track B)
5. Optimize for 4 generations default
6. Update plugin configs to support new features
7. Document improvements in README

**Estimated effort**: 2-3 hours
**Expected improvement**: +10-15% accuracy, 2× cost efficiency

### Phase 2: Create evolutionary-compute-library (v2 new architecture)
1. Design library-based architecture
2. Implement library initialization and storage
3. Create retrieval mechanism (score-weighted sampling)
4. Build context construction with multi-format grids
5. Implement two-phase training/evaluation
6. Add library update mechanism
7. Create benchmarking vs v1
8. Full documentation

**Estimated effort**: 4-6 hours
**Expected improvement**: +40-50% accuracy, 11× cost efficiency

### Success Criteria
- v1 enhanced achieves 65-70% estimated accuracy
- v2 library-based achieves 75-78% estimated accuracy
- v2 costs $2-4 per task vs v1's $7-9
- Both fully documented with clear architectural explanations
- Empirical comparison showing trade-offs

---

## Key Takeaways

1. **My initial implementation was philosophically correct** but missed critical implementation details from actual codebases

2. **The biggest gap is knowledge transfer** - library-based approach is 11× cheaper and 44% more accurate

3. **Two-model pattern is crucial** - separate instruction generation from execution for cost efficiency

4. **Multi-format encoding matters** - different representations expose different patterns

5. **Dual-track evolution prevents local maxima** - need both single-parent and pooled-parent tracks

6. **Generational depth is optimized** - 4 generations empirically proven, 42% solutions emerge in gen 2-4

7. **Score-weighted sampling > deterministic ranking** - probabilistic selection maintains diversity

8. **Agent Toolkit V2's skill reuse concept** actually manifests as learned program libraries in this domain

**Bottom line**: Create both versions to demonstrate the evolution from pure evolutionary compute (v1) to meta-learning library-based approach (v2).
