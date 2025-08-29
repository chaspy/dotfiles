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

## Security & Configuration Tips
- Review scripts before running; they modify paths under `$HOME` but are designed to be idempotent.
- macOS-specific paths are present; add guards if extending to Linux/WSL.
- Never commit tokens or local secrets; add them to ignored, machine-local locations.

