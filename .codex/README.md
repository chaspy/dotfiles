# Codex CLI カスタムプロンプト

このディレクトリは Codex CLI のスラッシュメニュー用カスタムプロンプト (`~/.codex/prompts/*.md`) を管理します。`./symlink.sh` を実行すると、Codex CLI がシンボリックリンクを読み込まない制約を回避するため、`.claude/commands` の内容を実ファイルとして `~/.codex/prompts/` にコピーします（毎回上書きされるため最新状態が反映されます）。

## 仕様メモ

Codex CLI のカスタムプロンプト仕様は [Prompts ドキュメント](https://github.com/openai/codex/blob/main/docs/prompts.md) を参照してください（2025-10 時点）。

- 配置先: `$CODEX_HOME/prompts/` （デフォルト `~/.codex/prompts/`）
- 拡張子: `.md`
- スラッシュ名: ファイル名（拡張子を除いた部分）が `/` 以降の名前になる
- 変数展開: `$1..$9`, `$ARGUMENTS`, `$$` が使用可能。ダブルクオートで囲むとスペースを含む 1 引数として扱える。
- 追加・更新した場合は Codex の新規セッションを開始すると再読込される。

## 追加したコマンド

- `/pr-review [owner/repo] [pr-number] [extra instructions...]`
  - 引数なしでも使用可能。カレントリポジトリと現在のブランチが紐づく PR を自動検出（`gh pr view` / `gh pr status`）。
  - 目的達成／AI チート検知／CI 成果確認など、レビューチェックリストを強制する。
  - 追加のレビューポリシーは 3 番目以降の引数（`$3..$9`）を結合して利用する。
- `/revierw …`
  - `/pr-review` のエイリアス（同じ挙動）。
