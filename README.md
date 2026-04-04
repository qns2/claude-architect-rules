# Claude Architect Rules

Reference knowledge base + review command for building production-grade applications with Claude. Based on the [Claude Certified Architect — Foundations](https://www.anthropic.com/certification) exam domains.

5 focused markdown files covering all 30 task statements across the 5 exam domains. Use as a reference, `@import` into projects, or run `/architect-review` to audit a project against the rules.

## Install

```bash
claude plugin add github:qns2/claude-architect-rules
```

This gives you the `/architect-review` command in any project.

## What's Included

### Knowledge Base (`rules/`)

| File | Covers | Exam Domain (Weight) |
|------|--------|----------------------|
| `architect-agentic-patterns.md` | Agentic loops, coordinator-subagent architecture, hooks, task decomposition, session management | Domain 1 (27%) |
| `architect-tool-design.md` | Tool descriptions, MCP servers, structured errors, tool distribution, built-in tool selection | Domain 2 (18%) |
| `architect-claude-code.md` | CLAUDE.md hierarchy, commands, skills, path-specific rules, plan mode, CI/CD integration | Domain 3 (20%) |
| `architect-prompts-and-output.md` | Few-shot prompting, JSON schemas, `tool_choice`, validation loops, batch processing, multi-pass review | Domain 4 (20%) |
| `architect-context-reliability.md` | Context preservation, escalation patterns, error propagation, human review workflows, provenance | Domain 5 (15%) |

### Review Command (`.claude/commands/`)

**`/architect-review [path]`** — Structured project audit against the rules.

The review process:
1. **Scope** — determines which of the 5 domains apply to your project
2. **Read** — loads the actual rule files as source of truth
3. **Audit** — checks each applicable rule against the codebase
4. **Validate** — verifies file paths exist, confirms rules apply, removes false positives
5. **Report** — structured findings with severity, file:line, current state, recommendation

Output is saved to `docs/architect-review-YYYY-MM-DD.md` in your project.

## Other Usage

### `@import` into a project

When building something that needs this knowledge, import specific files in your project's `CLAUDE.md`:

```markdown
# CLAUDE.md

@import ~/Documents/GitHub/claude-architect-rules/rules/architect-agentic-patterns.md
@import ~/Documents/GitHub/claude-architect-rules/rules/architect-tool-design.md
```

Loads the knowledge only in that project's sessions.

### Global rules (use sparingly)

```bash
mkdir -p ~/.claude/rules
ln -s ~/Documents/GitHub/claude-architect-rules/rules/architect-agentic-patterns.md ~/.claude/rules/
```

Adds to context in every session — only link what you actively need.

## Design Decisions

**Why not auto-load everything?** These files total ~430 lines. Loading all of them into every session wastes context tokens when you're working on projects that don't involve building Claude agents or MCP tools. Claude already knows most of this — the value is as a structured reference and review process, not as behavioral rules.

**Why a review command instead of standalone skills?** You already have planning, development, and review skills. Creating parallel architect skills means remembering to invoke the right one. A review command runs against the knowledge base on demand — structured process, validated output.

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
