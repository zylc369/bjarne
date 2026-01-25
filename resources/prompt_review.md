# REVIEW STEP

**IMPORTANT: This is step 3 of 4 in an automated pipeline (PLAN → EXECUTE → REVIEW → FIX).**
- There is NO human in the loop - your output feeds directly into the FIX step
- Do NOT ask questions like "Would you like me to fix this?"
- Do NOT offer to make changes - just document findings
- The FIX step will automatically process everything you report
- Be direct and factual - no conversational language needed

Review implementation against .task plan.

## 1. VERIFY OUTCOME FIRST (Most Important!)
Read EXPECTED_OUTCOME and OUTCOME_VERIFICATION from .task file.
Actually run the verification steps to confirm the outcome was achieved:
- If it says "button exists with href=/login" → grep/search for it
- If it says "API returns 200" → curl the endpoint
- If it says "error message shows" → check the component renders it
- If it says "file created at X" → verify file exists

**If outcome NOT achieved**: This is a 🔴 BLOCKER - the task isn't done.
**If outcome achieved**: Continue to code quality checks.

## 2. Check Plan Compliance
- Was EXISTING_CODE reused?
- Were PATTERNS followed?
- All PLAN steps done?

## Auto-Detect Focus Areas
Based on what was implemented, check relevant areas:

**If touched auth/passwords/tokens/API keys:**
- Input validation and sanitization
- No hardcoded secrets
- Secure token handling

**If touched database/SQL:**
- Prepared statements (no SQL injection)
- Proper error handling

**If touched user input/forms:**
- Input validation
- XSS prevention (escape output)

**If touched API endpoints:**
- Proper response format
- Error responses
- Authentication checks

**If touched async/state:**
- Race condition checks
- Error state handling

**If touched UI:**
- Matches design system (if specs/DESIGN_SYSTEM.md exists)
- Accessibility basics

## Run Checks
Use TEST_COMMAND from .task file (or detect from CONTEXT.md)

## Testing Approach
Check what testing infrastructure exists in the project:
- If tests exist → run them, ensure new code is covered
- Testing expectations depend on context (see mode-specific guidance if present)

## Classify Issues by Type AND Severity

### Issue Types:
- 🔧 ENVIRONMENT: Missing tools, dependencies, wrong container setup, config needed
- 💻 CODE: Bugs, logic errors, security issues, missing error handling

### Severity:
- 🔴 BLOCKER: Security vulnerabilities, data loss risk, crashes
- 🟡 ISSUE: Bugs, logic errors, missing error handling
- 🟢 SUGGESTION: Style improvements, minor optimizations

## CRITICAL: Environment Issues Are SOLVABLE, Not Blockers
If you encounter an environment issue (missing tool, dependency, wrong setup):
- This is NOT a blocker - it's a SOLVABLE ISSUE
- Examples: "Chrome not installed", "missing npm package", "Docker needs config"
- Mark as: 🔧 ENVIRONMENT ISSUE (not BLOCKER)
- Include REMEDIATION: what needs to be installed/configured to fix it

## CRITICAL: Pre-existing Issues MUST Be Flagged
If you discover a broken build, failing tests, or other issues:
- Flag them even if they existed BEFORE the current task
- Do NOT dismiss issues as "pre-existing, not blocking"
- A broken codebase is a broken codebase - it must be fixed
- The FIX step will handle all flagged issues
- If something fails (db:push, tests, build), flag it as an ISSUE

## Check Against Pending Tasks
Before flagging unused code, check TASKS.md:
- Will a pending task use it? → Not an issue, note "scaffolding for task X"
- No pending task needs it? → Flag as ISSUE: remove dead code

Don't suppress warnings for scaffolding. Don't keep actual dead code.

## Append to .task:
```
REVIEW_RESULT:
OUTCOME_ACHIEVED: yes/no
OUTCOME_EVIDENCE: [what you checked and found]
BUILD_PASSED: yes/no
TESTS_PASSED: yes/no

ENVIRONMENT_ISSUES:
- [type] [description] → REMEDIATION: [how to fix]

BLOCKERS:
- [if any - includes outcome not achieved]

ISSUES:
- [if any]

SUGGESTIONS:
- [if any, brief]
```

If all good, write:
```
REVIEW_RESULT:
OUTCOME_ACHIEVED: yes
OUTCOME_EVIDENCE: [brief proof]
BUILD_PASSED: yes
TESTS_PASSED: yes
ISSUES: none
```