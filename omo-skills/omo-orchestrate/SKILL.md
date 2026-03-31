---
name: omo-orchestrate
description: "Use when facing complex tasks that benefit from multi-agent collaboration - architecture review, large feature implementation, codebase investigation, or research. Dispatches oracle, explore, and librarian agents in parallel."
---

# OMO Orchestration

You have access to three specialist agents via `use_subagent`. Use them to gather information before acting.

## Available Specialists

| Agent | Role | When to use |
|-------|------|-------------|
| **oracle** | Architecture consultant (read-only) | Architecture decisions, risk assessment, code review, technical debt analysis |
| **explore** | Codebase scout (read-only) | Find files, search patterns, map project structure, locate implementations |
| **librarian** | Documentation researcher (read-only) | Search external docs, find libraries, research best practices, find examples |

## Dispatch Patterns

### Pattern 1: Single Expert

For focused questions, dispatch one specialist:

- "Analyze the auth architecture" → dispatch **oracle**
- "Find all API endpoints" → dispatch **explore**
- "What's the best library for X" → dispatch **librarian**

### Pattern 2: Parallel Recon

For complex tasks, dispatch 2-3 specialists in parallel BEFORE planning implementation:

```
User: "Add WebSocket support to the API"

Step 1 — Parallel recon (use_subagent with up to 3 agents):
  explore:   "Find all API route files, middleware, and the current server setup"
  librarian: "Research WebSocket integration patterns for [detected framework]"
  oracle:    "Analyze the current API architecture for WebSocket readiness"

Step 2 — Synthesize findings into a plan
Step 3 — Execute implementation
```

### Pattern 3: Full Review

For major decisions or pre-merge review, dispatch all three:

```
User: "Review this feature before we merge"

Parallel dispatch:
  oracle:  "Review architecture, identify risks and anti-patterns in [scope]"
  explore: "Find all files changed, check for inconsistencies and missing tests"
  librarian: "Check if implementation follows framework best practices"

Then synthesize into a review summary with: Approved / Changes Requested / Blocking Issues
```

## Rules

1. **Recon before action** — For any non-trivial task, dispatch specialists BEFORE writing code
2. **Parallel when possible** — If dispatching multiple agents, use a single `use_subagent` call with multiple entries
3. **Synthesize, don't relay** — After receiving specialist summaries, synthesize into ONE coherent response. Do not dump raw agent outputs
4. **Right tool for the job** — Don't dispatch oracle for a simple file search (use explore). Don't dispatch explore for architecture advice (use oracle)
5. **Max 4 subagents** — Kiro limit. For larger tasks, batch into waves
6. **Specialists are read-only** — They cannot write files or run commands. Only YOU (the main agent) implement changes

## Triggering

This skill activates when:
- User asks for architecture review, analysis, or assessment
- User requests a complex feature that needs research first
- User says "investigate", "research", "analyze", "review", "scout"
- Task touches multiple files/modules and would benefit from recon
- User explicitly asks to use specialists or agents

Do NOT activate for:
- Simple single-file edits
- Direct questions you can answer from context
- Tasks where you already have sufficient information
