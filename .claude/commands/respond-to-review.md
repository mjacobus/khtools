Respond to code review comments on the current PR. Arguments: $ARGUMENTS

## Instructions

1. **Detect the current PR** — run `gh pr view --json number,url,headRefName` to find the PR for the current branch. If no PR exists, stop and tell the user.

2. **Fetch all pending review comments** — run:
   ```
   gh api repos/{owner}/{repo}/pulls/{number}/comments --jq '.[] | {id: .id, path: .path, line: .line, body: .body, user: {login: .user.login}, in_reply_to_id: .in_reply_to_id}'
   ```
   Filter out comments that already have replies from you (check `in_reply_to_id` chains). If `$ARGUMENTS` specifies a reviewer name or comment IDs, filter to only those.

3. **Also fetch PR-level review comments** — run:
   ```
   gh api repos/{owner}/{repo}/pulls/{number}/reviews --jq '.[] | select(.state != "APPROVED" and .state != "DISMISSED") | {id: .id, body: .body, user: {login: .user.login}, state: .state}'
   ```

4. **Also fetch general PR comments** — these live on a *different* endpoint and are the easiest to miss:
   ```
   gh api repos/{owner}/{repo}/issues/{number}/comments --jq '.[] | {id: .id, body: .body, user: {login: .user.login}, created: .created_at}'
   ```
   A PR is an issue, so free-form comments (the ones typed in the bottom box, not attached to a line) are NOT returned by steps 2 or 3. A general comment from a **human** often carries the most important instruction on the PR — treat it as first-class review feedback. Ignore comments from bots (`github-actions[bot]`, the sticky quality-gate report).

5. **For EACH comment, one at a time:**

   a. **Read the relevant code** — open the file at the referenced path/line to understand context.

   b. **Evaluate technically** — is the suggestion correct for this codebase? Check:
      - Does it follow the conventions of the surrounding code?
      - Would it break existing functionality?
      - Is there a reason for the current implementation?
      - Does the reviewer have full context?

   c. **If the suggestion is valid** — fix the code, then reply to the specific comment thread:
      ```
      gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies -f body="Fixed — [brief description of change]."
      ```
      Note the `{number}`: `repos/.../pulls/comments/{id}/replies` (without it) returns 404.

      For a **general PR comment** (from step 4) there is no reply thread — post a new comment instead:
      ```
      gh api repos/{owner}/{repo}/issues/{number}/comments -f body="[response]"
      ```

   d. **If the suggestion is wrong or unclear** — push back with technical reasoning or ask for clarification, using the same endpoint as above for the comment's kind.

   e. **Commit the fix** (if code changed) before moving to the next comment. Use atomic commits.

6. **After all comments are addressed** — push once and summarize what was done.

## Rules

- **Reply to EACH comment INDIVIDUALLY** — never write a single summary response addressing multiple comments.
- **No performative agreement** — never say "Great point!", "You're absolutely right!", or "Thanks for catching that!". Just state the fix or push back technically.
- **Verify before implementing** — don't blindly apply suggestions. Check against the codebase first.
- **Push back when wrong** — if a suggestion violates project conventions, is technically incorrect, or is YAGNI, say so with reasoning.
- **One fix per commit** — each comment fix gets its own atomic commit.
- **Run linters and tests after fixes** — `bundle exec rubocop` and `bundle exec rspec` (at least the affected specs).
- **Cover all three sources** — inline comments, reviews, and general PR comments. A general comment asking for work (open an issue, gather evidence, write a message) counts as review feedback and must be answered like any other.
