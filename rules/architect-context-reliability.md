# Context Management & Reliability

Knowledge base for managing conversation context, designing escalation patterns, error propagation, and human review workflows.

## Preserving Critical Information Across Long Interactions

- **Progressive summarization risks**: condensing numerical values, percentages, dates, and customer-stated expectations into vague summaries loses critical details
- **Lost in the middle effect**: models reliably process information at the beginning and end of long inputs but may omit findings from middle sections
- Tool results accumulate in context and consume tokens disproportionately to their relevance (e.g., 40+ fields per order lookup when only 5 are relevant)
- Complete conversation history must be passed in subsequent API requests to maintain conversational coherence

### Context preservation patterns

- Extract transactional facts (amounts, dates, order numbers, statuses) into a persistent "case facts" block included in each prompt, outside summarized history
- Extract and persist structured issue data (order IDs, amounts, statuses) into a separate context layer for multi-issue sessions
- Trim verbose tool outputs to only relevant fields before they accumulate in context (e.g., keeping only return-relevant fields from order lookups)
- Place key findings summaries at the beginning of aggregated inputs and organize detailed results with explicit section headers to mitigate position effects
- Require subagents to include metadata (dates, source locations, methodological context) in structured outputs to support accurate downstream synthesis
- Modify upstream agents to return structured data (key facts, citations, relevance scores) instead of verbose content and reasoning chains when downstream agents have limited context budgets

## Escalation & Ambiguity Resolution

- **Appropriate escalation triggers**: customer requests for a human, policy exceptions/gaps, and inability to make meaningful progress (not just complex cases)
- Distinguish between escalating immediately when a customer explicitly demands it versus offering to resolve when the issue is straightforward
- Sentiment-based escalation and self-reported confidence scores are unreliable proxies for actual case complexity
- Multiple customer matches require clarification (requesting additional identifiers) rather than heuristic selection

### Escalation design

- Add explicit escalation criteria with few-shot examples to the system prompt demonstrating when to escalate versus resolve autonomously
- Honor explicit customer requests for human agents immediately without first attempting investigation
- Acknowledge frustration while offering resolution when the issue is within the agent's capability, escalating only if the customer reiterates their preference
- Escalate when policy is ambiguous or silent on the customer's specific request (e.g., competitor price matching when policy only addresses own-site adjustments)
- Instruct the agent to ask for additional identifiers when tool results return multiple matches, rather than selecting based on heuristics

## Error Propagation Across Multi-Agent Systems

- Structured error context (failure type, attempted query, partial results, alternative approaches) enables intelligent coordinator recovery decisions
- Distinguish access failures (timeouts needing retry decisions) from valid empty results (successful queries with no matches)
- Generic error statuses ("search unavailable") hide valuable context from the coordinator
- Silently suppressing errors (returning empty results as success) or terminating entire workflows on single failures are both anti-patterns

### Error propagation patterns

- Return structured error context including failure type, what was attempted, partial results, and potential alternatives to enable coordinator recovery
- Distinguish access failures from valid empty results in error reporting so the coordinator can make appropriate decisions
- Have subagents implement local recovery for transient failures and only propagate errors they cannot resolve, including what was attempted and partial results
- Structure synthesis output with coverage annotations indicating which findings are well-supported versus which topic areas have gaps due to unavailable sources

## Managing Context in Large Codebase Exploration

- **Context degradation**: in extended sessions, models start giving inconsistent answers and referencing "typical patterns" rather than specific classes discovered earlier
- **Scratchpad files**: persist key findings across context boundaries
- **Subagent delegation**: isolate verbose exploration output while the main agent coordinates high-level understanding
- **Structured state persistence**: each agent exports state to a known location, and the coordinator loads a manifest on resume for crash recovery

### Patterns

- Spawn subagents to investigate specific questions (e.g., "find all test files," "trace refund flow dependencies") while the main agent preserves high-level coordination
- Have agents maintain scratchpad files recording key findings, referencing them for subsequent questions to counteract context degradation
- Summarize key findings from one exploration phase before spawning sub-agents for the next phase, injecting summaries into initial context
- Design crash recovery using structured agent state exports (manifests) that the coordinator loads on resume and injects into agent prompts
- Use `/compact` to reduce context usage during extended exploration sessions when context fills with verbose discovery output

## Human Review Workflows & Confidence Calibration

- Aggregate accuracy metrics (e.g., 97% overall) may mask poor performance on specific document types or fields
- **Stratified random sampling**: measure error rates in high-confidence extractions for ongoing error rate measurement and novel error pattern detection
- **Field-level confidence scores**: calibrated using labeled validation sets for routing review attention
- Validate accuracy by document type and field to verify consistent performance across all segments before reducing human review

### Implementation

- Implement stratified random sampling of high-confidence extractions for ongoing error rate measurement and novel pattern detection
- Analyze accuracy by document type and field to verify consistent performance across all segments before reducing human review
- Have models output field-level confidence scores, then calibrate review thresholds using labeled validation sets
- Route extractions with low model confidence or ambiguous/contradictory source documents to human review, prioritizing limited reviewer capacity

## Information Provenance in Multi-Source Synthesis

- Source attribution is lost during summarization steps when findings are compressed without preserving claim-source mappings
- Structured claim-source mappings must be preserved through merge when the synthesis agent combines findings
- Handle conflicting statistics from credible sources: annotate conflicts with source attribution rather than arbitrarily selecting one value
- Temporal data: require publication/collection dates in structured outputs to prevent temporal differences from being misinterpreted as contradictions

### Provenance patterns

- Require subagents to output structured claim-source mappings (source URLs, document names, relevant excerpts) that downstream agents preserve through synthesis
- Structure reports with explicit sections distinguishing well-established findings from contested ones, preserving original source characterizations and methodological context
- Complete document analysis with conflicting values included and explicitly annotated, letting the coordinator decide how to reconcile before passing to synthesis
- Require subagents to include publication or data collection dates in structured outputs to enable correct temporal interpretation
- Render different content types appropriately in synthesis outputs — financial data as tables, news as prose, technical findings as structured lists — rather than converting everything to a uniform format
