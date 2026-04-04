# Tool Design & MCP Integration

Knowledge base for designing effective tool interfaces, MCP servers, and error handling patterns.

## Tool Interface Design

- Tool descriptions are the primary mechanism LLMs use for tool selection; minimal descriptions lead to unreliable selection among similar tools
- Include input formats, example queries, edge cases, and boundary explanations in tool descriptions
- Ambiguous or overlapping tool descriptions cause misrouting (e.g., `analyze_content` vs `analyze_document` with near-identical descriptions)
- System prompt wording can create keyword-sensitive tool associations that override well-written tool descriptions

### Fixing tool selection problems

- Write descriptions that clearly differentiate each tool's purpose, expected inputs, outputs, and when to use it versus similar alternatives
- Rename tools and update descriptions to eliminate functional overlap (e.g., rename `analyze_content` to `extract_web_results` with a web-specific description)
- Split generic tools into purpose-specific tools with defined input/output contracts (e.g., split `analyze_document` into `extract_data_points`, `summarize_content`, and `verify_claim_against_source`)
- Review system prompts for keyword-sensitive instructions that might override tool descriptions

## Structured Error Responses for MCP Tools

- The MCP `isError` flag pattern communicates tool failures back to the agent
- Distinguish between: transient errors (timeouts, service unavailability), validation errors (invalid input), business errors (policy violations), and permission errors
- Uniform error responses (generic "Operation failed") prevent the agent from making appropriate recovery decisions
- Distinguish between retryable and non-retryable errors; returning structured metadata prevents wasted retry attempts

### Error response design

Return structured error metadata including:
- `errorCategory` (transient/validation/permission)
- `isRetryable` boolean
- Human-readable descriptions
- Include `retriable: false` flags and customer-friendly explanations for business rule violations so the agent can communicate appropriately
- Implement local error recovery within subagents for transient failures; propagate to the coordinator only errors that cannot be resolved locally, along with partial results and what was attempted
- Distinguish access failures (needing retry decisions) from valid empty results (successful queries with no matches)

## Tool Distribution Across Agents

- Giving an agent access to too many tools (e.g., 18 instead of 4-5) degrades tool selection reliability by increasing decision complexity
- Agents with tools outside their specialization tend to misuse them (e.g., a synthesis agent attempting web searches)
- Scoped tool access: give agents only the tools needed for their role, with limited cross-role tools for specific high-frequency needs

### Distribution patterns

- Restrict each subagent's tool set to those relevant to its role, preventing cross-specialization misuse
- Replace generic tools with constrained alternatives (e.g., replace `fetch_url` with `load_document` that validates document URLs)
- Provide scoped cross-role tools for high-frequency needs (e.g., a `verify_fact` tool for the synthesis agent) while routing complex cases through the coordinator
- Use `tool_choice` forced selection to ensure a specific tool is called first (e.g., forcing `extract_metadata` before enrichment tools), then process subsequent steps in follow-up turns
- Setting `tool_choice: "any"` guarantees the model calls a tool rather than returning conversational text

## MCP Server Integration

- **Project-level** (`.mcp.json`): shared team tooling, version-controlled
- **User-level** (`~/.claude.json`): personal/experimental servers
- Environment variable expansion in `.mcp.json` (e.g., `${GITHUB_TOKEN}`) for credential management without committing secrets
- Tools from all configured MCP servers are discovered at connection time and available simultaneously to the agent
- MCP resources expose content catalogs (issue summaries, documentation hierarchies, database schemas) to reduce exploratory tool calls

### Configuration best practices

- Configure shared MCP servers in project-scoped `.mcp.json` with environment variable expansion for authentication tokens
- Configure personal/experimental MCP servers in user-scoped `~/.claude.json`
- Enhance MCP tool descriptions to explain capabilities and outputs in detail, preventing the agent from preferring built-in tools (like Grep) over more capable MCP tools
- Choose existing community MCP servers over custom implementations for standard integrations (e.g., Jira), reserving custom servers for team-specific workflows
- Expose content catalogs as MCP resources to give agents visibility into available data without requiring exploratory tool calls

## Built-in Tool Selection (Read, Write, Edit, Bash, Grep, Glob)

- **Grep**: content search (function names, error messages, import statements)
- **Glob**: file path pattern matching (finding files by name or extension)
- **Read/Write**: full file operations; **Edit**: targeted modifications using unique text matching
- When Edit fails due to non-unique text matches, use Read + Write as a fallback for reliable file modifications

### Selection patterns

- Select Grep for searching code content across a codebase (e.g., finding all callers of a function, locating error messages)
- Select Glob for finding files matching naming patterns (e.g., `**/*.test.tsx`)
- Use Read to load full file contents followed by Write when Edit cannot find unique anchor text
- Build codebase understanding incrementally: start with Grep to find entry points, then use Read to follow imports and trace flows, rather than reading all files upfront
- Trace function usage across wrapper modules by first identifying all exported names, then searching for each name across the codebase
