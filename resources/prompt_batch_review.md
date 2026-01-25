# REVIEW STEP (Batch Mode)

**IMPORTANT: This is step 3 of 4 in an automated pipeline (PLAN → EXECUTE → REVIEW → FIX).**
- There is NO human in the loop - your output feeds directly into the FIX step
- Do NOT ask questions like "Would you like me to fix this?"
- Do NOT offer to make changes - just document findings
- The FIX step will automatically process everything you report
- Be direct and factual - no conversational language needed

Review implementation against .task plan - verify ALL batched tasks.

## 1. VERIFY ALL OUTCOMES (Most Important!)
Read EXPECTED_OUTCOMES and OUTCOME_VERIFICATION from .task file.
For EACH task listed, actually run the verification steps:
- If it says "button exists with href=/login" → grep/search for it
- If it says "API returns 200" → curl the endpoint
- If it says "error message shows" → check the component renders it
- If it says "file created at X" → verify file exists

**Track each task's outcome separately:**
- Task 1: ✅ achieved / ❌ not achieved
- Task 2: ✅ achieved / ❌ not achieved
- etc.

**If ANY outcome NOT achieved**: This is a 🔴 BLOCKER - that task isn't done.

## 2. Check Plan Compliance
- Were ALL tasks in the batch addressed?
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

## Classify Issues by Type AND Severity

### Issue Types:
- 🔧 ENVIRONMENT: Missing tools, dependencies, wrong container setup, config needed
- 💻 CODE: Bugs, logic errors, security issues, missing error handling

### Severity:
- 🔴 BLOCKER: Security vulnerabilities, data loss risk, crashes, outcome not achieved
- 🟡 ISSUE: Bugs, logic errors, missing error handling
- 🟢 SUGGESTION: Style improvements, minor optimizations

## Append to .task:
```
REVIEW_RESULT:
OUTCOMES_ACHIEVED:
- Task 1: yes/no - [evidence]
- Task 2: yes/no - [evidence]
BUILD_PASSED: yes/no
TESTS_PASSED: yes/no

ENVIRONMENT_ISSUES:
- [type] [description] → REMEDIATION: [how to fix]

BLOCKERS:
- [if any - includes outcomes not achieved]

ISSUES:
- [if any]

SUGGESTIONS:
- [if any, brief]
```

If all good, write:
```
REVIEW_RESULT:
OUTCOMES_ACHIEVED:
- Task 1: yes - [brief proof]
- Task 2: yes - [brief proof]
BUILD_PASSED: yes
TESTS_PASSED: yes
ISSUES: none
```