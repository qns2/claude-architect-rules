---
description: "Audit a project against Claude Architect best practices. Produces structured findings with severity, file paths, and specific recommendations."
argument-hint: "[path to project, or current directory if omitted]"
---

You are reviewing a project against the Claude Architect knowledge base. Your job is to produce a structured, validated audit — not freeform observations.

## Process

Follow these steps IN ORDER. Do not skip steps.

### Step 1: Determine Scope

Read the project to understand what it does. Then determine which of the 5 rule domains apply:

| Domain | Applies when the project... |
|--------|----------------------------|
| Agentic Patterns | Uses Claude Agent SDK, spawns subagents, has agentic loops, multi-agent orchestration |
| Tool Design & MCP | Defines MCP tools, has tool descriptions, uses tool_choice, distributes tools across agents |
| Claude Code Config | Has CLAUDE.md, .claude/rules/, .claude/commands/, .claude/skills/, CI/CD integration |
| Prompts & Output | Uses Claude API prompts, structured output, JSON schemas, few-shot examples, batch processing |
| Context & Reliability | Has long conversations, escalation logic, error propagation, multi-source synthesis |

Report which domains apply and which don't. Skip non-applicable domains entirely.

### Step 2: Read the Rules

For each applicable domain, read the corresponding rule file from the architect-rules repo:

- `~/Documents/GitHub/claude-architect-rules/rules/architect-agentic-patterns.md`
- `~/Documents/GitHub/claude-architect-rules/rules/architect-tool-design.md`
- `~/Documents/GitHub/claude-architect-rules/rules/architect-claude-code.md`
- `~/Documents/GitHub/claude-architect-rules/rules/architect-prompts-and-output.md`
- `~/Documents/GitHub/claude-architect-rules/rules/architect-context-reliability.md`

### Step 3: Audit

For each applicable rule, check the project code. For each finding, record:

```json
{
  "rule": "Name of the specific rule/pattern",
  "domain": "Which domain (1-5)",
  "status": "pass | fail | partial | not-applicable",
  "severity": "critical | warning | info",
  "file": "path/to/relevant/file:line",
  "current": "What the code currently does",
  "recommendation": "Specific change to make (if status != pass)",
  "why": "Why this matters (from the rules)"
}
```

**Severity definitions:**
- **critical**: Anti-pattern that causes reliability failures, data loss, or incorrect behavior (e.g., parsing natural language for loop termination, no error handling on tool calls)
- **warning**: Missing best practice that degrades quality but doesn't break things (e.g., no few-shot examples for ambiguous classification, generic error messages)
- **info**: Improvement opportunity (e.g., could use .claude/rules/ instead of monolithic CLAUDE.md)

### Step 4: Validate Findings

Before reporting, validate each finding:
1. **Verify the file/line exists** — don't report findings on code you haven't read
2. **Confirm the rule applies** — is this pattern actually relevant to what the code does?
3. **Check for false positives** — is there a good reason the code does it differently?
4. **Remove duplicates** — don't report the same issue from multiple rules

### Step 5: Report

Output a structured report in this format:

```markdown
# Architect Review: [Project Name]

**Date:** YYYY-MM-DD
**Domains audited:** [list]
**Domains skipped:** [list with reason]

## Summary

| Severity | Count |
|----------|-------|
| Critical | N |
| Warning  | N |
| Info     | N |
| Pass     | N |

## Critical Findings

### [Finding title]
- **Rule:** [rule name from knowledge base]
- **File:** `path/to/file:line`
- **Current:** [what it does now]
- **Recommendation:** [specific change]
- **Why:** [from the rules]

## Warnings

[same format]

## Info

[same format]

## Passing

[brief list of rules the project follows correctly]
```

Save the report to the project directory as `docs/architect-review-YYYY-MM-DD.md`.

## Important

- Only audit against rules you've actually read from the files. Don't make up rules.
- Be specific — file paths, line numbers, code snippets. Not "consider improving error handling."
- A finding with no file path is not a finding. Skip it.
- If the project doesn't use Claude at all, say so and stop.
- Don't suggest changes unrelated to the architect rules.
