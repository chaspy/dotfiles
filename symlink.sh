#!/usr/bin/env bash
set -eu
set -o pipefail

# スクリプトが置いてあるディレクトリ＝dotfiles リポジトリ
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOT_DIRECTORY="$SCRIPT_DIR"

# 循環参照チェック関数
check_circular_link() {
    local link_path="$1"
    if [ -L "$link_path" ]; then
        local target=$(readlink "$link_path")
        # 絶対パスに変換
        if [[ "$target" != /* ]]; then
            target="$(dirname "$link_path")/$target"
        fi
        # 自分自身を指していないかチェック
        if [ "$target" = "$link_path" ]; then
            echo "⚠️  循環参照を検出: $link_path -> $target"
            return 1
        fi
    fi
    return 0
}

# --- dotfiles 本体 ----------------------------------------------------------
for f in "$DOT_DIRECTORY"/.??*; do
  base="$(basename "$f")"

  # 同期しないファイル／ディレクトリ
  case "$base" in
    .git|.toml) continue ;;
  esac

  ln -snfv "$DOT_DIRECTORY/$base" "$HOME/$base"
done

# --- 個別設定ファイル -------------------------------------------------------
# gitignore（system）
mkdir -p "$HOME/.config/git"
ln -snfv "$DOT_DIRECTORY/ignore" "$HOME/.config/git/ignore"

# Vim (dein)
mkdir -p "$HOME/.vim/rc"
ln -snfv "$DOT_DIRECTORY/dein.toml"       "$HOME/.vim/rc/dein.toml"
ln -snfv "$DOT_DIRECTORY/dein_lazy.toml" "$HOME/.vim/rc/dein_lazy.toml"

# aqua
mkdir -p "$HOME/.config/aquaproj-aqua"
ln -snfv "$DOT_DIRECTORY/aqua.yaml" "$HOME/.config/aquaproj-aqua/aqua.yaml"

# VS Code
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_USER_DIR"
ln -snfv "$DOT_DIRECTORY/settings.json" "$VSCODE_USER_DIR/settings.json"

# Claude
mkdir -p "$HOME/.claude"
# 既存のシンボリンクの循環参照をチェック
for link in "$HOME/.claude/settings.json" "$HOME/.claude/CLAUDE.md" "$HOME/.claude/commands"; do
    if ! check_circular_link "$link"; then
        echo "  -> 削除: $link"
        rm -f "$link"
    fi
done
ln -snfv "$DOT_DIRECTORY/.claude/settings.json"       "$HOME/.claude/settings.json"
ln -snfv "$DOT_DIRECTORY/.claude/commands"            "$HOME/.claude/commands"
ln -snfv "$DOT_DIRECTORY/.claude/CLAUDE.md"           "$HOME/.claude/CLAUDE.md"

# --- 追加で必要なら ---------------------------------------------------------
# GOPATH を使う場合だけ有効化（Go 1.21 以降は通常不要）
# export GOPATH="$HOME/go"

echo "✅ dotfiles symlink 完了"

