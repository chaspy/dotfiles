---
name: resolve-conflict
description: PR のマージコンフリクトを自動検出・解消する。base ブランチをマージし、コンフリクトを解析・解消してプッシュする。
disable-model-invocation: true
argument-hint: "[PR番号]"
---

# PR コンフリクト解消

PR のマージコンフリクトを自動検出・解消する。

## Inputs

- 引数（`$ARGUMENTS`）は対象の PR 番号やブランチ名として扱う。空の場合はカレントブランチの PR を対象にする。

## 手順

### 1. 対象 PR とコンフリクトの確認

```bash
# PR 番号の特定
PR_NUMBER=${ARGUMENTS:-$(gh pr view --json number -q .number 2>/dev/null)}
```

- `PR_NUMBER` が取得できない場合はユーザーに確認する
- `gh pr view $PR_NUMBER --json mergeable,mergeStateStatus,baseRefName,headRefName` でコンフリクト状態を確認する
- `mergeable` が `MERGEABLE` の場合はコンフリクトなしとして終了する
- コンフリクトがある場合は base ブランチ名を取得して次に進む

### 2. base ブランチの最新を取り込む

```bash
BASE_BRANCH=$(gh pr view $PR_NUMBER --json baseRefName -q .baseRefName)
HEAD_BRANCH=$(gh pr view $PR_NUMBER --json headRefName -q .headRefName)

# 最新のリモート情報を取得
git fetch origin $BASE_BRANCH

# HEAD ブランチに切り替え
git checkout $HEAD_BRANCH

# base ブランチをマージ
git merge origin/$BASE_BRANCH
```

### 3. コンフリクトの解析

`git diff --name-only --diff-filter=U` でコンフリクトのあるファイル一覧を取得し、各ファイルについて：

1. `git diff` でコンフリクトマーカー（`<<<<<<<`, `=======`, `>>>>>>>`）の箇所を確認する
2. ファイルの全体を読み、コンフリクト箇所の文脈を理解する
3. base ブランチ側と head ブランチ側の両方の変更意図を把握する

### 4. コンフリクトの解消

各コンフリクトファイルについて：

1. 両方の変更を統合できる場合は統合する（最も望ましい）
2. head ブランチの変更を優先すべき場合はそちらを採用する
3. 判断が難しい場合はユーザーに確認する

**解消の原則：**
- ロックファイル（`package-lock.json`, `go.sum`, `yarn.lock` 等）はマージ後に再生成する
  - `package-lock.json`: `npm install`
  - `yarn.lock`: `yarn install`
  - `go.sum`: `go mod tidy`
- 自動生成ファイルはコンフリクトを手動解消せず再生成する
- コードのコンフリクトは意味を理解した上で解消し、構文エラーがないことを確認する

### 5. 解消結果の検証

```bash
# コンフリクトマーカーが残っていないか確認
git grep -n "<<<<<<< " || echo "コンフリクトマーカーなし"

# ステージング
git add -A

# ビルド・テストが通るか確認（プロジェクトに応じて）
# npm test, go test ./..., etc.
```

### 6. コミットとプッシュ

```bash
git commit -m "Merge branch '$BASE_BRANCH' into $HEAD_BRANCH

Resolve merge conflicts"

git push origin $HEAD_BRANCH
```

### 7. 結果報告

以下の形式で報告する：

1. **解消したファイル** - コンフリクトがあったファイルと解消方法の一覧
2. **解消方針** - 各ファイルでどちらの変更を採用したか、統合したか
3. **検証結果** - コンフリクトマーカー残留チェック、ビルド・テスト結果
4. **注意点** - 手動確認が推奨される箇所があれば明記

## 注意事項

- コンフリクト解消の判断に自信がない場合は必ずユーザーに確認する
- force push は絶対に行わない
- マージコミットのメッセージには解消したファイルの情報を含める
- 解消後は必ずコンフリクトマーカーが残っていないことを検証する
