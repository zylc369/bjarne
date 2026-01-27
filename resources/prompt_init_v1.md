# PROJECT INITIALIZATION (Planning Only)

You have an idea file (freeform, any format) and detected environment info.
Your job: Create PLANNING FILES only (CONTEXT.md, TASKS.md, specs/).

## CRITICAL: This is a PLANNING phase, NOT implementation
- You create the roadmap, the PLAN→EXECUTE→REVIEW→FIX loop builds it
- DO NOT write any source code, HTML, CSS, JavaScript, Python, etc.
- DO NOT create the actual project files (index.html, app.py, main.js, etc.)
- ONLY create: CONTEXT.md, TASKS.md, and specs/*.md files
- The tasks you create will be implemented one-by-one in the dev loop

## Core Principle: RESPECT THE IDEA
- User's idea is the source of truth - don't change their concept
- If they specified something, use it exactly
- If they didn't specify, infer sensibly from context
- Fill gaps to make it buildable, but preserve their intent
- A detailed spec needs less inference; a vague idea needs more

## Phase 1: Understand
1. Read the idea file - extract what the user actually wants
2. Identify what's SPECIFIED (use as-is) vs what's UNSPECIFIED (infer)
3. Check detected environment for existing tech stack
4. If CLAUDE.md exists, read for existing project rules
5. **IF EXISTING PROJECT**: Explore the codebase! Read source files to understand:
   - What's already built
   - Code patterns and architecture used
   - What the idea is asking to ADD or CHANGE vs what exists

## Phase 2: Infer Missing Pieces (only if not specified)
For anything the user didn't specify, make smart choices:
- Tech stack: Use detected, or pick appropriate for project type
- Architecture: Simple and appropriate for scope (or follow existing patterns)
- Scope: Take idea at face value - don't expand or reduce

## Testing Principle: IF YOU CAN'T TEST IT, BUILD A WAY TO TEST IT
Unless user explicitly says "no tests", you MUST include testing:
- Add test framework setup task early (jest, pytest, vitest, etc.)
- Include test tasks for each major feature
- Tests enable the REVIEW step to verify work automatically
- Without tests, the feedback loop is blind
- Even simple projects benefit from basic smoke tests

## Phase 3: Create Files

### 1. CONTEXT.md (static reference for development)
```markdown
# [Project Name from idea]

## What We're Building
[User's vision - preserve their words/intent]

## Existing Codebase (if applicable)
[Summary of what already exists - key files, patterns, architecture]

## Tech Stack
[Detected or inferred]

## Commands
- Build: [detected or standard]
- Test: [detected or standard]
- Run: [detected or standard]

## Key Decisions
[Only if user specified preferences, constraints, or requirements]

## References
- specs/ for detailed specifications
```

### 2. TASKS.md
Break the idea into atomic tasks WITH VERIFIABLE OUTCOMES:
- Setup tasks first (if node_modules/vendor/.env missing)
- **For existing projects**: Tasks should reference existing code to modify/extend
- Then features from the idea (in logical order)
- Each task completable in one iteration
- **Format: `- [ ] Action → Outcome`**
  - Action: What to implement
  - Outcome: How to verify it worked (must be machine-checkable)
- Examples:
  - `- [ ] Add login button to navbar → Button with href="/login" exists in header`
  - `- [ ] Create /api/users endpoint → GET /api/users returns 200 with JSON array`
  - `- [ ] Add email validation → Invalid email shows error message`
- Number of tasks should match project scope (don't pad)

### 3. specs/ folder (only if needed)
Create specs that ADD VALUE - don't create empty scaffolds:
- API project with endpoints → specs/API.md with routes, payloads
- UI with specific design → specs/DESIGN_SYSTEM.md
- Complex data model → specs/DATA_MODEL.md
- Skip specs that would just repeat the idea

## What NOT to Do
- **DO NOT write implementation code** - no source files, no index.html, no app.py, etc.
- Don't add features the user didn't ask for
- Don't create specs that just restate obvious things
- Don't expand scope beyond what they described
- Don't change their architectural choices if specified
- Don't add "nice to have" tasks - stick to the idea
- Don't create tasks for "start server" or other manual user actions
- **For existing projects**: Don't recreate what already exists!

Read the idea, understand the vision, create the planning files. Implementation happens later.