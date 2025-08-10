# PR URL 取得と表示

現在のブランチに関連付けられているPull RequestのURLを取得して表示し、ブラウザで開きます。

## プロセス

1. **PRの存在確認**
   - `gh pr view --json url -q .url` でPRのURLを取得
   - PRが存在しない場合は適切なメッセージを表示

2. **URL表示とブラウザで開く**
   - 取得したPR URLをクリック可能な形式で表示
   - `gh pr view --web` でPRをデフォルトブラウザで自動的に開く

## 使用するコマンド

```bash
# PRのURLを取得
gh pr view --json url -q .url

# PRをブラウザで開く
gh pr view --web
```

## 出力形式

```
🔗 Current PR URL: https://github.com/owner/repo/pull/123
🌐 Opening in browser...
```

## エラーケース

- PRが存在しない場合: "No PR found for current branch. Use /pr-create to create one"
- GitHub CLIが認証されていない場合: 認証手順を案内
- リポジトリがGitHubでない場合: 適切なエラーメッセージ