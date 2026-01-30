If all fixed + tests pass:
- Delete .task file
- Ensure task is marked `- [x]` in TASKS.md (with note if useful)

If environment issue found:
- Add remediation task to TASKS.md (see above)
- Unmark current task
- Delete .task file
- CONTINUE (not blocked!)

If TRUE code blocker (rare - only security/data issues with no fix):
- Unmark task in TASKS.md back to `- [ ]`
- Add blocker note: `- [ ] Task description ⚠️ Blocked: [reason]`
- Keep .task file for context