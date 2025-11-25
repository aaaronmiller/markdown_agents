#!/bin/bash
################################################################################
# deploy-evolutionary.sh
#
# Deploy dual-track evolutionary test-time compute for complex problem-solving
#
# Usage:
#   ./deploy-evolutionary.sh <task-file> [output-file] [options]
#
# Examples:
#   ./deploy-evolutionary.sh arc_tasks/eval_001.json
#   ./deploy-evolutionary.sh custom_task.json solution.json --generations=3 --budget=6.00
#   ./deploy-evolutionary.sh problem.json output.json --early-termination --threshold=0.95
#
################################################################################

set -euo pipefail

# Configuration
SWARM_REPO="${HOME}/markdown_agents/evolutionary-swarms/test-time-compute"
DEFAULT_GENERATIONS=4
DEFAULT_BUDGET="9.00"
DEFAULT_STRATEGY="balanced"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
TASK_FILE="${1:-}"
OUTPUT_FILE="${2:-solution.json}"
GENERATIONS="${3:-$DEFAULT_GENERATIONS}"
BUDGET="${4:-$DEFAULT_BUDGET}"
STRATEGY="${5:-$DEFAULT_STRATEGY}"

# Validate arguments
if [[ -z "$TASK_FILE" ]]; then
    echo -e "${RED}Error: Missing required task file${NC}"
    echo "Usage: $0 <task-file> [output-file] [generations] [budget] [strategy]"
    echo ""
    echo "Example task format (JSON):"
    cat <<'EOF'
{
  "task_id": "example_001",
  "training_examples": [
    {"input": [[0,1]], "output": [[1,0]]},
    {"input": [[1,0]], "output": [[0,1]]}
  ]
}
EOF
    exit 1
fi

if [[ ! -f "$TASK_FILE" ]]; then
    echo -e "${RED}Error: Task file not found: ${TASK_FILE}${NC}"
    exit 1
fi

if [[ ! -d "$SWARM_REPO" ]]; then
    echo -e "${RED}Error: Evolutionary swarm not found at ${SWARM_REPO}${NC}"
    exit 1
fi

# Create temporary workspace
WORKSPACE="/tmp/evolutionary-$(date +%s)-${RANDOM}"
echo -e "${YELLOW}Creating workspace: ${WORKSPACE}${NC}"
mkdir -p "${WORKSPACE}"

# Copy swarm configuration to workspace
echo -e "${YELLOW}Loading dual-track evolutionary compute swarm...${NC}"
cp -r "${SWARM_REPO}/.claude" "${WORKSPACE}/"

# Copy task file to workspace
cp "${TASK_FILE}" "${WORKSPACE}/task.json"

# Navigate to workspace
cd "${WORKSPACE}"

# Display task info
echo -e "${BLUE}Task Information:${NC}"
TASK_ID=$(cat task.json | jq -r '.task_id // "unknown"')
TRAINING_COUNT=$(cat task.json | jq '.training_examples | length')
echo "  Task ID: ${TASK_ID}"
echo "  Training Examples: ${TRAINING_COUNT}"
echo "  Generations: ${GENERATIONS}"
echo "  Budget: \$${BUDGET}"
echo "  Strategy: ${STRATEGY}"
echo ""

# Prepare prompt
FULL_PROMPT="$(cat <<EOF
Solve the task in task.json using dual-track evolutionary test-time compute.

CONFIGURATION:
- Generations: ${GENERATIONS}
- Budget: \$${BUDGET}
- Strategy: ${STRATEGY}

DUAL-TRACK EVOLUTION:
- Track A (Single-Parent): 50 candidates/generation, focused refinement
- Track B (Pooled-Parent): 25 candidates/generation, strategic synthesis

PROCESS:
Generation 1:
  1. Generate 30 diverse initial candidates
  2. Evaluate all 30 on training examples
  3. Calculate two-tier scores (perfect examples, cell accuracy)
  4. Select top performers

Generations 2-${GENERATIONS}:
  Track A:
    - Refine best candidate (error correction)
    - Generate 50 focused variants
    - Evaluate all 50

  Track B:
    - Synthesize top 5 candidates (crossover)
    - Generate 25 hybrid solutions
    - Evaluate all 25

  - Select best across both tracks

FINAL:
  - Return best solution from any generation
  - Include evolution history
  - Report costs and performance

Use two-tier scoring:
  Primary: Count of perfect training examples
  Secondary: Cell accuracy on imperfect examples

Return results in structured JSON format.
EOF
)"

# Execute Claude Code
echo -e "${GREEN}Starting evolutionary compute (this may take 5-8 minutes)...${NC}"
echo ""

# Progress indicator
echo -e "${YELLOW}Generation 1: Initial population (30 candidates)...${NC}"

# Execute with streaming JSON
claude -p "${FULL_PROMPT}" --output-format stream-json > raw_output.json 2>&1

# Parse and format results
if [[ -f "raw_output.json" ]] && command -v jq &> /dev/null; then
    echo -e "${GREEN}Processing results...${NC}"

    # Extract solution
    cat raw_output.json | jq '{
      task_id: .task_id,
      solution: .solution,
      evolution_history: .evolution_history,
      total_candidates: .total_candidates,
      best_generation: .best_generation,
      cost: .cost,
      time: .time,
      strategy: .strategy
    }' > solution_parsed.json

    # Copy to output location
    cp solution_parsed.json "${OUTPUT_FILE}"

    # Display summary
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════${NC}"
    echo -e "${GREEN}   EVOLUTIONARY COMPUTE COMPLETE${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════${NC}"
    echo ""
    BEST_GEN=$(cat solution_parsed.json | jq -r '.best_generation // "unknown"')
    TRACK=$(cat solution_parsed.json | jq -r '.solution.track // "unknown"')
    PRIMARY=$(cat solution_parsed.json | jq -r '.solution.primary_score // 0')
    SECONDARY=$(cat solution_parsed.json | jq -r '.solution.secondary_score // 0')
    COST=$(cat solution_parsed.json | jq -r '.cost // "unknown"')
    TIME=$(cat solution_parsed.json | jq -r '.time // "unknown"')

    echo "  Best Solution: Generation ${BEST_GEN}, Track ${TRACK}"
    echo "  Score: (${PRIMARY}, ${SECONDARY})"
    echo "  Cost: ${COST}"
    echo "  Time: ${TIME}"
    echo ""
    echo -e "${BLUE}Solution:${NC}"
    cat solution_parsed.json | jq -r '.solution.code // .solution.instructions' | head -20
    echo ""
    echo -e "${GREEN}Full results saved to: ${OUTPUT_FILE}${NC}"
else
    # Fallback: just copy raw output
    cp raw_output.json "${OUTPUT_FILE}"
    echo -e "${YELLOW}Warning: Could not parse results (jq not available)${NC}"
    echo -e "${GREEN}Raw results saved to: ${OUTPUT_FILE}${NC}"
fi

# Cleanup workspace
echo ""
echo -e "${YELLOW}Cleaning up workspace...${NC}"
rm -rf "${WORKSPACE}"

echo -e "${GREEN}✓ Evolution complete${NC}"
