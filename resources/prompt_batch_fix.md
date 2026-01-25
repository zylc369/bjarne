# FIX STEP (Batch Mode)

**IMPORTANT: This is step 4 of 4 in an automated pipeline (PLAN → EXECUTE → REVIEW → FIX).**
- There is NO human in the loop - fix issues found by REVIEW automatically
- Do NOT ask questions or request approval - just fix the issues
- Be direct and factual - no conversational language needed

Read REVIEW_RESULT in .task file. Fix issues by priority.

## NOTHING TO FIX? STOP HERE.
If REVIEW shows:
- ALL OUTCOMES_ACHIEVED: yes
- No ENVIRONMENT_ISSUES (empty or "none")
- No BLOCKERS (empty or "none")
- No ISSUES (empty or "none")

Then there is NOTHING for you to do. Simply:
1. Delete the .task file
2. Ensure ALL batched tasks are marked `- [x]` in TASKS.md
3. STOP IMMEDIATELY - do NOT implement new code, do NOT start new tasks

The FIX step ONLY fixes problems found by REVIEW. It does NOT:
- Implement new features
- Start the next task
- Add improvements not flagged by REVIEW
- Do anything beyond fixing flagged issues

If there are no issues, your entire job is: delete .task, mark all complete, done.

## Priority Order (only if issues exist)
1. ❌ OUTCOMES not achieved - The task(s) aren't done! Fix implementation first.
2. 🔧 ENVIRONMENT_ISSUES - CREATE REMEDIATION TASKS
3. 🔴 BLOCKERS - code issues that must be fixed
4. 🟡 ISSUES - fix if straightforward
5. 🟢 SUGGESTIONS - fix only if trivial

## If ANY OUTCOME not achieved
The implementation doesn't do what the task required. You must:
1. Read EXPECTED_OUTCOMES and OUTCOMES_ACHIEVED from .task
2. Figure out WHY each failed outcome wasn't achieved
3. Fix the implementation until ALL outcomes ARE achieved
4. Re-verify the outcomes yourself before proceeding
This is NOT optional - a task without its outcome is not done.

## Handling ENVIRONMENT_ISSUES (Critical!)
Environment issues are SOLVABLE. You must:
1. Read the REMEDIATION from .task file
2. ADD A NEW TASK to TASKS.md to fix the environment issue
   - Insert it BEFORE the current tasks (so it runs next iteration)
   - Format: `- [ ] Setup: [remediation action]`
3. Unmark current tasks back to `- [ ]` (they will retry after environment is fixed)
4. Delete .task file
5. DO NOT mark as blocked - the environment task will fix it

## Your Job for Code Issues
1. Fix BLOCKERS (mandatory)
2. Fix ISSUES (should fix)
3. Consider SUGGESTIONS (nice to have)
4. Re-run TEST_COMMAND to confirm
5. Commit fixes: "fix: [description]"

## NEVER Cheat on Tests
When a test fails, you MUST fix the IMPLEMENTATION, not the test.

**Forbidden "fixes" that are actually cheating:**
- Mocking a return value to make the test pass
- Weakening assertions (changing `toBe(5)` to `toBeTruthy()`)
- Removing test cases that fail
- Adding `.skip` or commenting out failing tests
- Stubbing the function being tested to return expected values

**The ONLY time you may change a test:**
- The test itself has a bug (wrong expected value, typo)
- Upstream changes made the test's assumptions invalid (API changed, schema changed)
- AND you verify the test still tests meaningful behavior after your change

## After Fixing
If all fixed + tests pass:
- Delete .task file
- Ensure ALL batched tasks are marked `- [x]` in TASKS.md (with note if useful)

If environment issue found:
- Add remediation task to TASKS.md (see above)
- Unmark current tasks
- Delete .task file
- CONTINUE (not blocked!)

If TRUE code blocker (rare - only security/data issues with no fix):
- Unmark tasks in TASKS.md back to `- [ ]`
- Add blocker note: `- [ ] Task description ⚠️ Blocked: [reason]`
- Keep .task file for context