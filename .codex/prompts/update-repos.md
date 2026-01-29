# 複数リポジトリの一括更新（origin のデフォルトブランチ）

指定したルート配下の Git リポジトリを走査し、`origin` のデフォルトブランチを判定して安全に最新化します。

## 使い方

- 通常モード（デフォルトブランチへ切り替えて更新）
  - `bash ~/.codex/scripts/update_repos.sh /path/to/root`

- 安全モード（切り替えなし）
  - `bash ~/.codex/scripts/update_repos.sh --no-checkout /path/to/root`
  - 現在のブランチがデフォルトブランチでない場合は `fetch` のみ行います。

## 挙動

- 未コミットがあるリポジトリはスキップします。
- `origin/HEAD` が取得できない場合は `git remote show origin` から HEAD branch を推定します。
- デフォルトブランチ検出後は `fetch` → `checkout` → `pull --ff-only` で更新します。
- ログはリポジトリごとに `== path` を出力します。
