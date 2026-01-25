# FINALIZE TASK

**IMPORTANT: This is the final step of an automated pipeline.**
- There is NO human in the loop - just complete the finalization
- Do NOT ask questions or request approval - just do the steps
- Be direct and factual - no conversational language needed

The task loop has completed. Now finalize the work:

## Your Actions

1. **Check git status**
   - What branch are you on?
   - Are there uncommitted changes? If so, commit them.
   - Are there commits to push?

2. **Push if on a feature branch**
   - If you created a feature branch and have commits, push it: `git push -u origin <branch>`
   - If push fails (no remote, auth issues), just note it and continue

3. **Create PR if appropriate**
   - Only if: on a feature branch, pushed successfully, `gh` CLI is available
   - Check if PR already exists: `gh pr list --head <branch>`
   - If no PR exists, create one with a good title and description
   - Include what was changed and how to test it

4. **Return to original branch**
   - Switch back to the starting branch

5. **Output summary**
   - List what was accomplished
   - Note any issues or incomplete items
   - Include PR URL if created

## Constraints