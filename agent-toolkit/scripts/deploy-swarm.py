#!/usr/bin/env python3
"""
Swarm Deployment Script - Orchestrated Multi-Agent System Assembly
Creates complete swarm systems with orchestrator and specialized agents
"""

import argparse
import json
import yaml
from pathlib import Path
from typing import List, Dict

class SwarmDeployer:
    """Deploy orchestrated multi-agent swarms"""
    
    def __init__(self, toolkit_root: str = "agent-toolkit"):
        self.toolkit_root = Path(toolkit_root)
        self.templates_dir = self.toolkit_root / "templates"
        
    def create_orchestrator(self, 
                           swarm_name: str,
                           agents: List[str],
                           model: str = "sonnet",
                           thinking_budget: int = 12000) -> str:
        """Generate orchestrator CLAUDE.md"""
        
        orchestrator_content = f"""# {swarm_name.replace('-', ' ').title()} - Orchestrator

You are the **{swarm_name.upper()} ORCHESTRATOR**, responsible for coordinating specialized agents to complete complex tasks.

## Configuration

- **Model**: claude-{model}-4-20250514
- **Thinking Budget**: {thinking_budget}
- **Coordination Mode**: Dynamic agent instantiation

## Available Agents

"""
        
        for agent in agents:
            orchestrator_content += f"""### {agent.replace('-', ' ').title()}

**Agent File**: `.claude/agents/{agent}.md`
**Activation**: Read agent file to understand capabilities

"""
        
        orchestrator_content += """
## Orchestration Workflow

### Phase 1: Task Analysis

1. **Understand Requirements**: Parse the user's request
2. **Identify Sub-Tasks**: Break down into agent-specific work
3. **Determine Dependencies**: Identify which tasks depend on others
4. **Select Agents**: Choose appropriate agents for each sub-task

### Phase 2: Agent Deployment

For each sub-task:
1. **Read Agent Definition**: `cat .claude/agents/[agent-name].md`
2. **Load Agent Skills**: Agent will read required skill files
3. **Provide Context**: Give agent the sub-task and relevant context
4. **Monitor Execution**: Track agent progress

### Phase 3: Coordination

1. **Collect Results**: Gather outputs from all agents
2. **Resolve Dependencies**: Pass outputs between dependent agents
3. **Validate Completeness**: Ensure all sub-tasks completed
4. **Synthesize**: Combine results into final output

### Phase 4: Quality Assurance

1. **Verify Requirements Met**: Check against original request
2. **Run Validation**: Execute any quality checks
3. **Generate Report**: Summarize work completed

## Agent Spawning Pattern

When you need to deploy an agent:

```
AGENT: [agent-name]
TASK: [specific sub-task]
CONTEXT: [relevant information from other agents]
PRIORITY: [high/medium/low]
```

Example:
```
AGENT: code-analyzer
TASK: Build dependency graph for backend services
CONTEXT: Project uses microservices architecture
PRIORITY: high
```

## Memory Management

Use the memory MCP alternative to maintain state:
```bash
python agent-toolkit/mcp-alternatives/memory.py store [key] [value]
python agent-toolkit/mcp-alternatives/memory.py retrieve [key]
```

## Parallel Execution

When tasks are independent, deploy agents in parallel:
- Analyze + Test in parallel
- Frontend + Backend in parallel
- Documentation + Testing in parallel

## Error Handling

If an agent fails:
1. Review agent output for errors
2. Adjust sub-task if needed
3. Re-deploy agent with clarifications
4. If persistent failure, escalate to user

## Quality Standards

- ✅ All sub-tasks completed successfully
- ✅ Agent outputs integrated correctly
- ✅ No conflicts between agent work
- ✅ Final output meets requirements
- ✅ Documentation generated

---

**Ready to orchestrate. Awaiting task description.**
"""
        
        return orchestrator_content
    
    def create_swarm_settings(self,
                             swarm_name: str,
                             orchestrator_model: str,
                             orchestrator_thinking_budget: int,
                             agents: List[Dict]) -> Dict:
        """Generate settings.json for swarm"""
        
        return {
            "model": f"claude-{orchestrator_model}-4-20250514",
            "thinking_budget": orchestrator_thinking_budget,
            "swarm_config": {
                "name": swarm_name,
                "orchestrator": {
                    "model": orchestrator_model,
                    "thinking_budget": orchestrator_thinking_budget
                },
                "agents": agents
            },
            "tools": [
                "Task",
                "Read",
                "Write",
                "Edit",
                "Bash",
                "Glob",
                "Grep"
            ],
            "memoryBank": {
                "enabled": True,
                "path": "memory/memory-bank.json"
            }
        }
    
    def deploy(self,
               swarm_name: str,
               agents: List[Dict],
               output_dir: str,
               orchestrator_model: str = "sonnet",
               orchestrator_thinking_budget: int = 12000):
        """Deploy complete swarm system"""
        
        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)
        
        # Create directory structure
        (output_path / ".claude" / "agents").mkdir(parents=True, exist_ok=True)
        (output_path / ".claude" / "skills").mkdir(parents=True, exist_ok=True)
        (output_path / ".claude" / "hooks").mkdir(parents=True, exist_ok=True)
        (output_path / ".claude" / "scripts").mkdir(parents=True, exist_ok=True)
        (output_path / "memory").mkdir(parents=True, exist_ok=True)
        
        # Create orchestrator
        orchestrator_content = self.create_orchestrator(
            swarm_name,
            [agent["name"] for agent in agents],
            orchestrator_model,
            orchestrator_thinking_budget
        )
        
        with open(output_path / ".claude" / "CLAUDE.md", 'w') as f:
            f.write(orchestrator_content)
        
        print(f"✅ Created orchestrator: {output_path}/.claude/CLAUDE.md")
        
        # Create settings.json
        settings = self.create_swarm_settings(
            swarm_name,
            orchestrator_model,
            orchestrator_thinking_budget,
            agents
        )
        
        with open(output_path / ".claude" / "settings.json", 'w') as f:
            json.dump(settings, f, indent=2)
        
        print(f"✅ Created settings: {output_path}/.claude/settings.json")
        
        # Note: Actual agent files would be created by assemble-agent.py
        print(f"\n✅ Swarm deployed: {swarm_name}")
        print(f"   Output: {output_path}")
        print(f"   Orchestrator Model: {orchestrator_model}")
        print(f"   Agents: {len(agents)}")

def main():
    parser = argparse.ArgumentParser(description="Deploy orchestrated multi-agent swarms")
    parser.add_argument("--swarm-name", required=True, help="Swarm name")
    parser.add_argument("--agents", required=True, help="JSON file or inline JSON with agent configs")
    parser.add_argument("--output", required=True, help="Output directory")
    parser.add_argument("--orchestrator-model", default="sonnet", choices=["haiku", "sonnet", "opus"])
    parser.add_argument("--orchestrator-thinking-budget", type=int, default=12000)
    parser.add_argument("--toolkit-root", default="agent-toolkit")
    
    args = parser.parse_args()
    
    # Parse agents configuration
    if Path(args.agents).exists():
        with open(args.agents) as f:
            agents = json.load(f)
    else:
        agents = json.loads(args.agents)
    
    # Deploy swarm
    deployer = SwarmDeployer(toolkit_root=args.toolkit_root)
    deployer.deploy(
        swarm_name=args.swarm_name,
        agents=agents,
        output_dir=args.output,
        orchestrator_model=args.orchestrator_model,
        orchestrator_thinking_budget=args.orchestrator_thinking_budget
    )

if __name__ == "__main__":
    main()
