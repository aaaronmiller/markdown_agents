#!/usr/bin/env python3
"""
Agent Assembly Script - Dynamic Agent Configuration Generator
Assembles custom agents with precise tool palettes, skills, and model sizing
"""

import argparse
import json
import yaml
import os
from pathlib import Path
from typing import List, Dict, Optional

class AgentAssembler:
    """Dynamically assembles agent configurations from components"""
    
    def __init__(self, toolkit_root: str = "agent-toolkit"):
        self.toolkit_root = Path(toolkit_root)
        self.templates_dir = self.toolkit_root / "templates"
        self.skills_dir = self.toolkit_root / "skills"
        self.mcp_dir = self.toolkit_root / "mcp-alternatives"
        
    def load_template(self, template_type: str) -> Dict:
        """Load agent template based on model size"""
        template_map = {
            "haiku": "agent-micro.yaml",
            "sonnet": "agent-standard.yaml",
            "opus": "agent-advanced.yaml"
        }
        
        template_file = self.templates_dir / template_map.get(template_type, "agent-standard.yaml")
        
        with open(template_file) as f:
            return yaml.safe_load(f)
    
    def get_mcp_alternatives(self, tools: List[str]) -> List[Dict]:
        """Get script-based MCP alternatives for requested tools"""
        alternatives = []
        
        for tool in tools:
            script_path = self.mcp_dir / f"{tool}.py"
            if script_path.exists():
                alternatives.append({
                    "tool": tool,
                    "type": "script",
                    "path": str(script_path.relative_to(Path.cwd())),
                    "invocation": f"python {script_path}"
                })
            else:
                print(f"Warning: MCP alternative for '{tool}' not found")
        
        return alternatives
    
    def get_skills(self, skills: List[str]) -> List[Dict]:
        """Get skill configurations"""
        skill_configs = []
        
        for skill in skills:
            skill_dir = self.skills_dir / skill
            skill_file = skill_dir / "SKILL.md"
            
            if skill_file.exists():
                skill_configs.append({
                    "name": skill,
                    "path": str(skill_dir.relative_to(Path.cwd())),
                    "skill_file": str(skill_file.relative_to(Path.cwd()))
                })
            else:
                print(f"Warning: Skill '{skill}' not found")
        
        return skill_configs
    
    def calculate_thinking_budget(self, model: str, complexity: str = "medium") -> int:
        """Calculate appropriate thinking budget based on model and complexity"""
        budgets = {
            "haiku": {"simple": 0, "medium": 2000, "complex": 5000},
            "sonnet": {"simple": 5000, "medium": 10000, "complex": 15000},
            "opus": {"simple": 10000, "medium": 15000, "complex": 20000}
        }
        
        return budgets.get(model, budgets["sonnet"]).get(complexity, 10000)
    
    def generate_agent_markdown(self, 
                                name: str,
                                model: str,
                                tools: List[str],
                                skills: List[str],
                                thinking_budget: Optional[int] = None,
                                description: str = "",
                                custom_instructions: str = "") -> str:
        """Generate agent markdown file content"""
        
        # Load template
        template = self.load_template(model)
        
        # Calculate thinking budget if not provided
        if thinking_budget is None:
            thinking_budget = self.calculate_thinking_budget(model)
        
        # Get MCP alternatives and skills
        mcp_alternatives = self.get_mcp_alternatives(tools)
        skill_configs = self.get_skills(skills)
        
        # Generate frontmatter
        frontmatter = f"""---
name: {name}
displayName: {name.replace('-', ' ').title()}
description: {description or f"Specialized {name} agent"}
category: agent
tags: {json.dumps([name, model] + tools + skills)}
model: {model}
thinking_budget: {thinking_budget}
tools: {json.dumps([alt["tool"] for alt in mcp_alternatives])}
skills: {json.dumps([skill["name"] for skill in skill_configs])}
version: 1.0.0
---
"""
        
        # Generate agent body
        body = f"""# {name.replace('-', ' ').title()} Agent

You are a specialized **{name.upper()}** agent with expertise in {', '.join(skills)}.

## Configuration

- **Model**: {model}
- **Thinking Budget**: {thinking_budget} tokens
- **Tools**: {', '.join([alt["tool"] for alt in mcp_alternatives])}
- **Skills**: {', '.join([skill["name"] for skill in skill_configs])}

## Mission

{description or f"Execute {name} tasks with high precision and efficiency."}

## Available Tools

"""
        
        # Add tool documentation
        for alt in mcp_alternatives:
            body += f"""### {alt["tool"]}

**Type**: Script-based MCP alternative
**Path**: `{alt["path"]}`
**Usage**: `{alt["invocation"]} [command] [args]`

"""
        
        # Add skills documentation
        if skill_configs:
            body += "\n## Loaded Skills\n\n"
            for skill in skill_configs:
                body += f"""### {skill["name"]}

**Path**: `{skill["skill_file"]}`

Read this skill for domain-specific knowledge: `cat {skill["skill_file"]}`

"""
        
        # Add custom instructions
        if custom_instructions:
            body += f"\n## Custom Instructions\n\n{custom_instructions}\n"
        
        # Add workflow section
        body += """
## Workflow

1. **Receive Task**: Understand the specific requirements
2. **Load Skills**: Read relevant skill files for domain knowledge
3. **Use Tools**: Execute operations using script-based MCP alternatives
4. **Validate**: Verify results meet requirements
5. **Report**: Provide clear output and next steps

## Quality Standards

- ✅ Production-ready code only
- ✅ Comprehensive error handling
- ✅ Clear documentation
- ✅ Test coverage when applicable
- ✅ Follow skill guidelines

---

**Ready to execute. Awaiting task instructions.**
"""
        
        return frontmatter + body
    
    def assemble(self,
                 name: str,
                 model: str,
                 tools: List[str],
                 skills: List[str],
                 output_path: str,
                 thinking_budget: Optional[int] = None,
                 description: str = "",
                 custom_instructions: str = "") -> str:
        """Assemble agent and write to file"""
        
        # Generate agent markdown
        agent_content = self.generate_agent_markdown(
            name=name,
            model=model,
            tools=tools,
            skills=skills,
            thinking_budget=thinking_budget,
            description=description,
            custom_instructions=custom_instructions
        )
        
        # Write to file
        output_file = Path(output_path)
        output_file.parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_file, 'w') as f:
            f.write(agent_content)
        
        print(f"✅ Agent assembled: {output_file}")
        print(f"   Model: {model}")
        print(f"   Tools: {', '.join(tools)}")
        print(f"   Skills: {', '.join(skills)}")
        print(f"   Thinking Budget: {thinking_budget or self.calculate_thinking_budget(model)}")
        
        return str(output_file)

