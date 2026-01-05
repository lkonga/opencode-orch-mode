# Web Research Integration Reference

This document describes when and how to integrate external web research during surgical implementation.

## When to Use Web Research

### Conditional Triggers

Use web research **only if** you determine it's required:

1. **Unknown API usage patterns**
   - New library or framework
   - Undocumented behavior
   - Breaking changes in versions

2. **Best practice clarification**
   - Security patterns
   - Performance optimization
   - Industry standards

3. **Error resolution**
   - Unfamiliar error messages
   - Platform-specific issues
   - Edge cases

### When NOT to Use Research

❌ Don't research if:
- Implementation plan is clear
- Code patterns are standard
- Examples exist in codebase
- Documentation is available locally

## Research Tool Selection

### brave_search

**Best For**:
- General programming questions
- Current best practices
- Recent framework updates
- Error message lookups

**Usage Pattern**:
```bash
brave_search("TypeScript async error handling best practices")
brave_search("React hooks useEffect cleanup pattern")
brave_search("Node.js memory leak debugging")
```

**Limitations**:
- May return outdated results
- Requires filtering for relevance
- Can be overwhelming with results

### context7

**Best For**:
- Specific API documentation
- Library usage examples
- Framework patterns
- Quick reference lookups

**Usage Pattern**:
```bash
context7("Express.js middleware error handling")
context7("Jest mock implementation examples")
context7("TypeORM query builder relations")
```

**Advantages**:
- Focused results
- Recent information
- Code-centric

### perplexity_search

**Best For**:
- Comprehensive explanations
- Multi-source synthesis
- Current technology trends
- Comparative analysis

**Usage Pattern**:
```bash
perplexity_search("What is the difference between React useCallback and useMemo?")
perplexity_search("Best practices for GraphQL schema design in 2024")
perplexity_search("How to implement JWT refresh tokens in Node.js")
```

**Advantages**:
- Synthesized answers
- Multiple sources
- Contextual understanding

## Research Workflow

### Step 1: Determine Need

Before researching, ask:
1. Is this information in the codebase?
2. Is this pattern standard/common?
3. Does the implementation plan provide guidance?
4. Is this blocking implementation?

**If NO to all**: Consider research

### Step 2: Formulate Query

**Good Queries**:
- Specific and focused
- Include technology/version
- Mention specific problem/need
- Use technical terms

**Examples**:
```
✅ "TypeScript generic constraints with interfaces"
✅ "Express.js async middleware error handling"
✅ "React hooks cleanup on unmount"

❌ "TypeScript help"
❌ "Express problems"
❌ "React not working"
```

### Step 3: Execute Search

**Single Tool Approach**:
```bash
# For quick lookups
brave_search("specific technical query")
```

**Multi-Tool Approach**:
```bash
# For complex questions
context7("API usage patterns")
perplexity_search("Best practices explanation")
```

### Step 4: Filter Results

**Criteria**:
- Relevance to specific problem
- Recency (prefer 2023+)
- Authority (official docs, trusted sources)
- Code examples included

**Process**:
1. Scan titles/snippets
2. Identify 2-3 most relevant
3. Extract key information
4. Ignore tangential results

### Step 5: Apply Knowledge

**Integration**:
1. Adapt pattern to your context
2. Match existing code style
3. Add comments if non-obvious
4. Document source if unusual pattern

**Example**:
```typescript
// Based on Express.js best practices for async error handling
// Reference: [source URL if available]
const asyncHandler = (fn: Function) => (req: Request, res: Response, next: NextFunction) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};
```

## Integration with Other Skills

### With Relentless Web Research Skill

When implementation requires **extensive** research:

**Trigger Delegation**:
```
"This phase requires understanding of authentication patterns.
Delegating to $RelentlessWebResearch for comprehensive research
on OAuth 2.0 implementation patterns."
```

**When to Delegate**:
- Multiple unknowns
- Complex technical decision
- Need comprehensive understanding
- Time allows for deep research

**Pattern**:
1. Pause implementation
2. Call `$RelentlessWebResearch`
3. Receive synthesized findings
4. Resume implementation with knowledge

### With Architect-Coder Workflow

**Research in Architect Phase**:
- Architect gathers high-level patterns
- Research informs implementation plan
- Coder implements without further research

**Research in Coder Phase**:
- Coder encounters unexpected issue
- Quick targeted research
- Resolve and continue

## Research Token Budget

### Budget Allocation

From 21,000 line budget:
- Research queries: ~100 lines
- Result reading: ~500 lines
- Total research: ~600 lines (3%)

### Budget Tracking

**Mental Counter**:
```
Implementation Context: 800 lines
+ Research queries: 100 lines
+ Research results: 400 lines
= 1,300 lines total (6% of budget)
```

### Budget Optimization

**Strategies**:
1. **Targeted queries** (specific, not broad)
2. **Limit result reading** (top 3 results only)
3. **Extract key points** (don't copy entire articles)
4. **Summarize findings** (in your own words)

## Common Research Scenarios

### Scenario 1: Unknown Library API

**Situation**: Implementation requires library you haven't used

**Approach**:
```bash
# Quick API reference
context7("library-name API usage examples")

# If needed, best practices
perplexity_search("library-name best practices and common patterns")
```

**Time Limit**: 5 minutes max

### Scenario 2: Error Message

**Situation**: Verification fails with unfamiliar error

**Approach**:
```bash
# Search exact error message
brave_search("ExactErrorMessage framework-name")

# Scan top 3 results for solution
```

**Time Limit**: 3 minutes max

### Scenario 3: Security Pattern

**Situation**: Need to implement authentication/authorization

**Approach**:
```bash
# Get current best practices
perplexity_search("authentication pattern implementation language-name 2024")

# Verify with specific examples
context7("authentication middleware implementation")
```

**Time Limit**: 10 minutes max

### Scenario 4: Performance Optimization

**Situation**: Need to optimize specific operation

**Approach**:
```bash
# Research optimization techniques
brave_search("operation-type performance optimization language-name")

# Find benchmarks if available
context7("operation-type benchmark comparison")
```

**Time Limit**: 10 minutes max

## Best Practices

### DO:
✅ Research specific, focused questions
✅ Limit time spent on research
✅ Extract only relevant information
✅ Document unusual patterns
✅ Verify findings before implementing

### DON'T:
❌ Research before reading implementation plan
❌ Spend >10 minutes on single research topic
❌ Copy code without understanding
❌ Research common/standard patterns
❌ Let research delay implementation

## Emergency Research Protocol

If research is taking too long:

1. **Stop** current research
2. **Summarize** what you've learned
3. **Make decision** based on available info
4. **Implement** with best knowledge
5. **Note** uncertainty in comments
6. **Continue** with implementation

## Research Summary Template

After research, document briefly:

```markdown
## Research Summary: [Topic]

**Query**: [What you searched for]
**Source**: [brave_search/context7/perplexity_search]
**Key Findings**:
- Finding 1
- Finding 2
- Finding 3

**Application**: [How you'll apply this knowledge]
**References**: [URLs if available]
**Time Spent**: [X minutes]
```

## Integration Points

### In Phase Planning
- No research needed (Architect handles)

### In Context Gathering
- Quick API lookups only
- Limit to 5 minutes

### In Implementation
- Research specific issues as they arise
- Use targeted queries

### In Verification
- Research error messages if needed
- Quick troubleshooting only

## Progressive Disclosure

For more comprehensive research needs:
- See `$RelentlessWebResearch` skill
- Consider delegating complex research
- Return to implementation when done
