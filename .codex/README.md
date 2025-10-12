# Codex CLI カスタムプロンプト

このディレクトリは Codex CLI のスラッシュメニュー用カスタムプロンプト (`~/.codex/prompts/*.md`) を管理します。Claude 用の `.claude/commands` と同じ内容をシンボリックリンクで共有しているため、`./symlink.sh` を実行すると Codex でも同じスラッシュコマンドが利用できます。

## 仕様メモ

Codex CLI のカスタムプロンプト仕様は [Prompts ドキュメント](https://github.com/openai/codex/blob/main/docs/prompts.md) を参照してください（2025-10 時点）。

- 配置先: `$CODEX_HOME/prompts/` （デフォルト `~/.codex/prompts/`）
- 拡張子: `.md`
- スラッシュ名: ファイル名（拡張子を除いた部分）が `/` 以降の名前になる
- 変数展開: `$1..$9`, `$ARGUMENTS`, `$$` が使用可能。ダブルクオートで囲むとスペースを含む 1 引数として扱える。
- 追加・更新した場合は Codex の新規セッションを開始すると再読込される。

## 追加したコマンド

- `/review [owner/repo] <pr-number> [extra instructions...]`
  - リポジトリ省略時はカレントリポジトリ (`gh repo view` から取得) を自動利用。
  - 目的達成／AI チート検知／CI 成果確認など、レビューチェックリストを強制する。
  - 追加のレビューポリシーは 3 番目以降の引数（`$3..$9`）を結合して利用する。
- `/revierw …`
  - `/review` のエイリアス（同じ挙動）。
