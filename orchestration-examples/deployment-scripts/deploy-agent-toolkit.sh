#!/bin/bash
################################################################################
# deploy-agent-toolkit.sh
#
# Deploy Agent Toolkit V2 swarms for production software engineering tasks
#
# Usage:
#   ./deploy-agent-toolkit.sh <swarm-domain> <project-path> "<task-description>"
#
# Examples:
#   ./deploy-agent-toolkit.sh security /path/to/project "Audit payment module for SQL injection"
#   ./deploy-agent-toolkit.sh refactoring /path/to/project "Apply repository pattern to services/"
#   ./deploy-agent-toolkit.sh test /path/to/project "Generate integration tests for API"
#
################################################################################

set -euo pipefail

# Configuration
SWARM_REPO="${HOME}/markdown_agents/agent-toolkit-swarms"
DEFAULT_STRATEGY="balanced"
DEFAULT_BUDGET="3.00"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse arguments
SWARM_DOMAIN="${1:-}"
PROJECT_PATH="${2:-}"
TASK_DESCRIPTION="${3:-}"
STRATEGY="${4:-$DEFAULT_STRATEGY}"
BUDGET="${5:-$DEFAULT_BUDGET}"

# Validate arguments
if [[ -z "$SWARM_DOMAIN" || -z "$PROJECT_PATH" || -z "$TASK_DESCRIPTION" ]]; then
    echo -e "${RED}Error: Missing required arguments${NC}"
    echo "Usage: $0 <swarm-domain> <project-path> \"<task-description>\" [strategy] [budget]"
    echo ""
    echo "Available swarm domains:"
    echo "  - security, refactoring, documentation, test"
    echo "  - performance, cicd, observability, migration"
    echo "  - api, database, data-pipeline, mlops"
    exit 1
fi

# Map domain to swarm directory
SWARM_PATH="${SWARM_REPO}/${SWARM_DOMAIN}-swarm-v2"

if [[ ! -d "$SWARM_PATH" ]]; then
    echo -e "${RED}Error: Swarm '${SWARM_DOMAIN}' not found at ${SWARM_PATH}${NC}"
    echo "Available swarms:"
    ls -1 "${SWARM_REPO}" | grep -v "ARCHITECTURE.md"
    exit 1
fi

# Create temporary workspace
WORKSPACE="${PROJECT_PATH}/.claude-swarm-$(date +%s)-${RANDOM}"
echo -e "${YELLOW}Creating workspace: ${WORKSPACE}${NC}"
mkdir -p "${WORKSPACE}"

# Copy swarm configuration to workspace
echo -e "${YELLOW}Loading ${SWARM_DOMAIN} swarm...${NC}"
cp -r "${SWARM_PATH}/.claude" "${WORKSPACE}/"

# Navigate to workspace
cd "${WORKSPACE}"

# Prepare prompt with task context
FULL_PROMPT="$(cat <<EOF
You are deploying the ${SWARM_DOMAIN} swarm for the following task:

PROJECT: ${PROJECT_PATH}
TASK: ${TASK_DESCRIPTION}

STRATEGY: ${STRATEGY}
BUDGET: \$${BUDGET}

Execute this task using the swarm's capabilities:
1. Analyze the task requirements
2. Deploy appropriate subagents based on complexity
3. Use progressive disclosure skills as needed
4. Aggregate results into comprehensive report
5. Provide actionable recommendations

Return results in structured format suitable for further processing.
EOF
)"

# Execute Claude Code
echo -e "${GREEN}Executing ${SWARM_DOMAIN} swarm...${NC}"
echo ""

# Check if we should stream JSON or display normally
if command -v jq &> /dev/null; then
    # Stream JSON output for programmatic processing
    claude -p "${FULL_PROMPT}" --output-format stream-json > "${PROJECT_PATH}/${SWARM_DOMAIN}-results.json"

    echo -e "${GREEN}Results saved to: ${PROJECT_PATH}/${SWARM_DOMAIN}-results.json${NC}"
    echo ""
    echo "Summary:"
    cat "${PROJECT_PATH}/${SWARM_DOMAIN}-results.json" | jq -r '.summary // .result' | head -20
else
    # Display normally
    claude -p "${FULL_PROMPT}"
fi

# Cleanup workspace
echo ""
echo -e "${YELLOW}Cleaning up workspace...${NC}"
cd "${PROJECT_PATH}"
rm -rf "${WORKSPACE}"

echo -e "${GREEN}✓ Deployment complete${NC}"
