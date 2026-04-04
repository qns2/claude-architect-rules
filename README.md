# Claude Architect Rules

Reference knowledge base for building production-grade applications with Claude. Based on the [Claude Certified Architect — Foundations](https://www.anthropic.com/certification) exam domains.

5 focused markdown files covering all 30 task statements across the 5 exam domains. Use as a reference, or pull specific files into your project with `@import` when you're actually building agentic systems, MCP tools, or configuring Claude Code for teams.

## What's Included

| File | Covers | Exam Domain (Weight) |
|------|--------|----------------------|
| `architect-agentic-patterns.md` | Agentic loops, coordinator-subagent architecture, hooks, task decomposition, session management | Domain 1 (27%) |
| `architect-tool-design.md` | Tool descriptions, MCP servers, structured errors, tool distribution, built-in tool selection | Domain 2 (18%) |
| `architect-claude-code.md` | CLAUDE.md hierarchy, commands, skills, path-specific rules, plan mode, CI/CD integration | Domain 3 (20%) |
| `architect-prompts-and-output.md` | Few-shot prompting, JSON schemas, `tool_choice`, validation loops, batch processing, multi-pass review | Domain 4 (20%) |
| `architect-context-reliability.md` | Context preservation, escalation patterns, error propagation, human review workflows, provenance | Domain 5 (15%) |

## Usage

### Review a project

Audit any project against the architect rules with the included command:

```bash
cd /path/to/your/project
claude /architect-review
```

This produces a structured report with severity-rated findings, file paths, and specific recommendations — saved to `docs/architect-review-YYYY-MM-DD.md`.

Requires the repo to be installed as a Claude Code plugin or the command file to be available.

### As a reference

Clone the repo and read the files when you need them:

```bash
git clone https://github.com/qns2/claude-architect-rules.git
```

### In a project with `@import`

When you're building something that needs this knowledge (an agentic system, MCP tools, etc.), import the relevant file(s) in your project's `CLAUDE.md`:

```markdown
# CLAUDE.md

@import ~/Documents/GitHub/claude-architect-rules/rules/architect-agentic-patterns.md
@import ~/Documents/GitHub/claude-architect-rules/rules/architect-tool-design.md
```

This loads the knowledge only in that project's sessions — not globally.

### In `~/.claude/rules/` (global, use sparingly)

If you're working on Claude architecture across multiple projects and want the rules always available:

```bash
mkdir -p ~/.claude/rules
ln -s ~/Documents/GitHub/claude-architect-rules/rules/architect-agentic-patterns.md ~/.claude/rules/
```

This adds to context in every session, so only link what you actively need.

## Why Not Auto-Load Everything?

These files total ~430 lines. Loading all of them into every session wastes context tokens when you're working on projects that don't involve building Claude agents or MCP tools. Claude already knows most of this — the value is as a structured reference, not as behavioral rules.

Use `@import` to pull in specific files per-project when relevant.

## Topics Covered

### In Scope

- Agentic loop implementation (`stop_reason`, tool result handling, loop termination)
- Multi-agent orchestration (coordinator-subagent patterns, task decomposition, parallel execution)
- Subagent context management (explicit context passing, structured state persistence, crash recovery)
- Tool interface design (writing effective descriptions, splitting vs consolidating tools)
- MCP tool and resource design (resources for content catalogs, tools for actions)
- MCP server configuration (project vs user scope, environment variable expansion)
- Error handling and propagation (structured errors, transient vs business vs permission, local recovery)
- Escalation decision-making (explicit criteria, honoring customer preferences, policy gaps)
- CLAUDE.md configuration (hierarchy, `@import`, `.claude/rules/` with glob patterns)
- Custom commands and skills (`context: fork`, `allowed-tools`, `argument-hint`)
- Plan mode vs direct execution (complexity assessment, architectural decisions)
- Iterative refinement (input/output examples, test-driven iteration, interview pattern)
- Structured output via `tool_use` (schema design, `tool_choice`, nullable fields)
- Few-shot prompting (ambiguous scenario targeting, format consistency, false positive reduction)
- Batch processing (Message Batches API, latency tolerance, `custom_id` failure handling)
- Context window optimization (trimming verbose tool outputs, structured fact extraction)
- Human review workflows (confidence calibration, stratified sampling)
- Information provenance (claim-source mappings, temporal data, conflict annotation)

### Out of Scope

Fine-tuning, API auth/billing, cloud providers, embedding models, vector databases, computer use, vision/image analysis, streaming API, rate limiting, OAuth, token counting, prompt caching implementation.

## Source

Claude Certified Architect — Foundations Certification Exam Guide, Version 0.1 (Feb 10, 2025). Anthropic, PBC.

## License

MIT
