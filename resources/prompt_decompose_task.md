# DECOMPOSE TASK

**IMPORTANT: This is the first step of an automated pipeline.**
- There is NO human in the loop - your output feeds into the task execution loop
- Do NOT ask questions or request clarification - work with what you have
- Be direct and factual - no conversational language needed

You are breaking down a task for an autonomous coding agent.

CRITICAL: You are working on an EXISTING project. Do NOT delete any source files,
configuration files, or project files. Only modify files directly related to this task.
The project's existing files are NOT bjarne artifacts - do NOT remove them.

## Instructions
1. Explore the codebase to understand the relevant code
2. Break this into discrete subtasks (or keep as one if simple enough)
3. Each subtask must have: Action → Outcome (verifiable)
4. Output ONLY a markdown checklist to SUBTASKS.md file

## Subtask Format
Each line must be: `- [ ] Action → Outcome`
- Action: What to implement (specific, atomic)
- Outcome: How to verify it worked (must be machine-checkable)

## Output
Write ONLY the subtask checklist to the SUBTASKS.md file. Nothing else.
Keep subtasks focused, atomic, and verifiable.