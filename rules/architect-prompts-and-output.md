# Prompt Engineering & Structured Output

Knowledge base for designing prompts, structured output schemas, validation loops, and batch processing.

## Explicit Criteria Over Vague Instructions

- Explicit criteria outperform vague instructions (e.g., "flag comments only when claimed behavior contradicts actual code behavior" vs "check that comments are accurate")
- General instructions like "be conservative" or "only report high-confidence findings" fail to improve precision compared to specific categorical criteria
- High false positive rates in one category undermine developer confidence in accurate categories too

### Writing effective review criteria

- Define which issues to report (bugs, security) versus skip (minor style, local patterns) rather than relying on confidence-based filtering
- Temporarily disable high false-positive categories to restore developer trust while improving prompts for those categories
- Define explicit severity criteria with concrete code examples for each severity level to achieve consistent classification

## Few-Shot Prompting

- Few-shot examples are the most effective technique for achieving consistently formatted, actionable output when detailed instructions alone produce inconsistent results
- Few-shot examples demonstrate ambiguous-case handling (e.g., tool selection for ambiguous requests, branch-level test coverage gaps)
- Few-shot examples enable the model to generalize judgment to novel patterns rather than matching only pre-specified cases
- Effective for reducing hallucination in extraction tasks (handling informal measurements, varied document structures)

### Crafting effective few-shot examples

- Create 2-4 targeted examples for ambiguous scenarios that show reasoning for why one action was chosen over plausible alternatives
- Include examples that demonstrate specific desired output format (location, issue, severity, suggested fix) to achieve consistency
- Provide examples distinguishing acceptable code patterns from genuine issues to reduce false positives while enabling generalization
- Show correct handling of varied document structures (inline citations vs bibliographies, methodology sections vs embedded details)
- Include examples showing correct extraction from documents with varied formats to address empty/null handling of required fields

## Structured Output via tool_use and JSON Schemas

- `tool_use` with JSON schemas is the most reliable approach for guaranteed schema-compliant structured output, eliminating JSON syntax errors
- `tool_choice: "auto"` — model may return text instead of calling a tool
- `tool_choice: "any"` — model must call a tool but can choose which
- Forced tool selection — `{"type": "tool", "name": "..."}` — model must call a specific named tool
- Strict JSON schemas via tool use eliminate syntax errors but do NOT prevent semantic errors (e.g., line items that don't sum to total, values in wrong fields)

### Schema design

- Define extraction tools with JSON schemas as input parameters and extract structured data from the `tool_use` response
- Set `tool_choice: "any"` to guarantee structured output when multiple extraction schemas exist and the document type is unknown
- Force a specific tool with `tool_choice: {"type": "tool", "name": "extract_metadata"}` to ensure a particular extraction runs before enrichment steps
- Design schema fields as optional (nullable) when source documents may not contain the information, preventing the model from fabricating values to satisfy required fields
- Add enum values like `"unclear"` for ambiguous cases and `"other"` + detail fields for extensible categorization
- Include format normalization rules in prompts alongside strict output schemas to handle inconsistent source formatting

## Validation, Retry, and Feedback Loops

- **Retry-with-error-feedback**: append specific validation errors to the prompt on retry to guide the model toward correction
- Retries are ineffective when the required information is simply absent from the source document (vs format or structural errors)
- Track which code constructs trigger findings (`detected_pattern` field) to enable systematic analysis of dismissal patterns
- Semantic validation errors (values don't sum, wrong field placement) differ from schema syntax errors (eliminated by tool use)

### Implementation patterns

- Send follow-up requests that include the original document, the failed extraction, and specific validation errors for model self-correction
- Identify when retries will be ineffective (information exists only in an external document not provided) versus when they will succeed (format mismatches, structural output errors)
- Add `detected_pattern` fields to structured findings to enable analysis of false positive patterns when developers dismiss findings
- Design self-correction validation flows: extract "calculated_total" alongside "stated_total" to flag discrepancies, add "conflict_detected" booleans for inconsistent source data

## Batch Processing

- **Message Batches API**: 50% cost savings, up to 24-hour processing window, no guaranteed latency SLA
- Batch processing is appropriate for non-blocking, latency-tolerant workloads (overnight reports, weekly audits, nightly test generation) and inappropriate for blocking workflows (pre-merge checks)
- The batch API does not support multi-turn tool calling within a single request (cannot execute tools mid-request and return results)
- `custom_id` fields correlate batch request/response pairs

### Strategy

- Match API approach to workflow latency requirements: synchronous API for blocking pre-merge checks, batch API for overnight/weekly analysis
- Calculate batch submission frequency based on SLA constraints (e.g., 4-hour windows to guarantee 30-hour SLA with 24-hour batch processing)
- Handle batch failures: resubmit only failed documents (identified by `custom_id`) with appropriate modifications (e.g., chunking documents that exceeded context limits)
- Use prompt refinement on a sample set before batch-processing large volumes to maximize first-pass success rates and reduce iterative resubmission costs

## Multi-Instance and Multi-Pass Review

- **Self-review limitations**: a model retains reasoning context from generation, making it less likely to question its own decisions in the same session
- Independent review instances (without prior reasoning context) are more effective at catching subtle issues than self-review instructions or extended thinking
- **Multi-pass review**: split large reviews into per-file local analysis passes plus cross-file integration passes to avoid attention dilution and contradictory findings

### Patterns

- Use a second independent Claude instance to review generated code without the generator's reasoning context
- Split large multi-file reviews into focused per-file passes for local issues plus separate integration passes for cross-file data flow analysis
- Run verification passes where the model self-reports confidence alongside each finding to enable calibrated review routing
