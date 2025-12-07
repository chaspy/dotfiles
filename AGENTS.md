# Repository Guidelines

## Project Structure & Module Organization
- Root contains user dotfiles (e.g., `.zshrc`, `.vimrc`, `.gitconfig`) and helper configs (`dein.toml`, `settings.json`).
- `symlink.sh`: main setup script that links files into `$HOME` and platform-specific config dirs (e.g., VS Code on macOS).
- `docs/`: lightweight notes and usage examples. No build assets or binaries in this repo.

## Build, Test, and Development Commands
- `bash ./symlink.sh`: creates/refreshes symlinks into your environment. Safe to re-run.
- Verify links:
  - `ls -l $HOME/.zshrc` and `readlink $HOME/.zshrc`
  - VS Code: `ls -l "$HOME/Library/Application Support/Code/User/settings.json"`
- Dry-run approach: read the script first; no dedicated dry-run mode.

## Coding Style & Naming Conventions
- Shell: `bash` with `set -euo pipefail` and `-o pipefail` for safety. Keep functions small and idempotent.
- Indentation: 2 spaces; wrap at ~100 columns; prefer long flags.
- Filenames: standard dotfile names (leading `.`) at repo root; avoid platform-specific suffixes in filenames—handle in script logic.
- Don’t store secrets; reference external secret files via env or local, untracked paths.

## Testing Guidelines
- No formal test harness. Validate:
  - Symlink integrity: `readlink -f` (or `readlink` on macOS) returns an existing target.
  - Re-run `symlink.sh` is no-op and doesn’t create circular links (script includes checks).
- When changing `symlink.sh`, test on a fresh shell and verify VS Code, Git, and Vim configs load as expected.

## Commit & Pull Request Guidelines
- Commit style: Conventional Commits (`feat:`, `fix:`, `test:`) as seen in history. Keep commits focused and descriptive.
- PRs should include:
  - Summary of change, affected files, and why.
  - Manual verification steps and example outputs (e.g., `ls -l` of new links).
  - Screenshots optional for editor/UI changes.
  - PR description text must be written in Japanese (英語は必要に応じて併記可)。

## Security & Configuration Tips
- Review scripts before running; they modify paths under `$HOME` but are designed to be idempotent.
- macOS-specific paths are present; add guards if extending to Linux/WSL.
- Never commit tokens or local secrets; add them to ignored, machine-local locations.

---

## Codex CLI グローバル指示

Codex CLI がこのリポジトリで作業するときは、以下を必ず守ってください。

1. **回答は常に日本語で行うこと。**  
   - 技術用語など必要な部分のみ英語を併記して構いませんが、全体の文章は日本語でまとめてください。
   - スラッシュコマンド（例: `/pr-review`, `/review`）の最終レポートも日本語で出力してください（ログやコードは英語のままで可）。
2. 既に `.codex/prompts/` や `.claude/commands/` に用意したスラッシュコマンドを活用し、重複する説明は避けること。
3. 判断に迷った場合はユーザへ確認を求め、独断で決定しないこと。
4. `git` コマンドや `gh` コマンドを常に活用し、PR の作成や本文編集は Codex 自身の最優先の使命であると理解して行動すること。
5. Fail First 方針: 実装に失敗したら即座にエラーを報告し、状況と判断をユーザと共有してから次のアクションを決めること。ユーザが明示的に指示しない限り、独断でフォールバックや回避策を差し込まないこと。

このファイルを更新したら Codex セッションを再起動して反映させてください。
