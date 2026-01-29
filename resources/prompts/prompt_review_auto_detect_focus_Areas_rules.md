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