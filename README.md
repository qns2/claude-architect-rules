# Claude Architect Rules

Reference knowledge base + structured review command for building production-grade applications with Claude. Based on the [Claude Certified Architect — Foundations](https://www.anthropic.com/certification) exam domains.

5 focused knowledge files covering all 30 task statements across the 5 exam domains, plus a `/architect-review` command that systematically audits any project against the rules.

## Install

Clone the repo:

```bash
git clone https://github.com/qns2/claude-architect-rules.git ~/Documents/GitHub/claude-architect-rules
```

Then add the review command to any project you want to audit:

```bash
mkdir -p /path/to/your/project/.claude/commands
ln -s ~/Documents/GitHub/claude-architect-rules/.claude/commands/architect-review.md \
      /path/to/your/project/.claude/commands/
```

This gives you `/architect-review` in that project's Claude Code sessions.

## Usage

### Review a project

```bash
cd /path/to/your/project
# In Claude Code:
/architect-review
```

The command follows a 5-step structured process:

1. **Scope** — determines which of the 5 domains apply to your project (skips irrelevant ones)
2. **Read** — loads the actual rule files as source of truth (not from memory)
3. **Audit** — checks each applicable rule against the codebase
4. **Validate** — verifies file paths exist, confirms rules apply, checks for false positives
5. **Report** — structured findings with severity, file:line, current state, recommendation

Each finding has:
- **Rule** — which specific rule from the knowledge base
- **Severity** — `critical` (reliability failures), `warning` (quality degradation), `info` (improvement opportunity)
- **File:line** — exact location in the codebase
- **Current** — what the code does now
- **Recommendation** — specific change to make
- **Why** — reasoning from the rules

Output is saved to `docs/architect-review-YYYY-MM-DD.md` in your project.

### `@import` rules into a project

When building something that needs the knowledge during development (not just review), import specific files in your project's `CLAUDE.md`:

```markdown
# CLAUDE.md

@import ~/Documents/GitHub/claude-architect-rules/rules/architect-agentic-patterns.md
@import ~/Documents/GitHub/claude-architect-rules/rules/architect-tool-design.md
```

Only import what's relevant — this loads into every session for that project.

### Browse as reference

Read the files directly when you need them. Each file is self-contained with knowledge items and actionable patterns.

## What's Included

### Knowledge Base (`rules/`)

| File | Covers | Exam Domain (Weight) |
|------|--------|----------------------|
| `architect-agentic-patterns.md` | Agentic loops, coordinator-subagent architecture, hooks, task decomposition, session management | Domain 1 (27%) |
| `architect-tool-design.md` | Tool descriptions, MCP servers, structured errors, tool distribution, built-in tool selection | Domain 2 (18%) |
| `architect-claude-code.md` | CLAUDE.md hierarchy, commands, skills, path-specific rules, plan mode, CI/CD integration | Domain 3 (20%) |
| `architect-prompts-and-output.md` | Few-shot prompting, JSON schemas, `tool_choice`, validation loops, batch processing, multi-pass review | Domain 4 (20%) |
| `architect-context-reliability.md` | Context preservation, escalation patterns, error propagation, human review workflows, provenance | Domain 5 (15%) |

### Review Command (`.claude/commands/architect-review.md`)

Structured project audit. Symlink into any project's `.claude/commands/` to use.

## Design Decisions

**Why not auto-load as global rules?** These files total ~430 lines. Loading all of them into every session wastes context tokens when you're working on projects that don't involve Claude agents or MCP tools. Claude already knows most of this — the value is the structured review process, not passive context.

**Why a review command instead of standalone skills?** You already have planning, development, and review skills (brainstorming, writing-plans, code-reviewer, etc.). A review command audits against the knowledge base on demand with structured output — no need for parallel skill invocation.

**Why symlink instead of plugin?** Plugin marketplace registration adds complexity. A symlink works immediately, updates with `git pull`, and is explicit about which projects get the command.

## Updating

```bash
cd ~/Documents/GitHub/claude-architect-rules
git pull
```

Symlinked commands and rules update automatically.

## Source

Claude Certified Architect — Foundations Certification Exam Guide, Version 0.1 (Feb 10, 2025). Anthropic, PBC.

## License

MIT