def main():
    parser = argparse.ArgumentParser(
        description="Assemble custom agents with precise tool and skill configurations"
    )
    
    parser.add_argument("--name", required=True, help="Agent name (use hyphens)")
    parser.add_argument("--model", required=True, choices=["haiku", "sonnet", "opus"],
                       help="Model size: haiku (micro), sonnet (standard), opus (advanced)")
    parser.add_argument("--tools", required=True, help="Comma-separated list of tools")
    parser.add_argument("--skills", required=True, help="Comma-separated list of skills")
    parser.add_argument("--output", required=True, help="Output file path")
    parser.add_argument("--thinking-budget", type=int, help="Thinking budget (overrides default)")
    parser.add_argument("--description", default="", help="Agent description")
    parser.add_argument("--custom-instructions", default="", help="Custom instructions")
    parser.add_argument("--toolkit-root", default="agent-toolkit", help="Agent toolkit root directory")
    
    args = parser.parse_args()
    
    # Parse tools and skills
    tools = [t.strip() for t in args.tools.split(',')]
    skills = [s.strip() for s in args.skills.split(',')]
    
    # Assemble agent
    assembler = AgentAssembler(toolkit_root=args.toolkit_root)
    assembler.assemble(
        name=args.name,
        model=args.model,
        tools=tools,
        skills=skills,
        output_path=args.output,
        thinking_budget=args.thinking_budget,
        description=args.description,
        custom_instructions=args.custom_instructions
    )

if __name__ == "__main__":
    main()
