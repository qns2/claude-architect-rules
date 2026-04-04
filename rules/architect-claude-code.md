# Claude Code Configuration & Workflows

Knowledge base for configuring Claude Code for team workflows, custom commands, skills, CI/CD integration, and iterative refinement.

## CLAUDE.md Configuration Hierarchy

- **User-level** (`~/.claude/CLAUDE.md`): personal settings, not shared with teammates via version control
- **Project-level** (`.claude/CLAUDE.md` or root `CLAUDE.md`): team-wide standards
- **Directory-level** (subdirectory `CLAUDE.md` files): area-specific conventions
- `@import` syntax references external files to keep CLAUDE.md modular (e.g., importing specific standards files relevant to each package)
- `.claude/rules/` directory for organizing topic-specific rule files as an alternative to a monolithic CLAUDE.md

### Configuration best practices

- Diagnose configuration hierarchy issues (e.g., a new team member not receiving instructions because they're in user-level rather than project-level configuration)
- Use `@import` to selectively include relevant standards files in each package's CLAUDE.md based on maintainer domain knowledge
- Split large CLAUDE.md files into focused topic-specific files in `.claude/rules/` (e.g., `testing.md`, `api-conventions.md`, `deployment.md`)
- Use the `/memory` command to verify which memory files are loaded and diagnose inconsistent behavior across sessions

## Custom Slash Commands & Skills

- **Project-scoped commands**: `.claude/commands/` — shared via version control, available to all developers who clone/pull
- **User-scoped commands**: `~/.claude/commands/` — personal, not shared
- **Skills**: `.claude/skills/` with `SKILL.md` files that support frontmatter configuration including `context: fork`, `allowed-tools`, and `argument-hint`
- `context: fork` runs skills in an isolated sub-agent, preventing skill outputs from polluting the main conversation
- Personal skill customization: create personal variants in `~/.claude/skills/` with different names to avoid affecting teammates

### Implementation

- Create project-scoped slash commands in `.claude/commands/` for team-wide availability via version control
- Use `context: fork` to isolate skills that produce verbose output (e.g., codebase analysis) or exploratory context (e.g., brainstorming alternatives) from the main session
- Configure `allowed-tools` in skill frontmatter to restrict tool access during skill execution (e.g., limiting to file read operations to prevent destructive actions)
- Use `argument-hint` frontmatter to prompt developers for required parameters when they invoke the skill without arguments
- Choose between skills (on-demand invocation for task-specific workflows) and CLAUDE.md (always-loaded universal standards)

## Path-Specific Rules

- `.claude/rules/` files with YAML frontmatter `paths` fields containing glob patterns for conditional rule activation
- Path-scoped rules load only when editing matching files, reducing irrelevant context and token usage
- Glob-pattern rules are better than directory-level CLAUDE.md files for conventions that span multiple directories (e.g., test files spread throughout a codebase)

### Usage

- Create `.claude/rules/` files with YAML frontmatter path scoping (e.g., `paths: ["terraform/**/*"]`) so rules load only when editing matching files
- Use glob patterns in path-specific rules to apply conventions to files by type regardless of directory location (e.g., `**/*.test.tsx` for all test files)
- Choose path-specific rules over subdirectory CLAUDE.md files when conventions must apply to files spread across a codebase

## Plan Mode vs Direct Execution

- **Plan mode**: complex tasks involving large-scale changes, multiple valid approaches, and multi-file modifications. Enables safe codebase exploration and design before committing to changes, preventing costly rework.
- **Direct execution**: simple, well-scoped changes (e.g., a single-file bug fix with a clear stack trace, adding a date validation conditional)
- The **Explore subagent** isolates verbose discovery output and returns summaries to preserve main conversation context

### Decision patterns

- Select plan mode for tasks with architectural implications (e.g., microservice restructuring, library migrations affecting 45+ files, choosing between integration approaches with different infrastructure requirements)
- Select direct execution for well-understood changes with clear scope
- Use the Explore subagent for verbose discovery phases to prevent context window exhaustion during multi-phase tasks
- Combine plan mode for investigation with direct execution for implementation (e.g., planning a library migration, then executing the planned approach)

## Iterative Refinement Techniques

- Concrete input/output examples are the most effective way to communicate expected transformations when prose descriptions are interpreted inconsistently
- **Test-driven iteration**: write test suites first, then iterate by sharing test failures to guide progressive improvement
- **Interview pattern**: have Claude ask questions to surface considerations the developer may not have anticipated before implementing
- Provide all interacting issues in a single message versus fixing them sequentially for independent problems

### Application

- Provide 2-3 concrete input/output examples to clarify transformation requirements when natural language descriptions produce inconsistent results
- Write test suites covering expected behavior, edge cases, and performance requirements before implementation, then iterate by sharing test failures
- Use the interview pattern to surface design considerations (e.g., cache invalidation strategies, failure modes) before implementing solutions in unfamiliar domains
- Provide specific test cases with example input and expected output to fix edge case handling (e.g., null values in migration scripts)
- Address multiple interacting issues in a single detailed message when fixes interact, versus sequential iteration for independent issues

## CI/CD Integration

- `-p` (or `--print`) flag runs Claude Code in non-interactive mode in automated pipelines
- `--output-format json` and `--json-schema` CLI flags enforce structured output in CI contexts
- CLAUDE.md provides project context (testing standards, fixture conventions, review criteria) to CI-invoked Claude Code
- **Session context isolation**: the same Claude session that generated code is less effective at reviewing its own changes compared to an independent review instance

### CI patterns

- Run Claude Code in CI with the `-p` flag to prevent interactive input hangs
- Use `--output-format json` with `--json-schema` to produce machine-parseable structured findings for automated posting as inline PR comments
- Include prior review findings in context when re-running reviews after new commits, instructing Claude to report only new or still-unaddressed issues to avoid duplicate comments
- Provide existing test files in context so test generation avoids suggesting duplicate scenarios already covered by the test suite
- Document testing standards, valuable test criteria, and available fixtures in CLAUDE.md to improve test generation quality and reduce low-value test output
