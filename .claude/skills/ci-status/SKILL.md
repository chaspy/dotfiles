---
name: ci-status
description: 現在の PR の CI ステータスを確認し、失敗している場合は原因を分析して修正案を提示する
disable-model-invocation: true
argument-hint: "[オプション: --wait (CI完了まで待機)]"
---

# CI ステータスチェック

現在のPull RequestのCIステータスを確認し、失敗している場合は原因を分析して修正案を提示します。

## プロセス

1. **PRのCI状態を確認**
   - `gh pr checks` でCI/CDパイプラインの状態を取得
   - 各ジョブの成功/失敗状態を確認
   - 実行中のジョブがある場合は待機オプションを提供

2. **失敗の詳細分析**
   - 失敗したジョブのログを取得
   - エラーメッセージを抽出
   - 失敗パターンを分類（ビルド、テスト、Lint、型チェック等）

3. **原因の特定**
   - エラーログから根本原因を分析
   - 関連するソースコードを確認
   - 最近の変更との関連性を調査

4. **修正提案**
   - 具体的な修正方法を提示
   - 必要に応じてコードの修正を実行
   - 再実行が必要なジョブを特定

## 対応するCIシステム

- GitHub Actions
- CircleCI
- Jenkins
- GitLab CI
- その他（`gh pr checks`で取得可能なもの）

## 出力形式

```
🔍 CI Status Summary:
✅ build (passed)
❌ test (failed) - 3 tests failing
❌ lint (failed) - ESLint errors
⏳ deploy (running)

📋 Failed Job Analysis:
[詳細な失敗原因と修正案]
```
