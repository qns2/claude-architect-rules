# Agentic Architecture & Orchestration Patterns

Knowledge base for designing and implementing agentic systems with the Claude Agent SDK.

## Agentic Loop Lifecycle

- The agentic loop sends requests to Claude, inspects `stop_reason` (`"tool_use"` vs `"end_turn"`), executes requested tools, and returns results for the next iteration
- Tool results must be appended to conversation history so the model reasons about the next action with new information
- The loop continues when `stop_reason` is `"tool_use"` and terminates when `stop_reason` is `"end_turn"`
- The model decides which tool to call based on context — this is model-driven decision-making, not pre-configured decision trees

### Anti-patterns to avoid

- Parsing natural language signals to determine loop termination
- Setting arbitrary iteration caps as the primary stopping mechanism
- Checking for assistant text content as a completion indicator
- Using pre-configured tool sequences instead of letting the model reason about what to call next

## Coordinator-Subagent Architecture

- Hub-and-spoke: a coordinator agent manages all inter-subagent communication, error handling, and information routing
- Subagents operate with isolated context — they do NOT inherit the coordinator's conversation history automatically
- The coordinator handles task decomposition, delegation, result aggregation, and decides which subagents to invoke based on query complexity
- Overly narrow task decomposition by the coordinator leads to incomplete coverage (e.g., decomposing "creative industries" into only visual arts subtopics, missing music/writing/film)

### Designing effective coordination

- Analyze query requirements and dynamically select which subagents to invoke rather than always routing through the full pipeline
- Partition research scope across subagents to minimize duplication (assign distinct subtopics or source types to each agent)
- Implement iterative refinement loops: coordinator evaluates synthesis output for gaps, re-delegates to search/analysis subagents with targeted queries, re-invokes synthesis until coverage is sufficient
- Route all subagent communication through the coordinator for observability, consistent error handling, and controlled information flow

## Subagent Configuration & Context Passing

- The `Task` tool is the mechanism for spawning subagents; `allowedTools` must include `"Task"` for a coordinator to invoke subagents
- Subagent context must be explicitly provided in the prompt — subagents do not automatically inherit parent context or share memory between invocations
- `AgentDefinition` configures descriptions, system prompts, and tool restrictions for each subagent type
- `fork_session` creates independent branches from a shared analysis baseline for exploring divergent approaches

### Context passing best practices

- Include complete findings from prior agents directly in the subagent's prompt (e.g., pass web search results and document analysis outputs to the synthesis subagent)
- Use structured data formats to separate content from metadata (source URLs, document names, page numbers) when passing context between agents to preserve attribution
- Spawn parallel subagents by emitting multiple `Task` tool calls in a single coordinator response rather than across separate turns
- Design coordinator prompts that specify research goals and quality criteria rather than step-by-step procedural instructions, to enable subagent adaptability

## Multi-Step Workflow Enforcement

- Programmatic enforcement (hooks, prerequisite gates) provides deterministic guarantees for workflow ordering
- Prompt-based guidance for workflow ordering has a non-zero failure rate
- When deterministic compliance is required (e.g., identity verification before financial operations), use hooks not prompts
- Structured handoff protocols for mid-process escalation should include customer details, root cause analysis, and recommended actions

### When to use hooks vs prompts

- **Hooks**: critical business logic where failure has financial/legal consequences (e.g., blocking `process_refund` until `get_customer` returns a verified customer ID)
- **Prompts**: soft guidance where occasional deviation is acceptable
- Implement programmatic prerequisites that block downstream tool calls until prerequisite steps have completed

## Agent SDK Hooks

- `PostToolUse` hooks intercept tool results for transformation before the model processes them
- Hooks can enforce compliance rules (e.g., blocking refunds above a threshold)
- Hooks provide deterministic guarantees; prompt instructions provide probabilistic compliance
- Use hooks to normalize heterogeneous data formats (Unix timestamps, ISO 8601, numeric status codes) from different MCP tools before the agent processes them
- Implement tool call interception hooks that block policy-violating actions and redirect to alternative workflows (e.g., human escalation)

## Task Decomposition Strategies

- **Fixed sequential pipelines (prompt chaining)**: break reviews into sequential steps (e.g., analyze each file individually, then run a cross-file integration pass). Best for predictable, multi-aspect reviews.
- **Dynamic adaptive decomposition**: generate subtasks based on intermediate findings. Best for open-ended investigation tasks.
- Split large code reviews into per-file local analysis passes plus a separate cross-file integration pass to avoid attention dilution
- For open-ended tasks (e.g., "add comprehensive tests to a legacy codebase"), first map structure, identify high-impact areas, then create a prioritized plan that adapts as dependencies are discovered

## Session Management

- Named session resumption using `--resume <session-name>` to continue a specific prior conversation
- `fork_session` for creating independent exploration branches from a shared analysis baseline (e.g., comparing two testing strategies from the same codebase analysis)
- Starting a new session with a structured summary is more reliable than resuming when prior tool results are stale
- When resuming a session, inform the agent about specific file changes for targeted re-analysis rather than requiring full re-exploration
