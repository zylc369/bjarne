Environment issues are SOLVABLE. You must:
1. Read the REMEDIATION from .task file
2. ADD A NEW TASK to TASKS.md to fix the environment issue
   - Insert it BEFORE the current task (so it runs next iteration)
   - Format: `- [ ] Setup: [remediation action]`
   - Examples:
     - `- [ ] Setup: Install Chromium and dependencies in Dockerfile.dev`
     - `- [ ] Setup: Add missing npm package X to dependencies`
     - `- [ ] Setup: Configure Docker to support tool Y`
3. Unmark current task back to `- [ ]` (it will retry after environment is fixed)
4. Delete .task file
5. DO NOT mark as blocked - the environment task will fix it