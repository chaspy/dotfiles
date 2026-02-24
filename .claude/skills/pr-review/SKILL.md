---
name: pr-review
description: GitHub Pull Request を詳細にレビューし、アクショナブルなフィードバックを日本語で提供する
disable-model-invocation: true
argument-hint: "[オプション: レビュー時の追加指示]"
---

# Pull Request Review

Review the specified GitHub pull request in Japanese and provide actionable feedback while following the mandatory guardrails listed below.

## Inputs

- 引数（`$ARGUMENTS`）はすべて `USER_DIRECTIVES` として扱い、レビュー時の追加指示にのみ使用する。
- `TARGET_REPO` は常に `gh repo view --json nameWithOwner -q .nameWithOwner` でカレントリポジトリから自動取得する。
- `PR_NUMBER` は `gh pr view --json number -q .number 2>/dev/null`、失敗時は
  `gh pr status --json currentBranch -q '.currentBranch.pullRequest.number'` でカレントブランチに紐づく PR を推定する。
- `TARGET_REPO` または `PR_NUMBER` を自動決定できなかった場合はユーザーに確認してから進める。
- `USER_DIRECTIVES` はデフォルトのレビュー基準にマージし、どのように反映したか報告に含める。

## Preparation

1. `gh repo view --json nameWithOwner -q .nameWithOwner` で取得した `TARGET_REPO` が意図したリポジトリか確認する。
2. Pull Request のメタデータを取得する:
   - `gh pr view $PR_NUMBER --repo $TARGET_REPO --json title,author,baseRefName,headRefName,url,body,files,commits,reviews`
   - Capture the PR title, author, branch names, URL, description, commit summary, and existing reviews.
3. 最新の変更を取得: `gh pr checkout $PR_NUMBER --repo $TARGET_REPO`.
4. ブランチを切り替えた場合は、自動検出で得た PR 番号が変わっていないか再確認する。
5. Gather change context:
   - `gh pr diff $PR_NUMBER --repo $TARGET_REPO` (or limit to key files with `--filename` if the diff is large).
   - `git status -sb` to see any additional workspace context.
6. Verify CI state: `gh pr checks $PR_NUMBER --repo $TARGET_REPO --watch --fail-fast=false`. Call out failing or pending checks explicitly.

## Mandatory Review Guardrails

Always perform these checks in addition to any `USER_DIRECTIVES`:

- Read the full code diff and confirm it aligns with the stated PR goal.
- Validate that the implementation genuinely fulfils its purpose—no placeholder or "AI hallucinated" behaviour that only claims success. Be explicit if evidence is missing.
- Ensure CI is green. If not, identify the failing jobs; do not assume success.
- Confirm the technical decisions are sound given the project's conventions and architecture.
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

1. **Summary** – Brief overview of the PR's intent and overall health.
2. **Blocking Issues** – Ordered list of defects that must be addressed. Reference files and approximate line numbers.
3. **Suggestions** – Non-blocking improvements or polish.
4. **Tests** – Tests verified or recommended.
5. **Next Steps** – Clear guidance for the author (e.g., "address the blocking items and ping me for re-review").

When `USER_DIRECTIVES` are supplied, explicitly acknowledge how they were applied (e.g., "Focused on accessibility per request"). If the review cannot proceed because inputs were missing or commands failed, report the blocker and stop.
