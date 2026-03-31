---
name: omo-init-deep
description: "Use when first entering a project, when asked to understand project structure, or when asked to generate AGENTS.md files. Scans the project and generates hierarchical context files."
---

# Init Deep — Project Context Generation

Generate hierarchical `AGENTS.md` context files throughout the project tree so that agents working in specific directories have relevant context without loading the entire repo.

## When To Use

- First time working in a project
- User says "init deep", "scan project", "generate context", "map the codebase"
- Project has no `AGENTS.md` files yet

## Process

### Step 1: Dispatch explore agent to scan

Use `use_subagent` to dispatch **explore** agent:

```
explore: "Map the complete project structure. For each directory, report:
  1. Directory path
  2. Key files and their purpose
  3. What this directory is responsible for
  4. Dependencies on other directories
  Report as structured data."
```

### Step 2: Generate AGENTS.md files

Based on explore's findings, create `AGENTS.md` at each significant directory level:

**Root `AGENTS.md`** — Project overview:
```markdown
# Project Context

## Overview
[What this project does, one paragraph]

## Tech Stack
[Languages, frameworks, key dependencies]

## Structure
[Top-level directory purposes]

## Conventions
[Coding style, naming conventions, patterns used]
```

**Subdirectory `AGENTS.md`** — Directory-specific context:
```markdown
# [Directory Name] Context

## Purpose
[What this directory is responsible for]

## Key Files
[Important files and what they do]

## Dependencies
[What this directory depends on, what depends on it]

## Patterns
[Patterns and conventions specific to this directory]
```

### Step 3: Report what was created

Show a tree of generated files and a brief summary.

## Rules

- Only create `AGENTS.md` in directories that have meaningful context (skip `node_modules`, `dist`, `.git`, etc.)
- Keep each file concise — agents read these for quick context, not documentation
- Don't overwrite existing `AGENTS.md` files unless user explicitly asks
- Typical depth: root + 1-2 levels of subdirectories (src/, src/components/, etc.)
