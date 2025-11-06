# Pull Request Review

Note (Language): 全ての出力は日本語で記述すること。CLI の実行ログやコード断片は英語原文のままで構わないが、要約・指摘・助言などの説明文は日本語で行う。

Review the specified GitHub pull request and provide actionable feedback while following the mandatory guardrails listed below.

## Inputs

- Argument parsing rules (in order):
  1. Resolve `TARGET_REPO`:
     - If `$1` includes a slash (e.g. `owner/repo`), consume it as the repo slug.
     - Otherwise run `gh repo view --json nameWithOwner -q .nameWithOwner` to identify the current repository.
  2. Resolve `PR_NUMBER`:
     - If the next token is numeric, consume it as the PR number.
     - If no explicit PR number is supplied, detect from the current directory and branch in this order.
       実際に以下のコマンド列を順に実行して `PR_NUMBER` を埋めること。
       ```zsh
       set -euo pipefail
       TARGET_REPO=${TARGET_REPO:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}
       PR_NUMBER=${PR_NUMBER:-}
       if [[ -z ${PR_NUMBER:-} ]]; then
         PR_NUMBER=$(gh pr view --repo "$TARGET_REPO" --json number -q .number 2>/dev/null || true)
       fi
       if [[ -z ${PR_NUMBER:-} ]]; then
         PR_NUMBER=$(gh pr status --repo "$TARGET_REPO" --json currentBranch -q '.currentBranch.pullRequest.number' 2>/dev/null || true)
       fi
       if [[ -z ${PR_NUMBER:-} ]]; then
         BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --abbrev-ref HEAD)
         PR_NUMBER=$(gh pr list --repo "$TARGET_REPO" --head "$BRANCH" --state open --json number -q '.[0].number' 2>/dev/null || true)
       fi
       if [[ -z ${PR_NUMBER:-} ]]; then
         PR_NUMBER=$(gh pr list --repo "$TARGET_REPO" --head "$BRANCH" --state all --json number -q '.[0].number' 2>/dev/null || true)
       fi
       ```
       - これで取得できた最初の非空値を `PR_NUMBER` とする。
       - それでも取得できなかった場合は、英語ではなく日本語で次の処理を行うこと：
         1) 現在ブランチの候補PRを一覧提示（最大10件）
            ```zsh
            gh pr list --repo "$TARGET_REPO" --head "$BRANCH" --state all \
              --limit 10 --json number,title,headRefName,author,url \
              -q '.[] | "#\(.number) [\(.headRefName)] \(.title) by \(.author.login)\n\(.url)"'
            ```
         2) 「該当のPR番号を指定してください」と日本語で促す。
  3. Any remaining tokens (`$ARGUMENTS`) become `USER_DIRECTIVES`.
- Validate that both `TARGET_REPO` and `PR_NUMBER` are set. If detection fails at any stage, stop and ask the user for clarification.
- `USER_DIRECTIVES` capture extra guidance. Merge them with the default rubric and confirm in the report how they were honoured.

## Preparation

1. Confirm the local checkout matches the target repository. If not, run `gh repo clone $TARGET_REPO` or `gh repo set-default $TARGET_REPO` as needed.
2. Fetch the pull request metadata:
   - `gh pr view $PR_NUMBER --repo $TARGET_REPO --json title,author,baseRefName,headRefName,url,body,files,commits,reviews`
   - Capture the PR title, author, branch names, URL, description, commit summary, and existing reviews.
3. Download the latest changes: `gh pr checkout $PR_NUMBER --repo $TARGET_REPO`.
4. Re-run the PR number discovery step after checkout if the branch changed to ensure you are reviewing the correct PR.
5. Gather change context:
   - `gh pr diff $PR_NUMBER --repo $TARGET_REPO` (or limit to key files with `--filename` if the diff is large).
   - `git status -sb` to see any additional workspace context.
6. Verify CI state: `gh pr checks $PR_NUMBER --repo $TARGET_REPO --watch --fail-fast=false`. Call out failing or pending checks explicitly.

## Mandatory Review Guardrails

Always perform these checks in addition to any `USER_DIRECTIVES`:

- Read the full code diff and confirm it aligns with the stated PR goal.
- Validate that the implementation genuinely fulfils its purpose—no placeholder or “AI hallucinated” behaviour that only claims success. Be explicit if evidence is missing.
- Ensure CI is green. If not, identify the failing jobs; do not assume success.
- Confirm the technical decisions are sound given the project’s conventions and architecture.
- When unsure about intent or acceptable trade-offs, pause and ask the user for guidance rather than guessing.

## Review Rubric

Apply these lenses (and include any `USER_DIRECTIVES`):

1. **Correctness / Functionality**
   - Does the implementation satisfy the requirements described in the PR body and commits?
   - Identify logic bugs, edge cases, or regressions. Note broken flows, incorrect assumptions, and missing error handling.
2. **Testing**
   - Verify that new or modified behaviour has automated coverage.
   - Recommend concrete tests (unit/integration/e2e) when gaps exist. Call out brittle or flaky patterns.
3. **Security / Stability**
   - Examine inputs for validation, potential injection, resource leaks, and race conditions.
   - Flag concurrency hazards, panic paths, or unbounded resource usage.
4. **Performance**
   - Highlight inefficient queries, hot-path regressions, or unnecessary allocations.
5. **Readability / Maintainability**
   - Ensure naming, structure, and documentation make future changes straightforward.
   - Encourage refactors when complexity can be reduced without large rewrites.

## Reporting

Structure the response as:

1. **Summary** – Brief overview of the PR’s intent and overall health.
2. **Blocking Issues** – Ordered list of defects that must be addressed. Reference files and approximate line numbers.
3. **Suggestions** – Non-blocking improvements or polish.
4. **Tests** – Tests verified or recommended.
5. **Next Steps** – Clear guidance for the author (e.g., “address the blocking items and ping me for re-review”).

When `USER_DIRECTIVES` are supplied, explicitly acknowledge how they were applied (e.g., “Focused on accessibility per request”). If the review cannot proceed because inputs were missing or commands failed, report the blocker and stop.
