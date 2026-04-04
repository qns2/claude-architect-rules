# Claude Architect Rules

Knowledge base for building production-grade applications with Claude, organized as [Claude Code rules](https://docs.anthropic.com/en/docs/claude-code/memory#claude-rules) that load automatically into every session.

Based on the [Claude Certified Architect — Foundations](https://www.anthropic.com/certification) exam domains.

## What's Included

| File | Covers | Exam Weight |
|------|--------|-------------|
| `architect-agentic-patterns.md` | Agentic loops, coordinator-subagent architecture, hooks, task decomposition, session management | Domain 1 (27%) |
| `architect-tool-design.md` | Tool descriptions, MCP servers, structured errors, tool distribution, built-in tool selection | Domain 2 (18%) |
| `architect-claude-code.md` | CLAUDE.md hierarchy, commands, skills, path-specific rules, plan mode, CI/CD integration | Domain 3 (20%) |
| `architect-prompts-and-output.md` | Few-shot prompting, JSON schemas, `tool_choice`, validation loops, batch processing, multi-pass review | Domain 4 (20%) |
| `architect-context-reliability.md` | Context preservation, escalation patterns, error propagation, human review workflows, provenance | Domain 5 (15%) |

## Installation

### Quick (symlink)

```bash
# Clone the repo
git clone <repo-url> ~/Documents/GitHub/claude-architect-rules

# Symlink the rules into your user-level Claude rules directory
./install.sh
```

### Manual

```bash
# Copy files to your Claude rules directory
mkdir -p ~/.claude/rules
cp rules/*.md ~/.claude/rules/
```

### Verify

Start a new Claude Code session and check that the rules are loaded:

```
/memory
```

You should see the architect rules listed as active rule files.

## How It Works

Files in `~/.claude/rules/` are automatically loaded into every Claude Code session, regardless of which project you're working in. They enrich the existing planning, development, and review workflows (brainstorming, writing-plans, executing-plans, code-reviewer, etc.) with domain-specific architecture knowledge.

These are **not** standalone skills — they're a knowledge base that your existing workflow skills reference automatically.

## Updating

```bash
cd ~/Documents/GitHub/claude-architect-rules
git pull
./install.sh
```

## Topics Covered

### In Scope (tested on the exam)

- Agentic loop implementation (`stop_reason`, tool result handling, loop termination)
- Multi-agent orchestration (coordinator-subagent patterns, task decomposition, parallel subagent execution)
- Subagent context management (explicit context passing, structured state persistence, crash recovery)
- Tool interface design (writing effective descriptions, splitting vs consolidating tools, naming)
- MCP tool and resource design (resources for content catalogs, tools for actions, description quality)
- MCP server configuration (project vs user scope, environment variable expansion, multi-server access)
- Error handling and propagation (structured errors, transient vs business vs permission, local recovery)
- Escalation decision-making (explicit criteria, honoring customer preferences, policy gap identification)
- CLAUDE.md configuration (hierarchy, `@import` patterns, `.claude/rules/` with glob patterns)
- Custom commands and skills (project vs user scope, `context: fork`, `allowed-tools`, `argument-hint`)
- Plan mode vs direct execution (complexity assessment, architectural decisions, single-file changes)
- Iterative refinement (input/output examples, test-driven iteration, interview pattern)
- Structured output via `tool_use` (schema design, `tool_choice` configuration, nullable fields)
- Few-shot prompting (ambiguous scenario targeting, format consistency, false positive reduction)
- Batch processing (Message Batches API, latency tolerance assessment, `custom_id` failure handling)
- Context window optimization (trimming verbose tool outputs, structured fact extraction, position-aware ordering)
- Human review workflows (confidence calibration, stratified sampling, accuracy segmentation)
- Information provenance (claim-source mappings, temporal data handling, conflict annotation)

### Out of Scope (not on the exam)

Fine-tuning, API auth/billing, specific cloud providers, embedding models, vector databases, computer use, vision/image analysis, streaming API, rate limiting, OAuth, token counting algorithms, prompt caching implementation details.

## Source

Claude Certified Architect — Foundations Certification Exam Guide, Version 0.1 (Feb 10, 2025). Anthropic, PBC.

## License

MIT
