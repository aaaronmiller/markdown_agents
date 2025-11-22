#!/bin/bash
################################################################################
# deploy-library.sh
#
# Deploy library-based meta-learning evolution for knowledge transfer across tasks
#
# Usage:
#   ./deploy-library.sh <task-file> <library-path> [output-file] [options]
#
# Examples:
#   ./deploy-library.sh arc_tasks/eval_001.json library/trained.pkl
#   ./deploy-library.sh task.json library/growing.pkl solution.json --update-library
#   ./deploy-library.sh problem.json library/domain_specific.pkl output.json --retrieval-size=10
#
################################################################################

set -euo pipefail

# Configuration
SWARM_REPO="${HOME}/markdown_agents/evolutionary-swarms/library-evolution"
DEFAULT_BUDGET="4.00"
DEFAULT_RETRIEVAL_SIZE=5
DEFAULT_GENERATION_COUNT=10

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Parse arguments
TASK_FILE="${1:-}"
LIBRARY_PATH="${2:-}"
OUTPUT_FILE="${3:-solution.json}"
UPDATE_LIBRARY="${4:-true}"
RETRIEVAL_SIZE="${5:-$DEFAULT_RETRIEVAL_SIZE}"
BUDGET="${6:-$DEFAULT_BUDGET}"

# Validate arguments
if [[ -z "$TASK_FILE" || -z "$LIBRARY_PATH" ]]; then
    echo -e "${RED}Error: Missing required arguments${NC}"
    echo "Usage: $0 <task-file> <library-path> [output-file] [update-library] [retrieval-size] [budget]"
    echo ""
    echo "Library path can be:"
    echo "  - Existing library: library/trained.pkl"
    echo "  - New library (will be created): library/new.pkl"
    exit 1
fi

if [[ ! -f "$TASK_FILE" ]]; then
    echo -e "${RED}Error: Task file not found: ${TASK_FILE}${NC}"
    exit 1
fi

# Check if library exists, create if needed
LIBRARY_EXISTS=false
if [[ -f "$LIBRARY_PATH" ]]; then
    LIBRARY_EXISTS=true
    LIBRARY_SIZE=$(python3 -c "import pickle; print(len(pickle.load(open('${LIBRARY_PATH}', 'rb'))))" 2>/dev/null || echo "unknown")
    echo -e "${GREEN}Found existing library: ${LIBRARY_PATH} (${LIBRARY_SIZE} programs)${NC}"
else
    echo -e "${YELLOW}Library not found, will create new library at: ${LIBRARY_PATH}${NC}"
    mkdir -p "$(dirname "${LIBRARY_PATH}")"
    # Create empty library
    python3 -c "import pickle; pickle.dump([], open('${LIBRARY_PATH}', 'wb'))"
    LIBRARY_SIZE=0
fi

if [[ ! -d "$SWARM_REPO" ]]; then
    echo -e "${RED}Error: Library evolution swarm not found at ${SWARM_REPO}${NC}"
    exit 1
fi

# Create temporary workspace
WORKSPACE="/tmp/library-evo-$(date +%s)-${RANDOM}"
echo -e "${YELLOW}Creating workspace: ${WORKSPACE}${NC}"
mkdir -p "${WORKSPACE}"

# Copy swarm configuration to workspace
echo -e "${YELLOW}Loading library evolution swarm...${NC}"
cp -r "${SWARM_REPO}/.claude" "${WORKSPACE}/"

# Copy task file and library to workspace
cp "${TASK_FILE}" "${WORKSPACE}/task.json"
cp "${LIBRARY_PATH}" "${WORKSPACE}/library.pkl"

# Navigate to workspace
cd "${WORKSPACE}"

# Display task and library info
echo ""
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}   LIBRARY EVOLUTION CONFIGURATION${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo ""
TASK_ID=$(cat task.json | jq -r '.task_id // "unknown"')
TRAINING_COUNT=$(cat task.json | jq '.training_examples | length')
echo -e "${MAGENTA}Task:${NC}"
echo "  Task ID: ${TASK_ID}"
echo "  Training Examples: ${TRAINING_COUNT}"
echo ""
echo -e "${MAGENTA}Library:${NC}"
echo "  Path: ${LIBRARY_PATH}"
echo "  Current Size: ${LIBRARY_SIZE} programs"
echo "  Retrieval Size: ${RETRIEVAL_SIZE}"
echo "  Update After Solving: ${UPDATE_LIBRARY}"
echo ""
echo -e "${MAGENTA}Execution:${NC}"
echo "  Budget: \$${BUDGET}"
echo "  Candidates to Generate: ${DEFAULT_GENERATION_COUNT}"
echo ""

# Prepare prompt
FULL_PROMPT="$(cat <<EOF
Solve the task in task.json using library-based meta-learning evolution.

LIBRARY: library.pkl (${LIBRARY_SIZE} programs currently)
TASK: task.json

CONFIGURATION:
- Retrieval Size: ${RETRIEVAL_SIZE}
- Generation Count: ${DEFAULT_GENERATION_COUNT}
- Budget: \$${BUDGET}
- Update Library: ${UPDATE_LIBRARY}

PROCESS:

STEP 1: LIBRARY RETRIEVAL
  - Load library from library.pkl
  - Calculate similarity between task and all library programs
  - Use score-weighted sampling (NOT deterministic top-K!)
  - Retrieve ${RETRIEVAL_SIZE} relevant programs
  - Display retrieved programs with metadata

STEP 2: PROGRAM GENERATION
  - Generate ${DEFAULT_GENERATION_COUNT} new programs
  - Leverage retrieved library programs as building blocks
  - Composition strategies:
    * Direct reuse of library program
    * Two-step composition (prog_A → prog_B)
    * Conditional logic (if condition: prog_A else prog_B)
    * Multi-component synthesis
  - Maintain diversity in generated candidates

STEP 3: EVALUATION
  - Execute all ${DEFAULT_GENERATION_COUNT} programs on training examples
  - Calculate two-tier scores:
    Primary: Count of perfect training examples
    Secondary: Cell accuracy on imperfect examples
  - Rank by (primary DESC, secondary DESC)

STEP 4: SELECTION
  - Select best program
  - Report score and confidence

STEP 5: LIBRARY UPDATE
  - If update_library=${UPDATE_LIBRARY}:
    * Add winning program to library.pkl
    * Update reuse counts for library programs used
    * Deduplicate if needed
    * Save updated library

OUTPUT:
  - Solution (best program)
  - Library programs used
  - Confidence score
  - Library growth statistics
  - Cost breakdown

Return results in structured JSON format.
EOF
)"

