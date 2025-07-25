# Claude Code カスタムコマンド設定

このディレクトリには、Claude Code用のカスタムコマンド、ロール、設定が含まれています。

## セットアップ

```bash
# dotfilesリポジトリのルートディレクトリで実行
./symlink.sh
```

これにより、以下のシンボリックリンクが作成されます：
- `~/.claude/settings.json`
- `~/.claude/commands`
- `~/.claude/CLAUDE.md`

## カスタムコマンド

| コマンド | エイリアス | 説明 |
|---------|-----------|------|
| `/pr-create` | `pr` | 現在の変更からPull Requestを作成 |
| `/compact` | `c` | 簡潔な回答モード |
| `/test` | `t` | テストを実行して結果を分析 |
| `/debug` | `d` | 詳細なデバッグ情報を提供 |
| `/explain` | `e` | コードの詳細説明 |

## ロール

- **security-expert**: セキュリティ脆弱性の分析
- **performance-expert**: パフォーマンス最適化
- **code-reviewer**: 厳格なコードレビュー

## 使用例

```
# PRを作成
/pr-create

# エイリアスを使用
pr

# 簡潔モードで回答
/compact このファイルを削除していい？

# コードの説明を求める
/explain src/main.js
```