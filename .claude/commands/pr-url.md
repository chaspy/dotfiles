# PR URL 取得

現在のブランチに関連付けられているPull RequestのURLを取得して表示します。

## プロセス

1. **PRの存在確認**
   - `gh pr view --json url -q .url` でPRのURLを取得
   - PRが存在しない場合は適切なメッセージを表示

2. **URL表示**
   - 取得したPR URLをクリック可能な形式で表示
   - URLが正常に取得できた場合はそのまま出力

## 使用するコマンド

```bash
gh pr view --json url -q .url
```

## 出力形式

```
🔗 Current PR URL:
https://github.com/owner/repo/pull/123
```

## エラーケース

- PRが存在しない場合: "No PR found for current branch"
- GitHub CLIが認証されていない場合: 認証手順を案内
- リポジトリがGitHubでない場合: 適切なエラーメッセージ