# Execute Claude Code
echo -e "${GREEN}Starting library evolution (this may take 2-3 minutes)...${NC}"
echo ""

# Progress indicator
echo -e "${YELLOW}→ Retrieving relevant programs from library...${NC}"

# Execute with streaming JSON
claude -p "${FULL_PROMPT}" --output-format stream-json > raw_output.json 2>&1

# Parse and format results
if [[ -f "raw_output.json" ]] && command -v jq &> /dev/null; then
    echo ""
    echo -e "${GREEN}Processing results...${NC}"

    # Extract solution
    cat raw_output.json | jq '{
      task_id: .task_id,
      solution: .solution,
      library_programs_used: .library_programs_used,
      library_stats: .library_stats,
      cost: .cost,
      time: .time
    }' > solution_parsed.json

    # Copy to output location
    cp solution_parsed.json "${OUTPUT_FILE}"

    # Copy updated library back
    if [[ "$UPDATE_LIBRARY" == "true" ]] && [[ -f "library.pkl" ]]; then
        cp library.pkl "${LIBRARY_PATH}"
        NEW_LIBRARY_SIZE=$(python3 -c "import pickle; print(len(pickle.load(open('library.pkl', 'rb'))))" 2>/dev/null || echo "unknown")
        LIBRARY_GROWTH=$((NEW_LIBRARY_SIZE - LIBRARY_SIZE))
    else
        NEW_LIBRARY_SIZE=$LIBRARY_SIZE
        LIBRARY_GROWTH=0
    fi

    # Display summary
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════${NC}"
    echo -e "${GREEN}   LIBRARY EVOLUTION COMPLETE${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════${NC}"
    echo ""

    PRIMARY=$(cat solution_parsed.json | jq -r '.solution.primary_score // 0')
    SECONDARY=$(cat solution_parsed.json | jq -r '.solution.secondary_score // 0')
    CONFIDENCE=$(cat solution_parsed.json | jq -r '.solution.confidence // 0')
    COST=$(cat solution_parsed.json | jq -r '.cost // "unknown"')
    TIME=$(cat solution_parsed.json | jq -r '.time // "unknown"')
    LIBRARY_USED_COUNT=$(cat solution_parsed.json | jq '.library_programs_used | length // 0')

    echo -e "${MAGENTA}Solution:${NC}"
    echo "  Score: (${PRIMARY}, ${SECONDARY})"
    echo "  Confidence: ${CONFIDENCE}"
    echo "  Library Programs Used: ${LIBRARY_USED_COUNT}"
    echo ""
    echo -e "${MAGENTA}Performance:${NC}"
    echo "  Cost: ${COST}"
    echo "  Time: ${TIME}"
    echo ""
    echo -e "${MAGENTA}Library:${NC}"
    echo "  Previous Size: ${LIBRARY_SIZE} programs"
    echo "  New Size: ${NEW_LIBRARY_SIZE} programs"
    if [[ $LIBRARY_GROWTH -gt 0 ]]; then
        echo -e "  Growth: ${GREEN}+${LIBRARY_GROWTH} programs${NC}"
    else
        echo "  Growth: 0 programs (no update or solution already in library)"
    fi
    echo ""
    echo -e "${BLUE}Solution Code:${NC}"
    cat solution_parsed.json | jq -r '.solution.code // .solution.instructions' | head -20
    echo ""
    echo -e "${GREEN}Full results saved to: ${OUTPUT_FILE}${NC}"

    if [[ "$UPDATE_LIBRARY" == "true" ]]; then
        echo -e "${GREEN}Updated library saved to: ${LIBRARY_PATH}${NC}"
    fi
else
    # Fallback: just copy raw output
    cp raw_output.json "${OUTPUT_FILE}"

    # Try to copy library back anyway
    if [[ "$UPDATE_LIBRARY" == "true" ]] && [[ -f "library.pkl" ]]; then
        cp library.pkl "${LIBRARY_PATH}"
        echo -e "${YELLOW}Library updated (could not verify size)${NC}"
    fi

    echo -e "${YELLOW}Warning: Could not parse results (jq not available)${NC}"
    echo -e "${GREEN}Raw results saved to: ${OUTPUT_FILE}${NC}"
fi

# Cleanup workspace
echo ""
echo -e "${YELLOW}Cleaning up workspace...${NC}"
rm -rf "${WORKSPACE}"

echo -e "${GREEN}✓ Library evolution complete${NC}"
