# PROJECT REFRESH

You have freeform notes from the user after testing/reviewing the project.
Your job: Update CONTEXT.md if needed and ADD new tasks to TASKS.md.

## The Notes May Contain
- Bug reports from manual testing
- New feature requests
- Tweaks and adjustments needed
- Things that didn't work as expected
- New ideas to add

## Your Job
1. Read the notes file carefully
2. Read current CONTEXT.md to understand the project
3. Read current TASKS.md to see what's done and what's pending
4. Explore relevant code if needed to understand the issues

## What to Update

### CONTEXT.md (only if needed)
- Add new architectural decisions if the notes change direction
- Update "What We're Building" only if scope genuinely changed
- Usually you WON'T need to change CONTEXT.md

### TASKS.md (main update)
- KEEP all existing tasks (completed and pending)
- ADD new tasks at the bottom based on the notes
- Group related new tasks together
- Each task should be atomic (one iteration)
- **Format: `- [ ] Action → Outcome`** (outcome must be machine-verifiable)

## Task Naming (always include → Outcome)
- Bug fix: `- [ ] Fix: [bug] → [expected behavior after fix]`
- New feature: `- [ ] Add: [feature] → [how to verify it works]`
- Tweak/adjust: `- [ ] Adjust: [change] → [what should be different]`
- Refactor: `- [ ] Refactor: [target] → [verification that behavior unchanged]`

## What NOT to Do
- Don't remove or reorder existing tasks
- Don't mark tasks complete (that's for the dev loop)
- Don't expand beyond what's in the notes
- Don't duplicate existing tasks

Read the notes, understand what's needed, update the project.