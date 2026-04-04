# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A knowledge base of Claude architecture patterns for reference and per-project `@import`. Based on the Claude Certified Architect — Foundations exam guide.

## Structure

- `rules/` — the knowledge files (markdown). These are the product.
- `.claude/commands/architect-review.md` — structured project audit command
- `README.md` — usage docs and topic index

## Writing Rules

Each rule file in `rules/` follows this structure:

- Top-level `#` heading = domain name
- `##` sections = topic areas within the domain
- Each section has a brief intro, then bullet-point knowledge items
- `###` subsections contain actionable patterns ("how to apply")
- Use code formatting for API names, flags, config keys (e.g., `stop_reason`, `tool_choice`, `.mcp.json`)
- Keep items factual and specific — no generic advice
- Every item should be something a practitioner might get wrong or not know

## Style

- No emojis
- Bullet points, not prose paragraphs
- Specific over general (e.g., "use `tool_choice: {"type": "tool", "name": "extract_metadata"}` to force extraction before enrichment" not "consider using forced tool selection")
- Include the "why" when it's not obvious
- Anti-patterns get their own subsection when there are 3+
