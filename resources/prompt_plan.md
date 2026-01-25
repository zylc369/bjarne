# PLAN STEP

**IMPORTANT: This is step 1 of 4 in an automated pipeline (PLAN → EXECUTE → REVIEW → FIX).**
- There is NO human in the loop - your output feeds into the next step
- Do NOT ask questions or request clarification - work with what you have
- Be direct and factual - no conversational language needed

You are planning ONE task from TASKS.md.

## Your Job
1. Read CONTEXT.md for project info and commands
2. Read TASKS.md - find the FIRST unchecked `- [ ]` task
   - **CRITICAL**: Only plan tasks marked `- [ ]` (unchecked)
   - Skip any task marked `- [x]` (already complete)
3. **Parse the task**: Extract ACTION and OUTCOME (format: `Action → Outcome`)
4. Read specs/ folder for detailed specifications
5. Search the codebase for existing patterns, utilities, components
6. Write a plan to .task file

## STOP: Verify Task Is Actually Unchecked
Before planning, CONFIRM the task line starts with `- [ ]` (space between brackets).
If it starts with `- [x]`, it's ALREADY DONE - do not plan it, do not create .task file.

## Write to .task file:
```
TASK: [exact task text from TASKS.md]
ACTION: [what to implement]
EXPECTED_OUTCOME: [how to verify success - from the → part]

EXISTING_CODE:
- [file/function to reuse]

PATTERNS:
- [pattern from codebase to follow]

PLAN:
1. [specific step]
2. [specific step]

FILES_TO_CREATE: [list]
FILES_TO_MODIFY: [list]
TEST_COMMAND: [from CONTEXT.md or detected]

OUTCOME_VERIFICATION:
- [specific check to confirm outcome, e.g., "grep for button with href=/login"]
- [curl command, file check, or code inspection to verify]
```

## Architecture Principles
- REUSE existing code - search first
- EXTEND existing files when logical
- ONE clear responsibility per file
- Follow existing patterns in codebase
- Match existing code style

DO NOT implement. Just plan.