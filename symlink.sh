#!/usr/bin/env bash
set -eu
set -o pipefail

# スクリプトが置いてあるディレクトリ＝dotfiles リポジトリ
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOT_DIRECTORY="$SCRIPT_DIR"

# 循環参照チェック関数（改良版）
check_circular_link() {
    local link_path="$1"
    
    # シンボリンクでない場合は問題なし
    if [ ! -L "$link_path" ]; then
        return 0
    fi
    
    # シンボリンクが壊れている場合は削除対象
    if [ ! -e "$link_path" ]; then
        echo "⚠️  壊れたシンボリンクを検出: $link_path"
        return 1
    fi
    
    # リンクターゲットを確認
    local target=$(readlink "$link_path")
    
    # 絶対パスに変換
    if [[ "$target" != /* ]]; then
        target="$(dirname "$link_path")/$target"
    fi
    
    # 正規化されたパスで比較
    local normalized_link=$(readlink -f "$link_path" 2>/dev/null || echo "$link_path")
    local normalized_target=$(readlink -f "$target" 2>/dev/null || echo "$target")
    
    # 自分自身を指している場合は循環参照
    if [ "$normalized_link" = "$normalized_target" ]; then
        echo "⚠️  循環参照を検出: $link_path -> $target"
        return 1
    fi
    
    # dotfilesリポジトリ内のファイルが、同じファイルを指している場合もチェック
    if [[ "$target" == "$DOT_DIRECTORY"* ]] && [ "$target" = "$link_path" ]; then
        echo "⚠️  dotfiles内循環参照を検出: $link_path -> $target"
        return 1
    fi
    
    return 0
}

# --- dotfiles 本体 ----------------------------------------------------------
for f in "$DOT_DIRECTORY"/.??*; do
  base="$(basename "$f")"

  # 同期しないファイル／ディレクトリ
  case "$base" in
    .git|.toml|.claude|.codex) continue ;;
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

# Ghostty
GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
mkdir -p "$GHOSTTY_DIR"
ln -snfv "$DOT_DIRECTORY/ghostty/config" "$GHOSTTY_DIR/config"

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

# Codex
mkdir -p "$HOME/.codex"
if ! check_circular_link "$HOME/.codex/config.toml"; then
    echo "  -> 削除: $HOME/.codex/config.toml"
    rm -f "$HOME/.codex/config.toml"
fi
ln -snfv "$DOT_DIRECTORY/.codex/config.toml" "$HOME/.codex/config.toml"
if ! check_circular_link "$HOME/.codex/notify_macos.sh"; then
    echo "  -> 削除: $HOME/.codex/notify_macos.sh"
    rm -f "$HOME/.codex/notify_macos.sh"
fi
ln -snfv "$DOT_DIRECTORY/.codex/notify_macos.sh" "$HOME/.codex/notify_macos.sh"
chmod +x "$HOME/.codex/notify_macos.sh"
# AGENTS.md はグローバル指示として実体コピーを置く
CODEX_AGENT_SRC="$DOT_DIRECTORY/AGENTS.md"
CODEX_AGENT_DEST="$HOME/.codex/AGENTS.md"
if [ -f "$CODEX_AGENT_SRC" ]; then
    if [ -L "$CODEX_AGENT_DEST" ]; then
        echo "  -> シンボリックリンクを削除: $CODEX_AGENT_DEST"
        rm -f "$CODEX_AGENT_DEST"
    fi
    cp "$CODEX_AGENT_SRC" "$CODEX_AGENT_DEST"
fi
# ~/.codex/prompts はシンボリックリンクだと読み込まれないためフルコピーする
PROMPTS_SRC="$DOT_DIRECTORY/.codex/prompts"
PROMPTS_DEST="$HOME/.codex/prompts"
if [ -L "$PROMPTS_DEST" ]; then
    echo "  -> シンボリックリンクを削除: $PROMPTS_DEST"
    rm -f "$PROMPTS_DEST"
fi
if [ -d "$PROMPTS_DEST" ]; then
    echo "  -> 既存のディレクトリを削除: $PROMPTS_DEST"
    rm -rf "$PROMPTS_DEST"
elif [ -f "$PROMPTS_DEST" ]; then
    echo "  -> 既存のファイルを削除: $PROMPTS_DEST"
    rm -f "$PROMPTS_DEST"
fi
mkdir -p "$PROMPTS_DEST"
rsync -a --copy-links "$PROMPTS_SRC"/ "$PROMPTS_DEST"/

# Codex skills も実体ファイルが必須なのでコピー
SKILLS_SRC="$DOT_DIRECTORY/.codex/skills"
SKILLS_DEST="$HOME/.codex/skills"
if [ -d "$SKILLS_SRC" ]; then
    if [ -L "$SKILLS_DEST" ]; then
        echo "  -> シンボリックリンクを削除: $SKILLS_DEST"
        rm -f "$SKILLS_DEST"
    fi
    if [ -f "$SKILLS_DEST" ]; then
        echo "  -> 既存のファイルを削除: $SKILLS_DEST"
        rm -f "$SKILLS_DEST"
    fi
    mkdir -p "$SKILLS_DEST"
    rsync -a --delete "$SKILLS_SRC"/ "$SKILLS_DEST"/
fi

# custom agents も実体ファイルがないと検出されないためコピーする
AGENTS_SRC="$DOT_DIRECTORY/.codex/agents"
AGENTS_DEST="$HOME/.codex/agents"
if [ -d "$AGENTS_SRC" ]; then
    if [ -L "$AGENTS_DEST" ]; then
        echo "  -> シンボリックリンクを削除: $AGENTS_DEST"
        rm -f "$AGENTS_DEST"
    fi
    if [ -f "$AGENTS_DEST" ]; then
        echo "  -> 既存のファイルを削除: $AGENTS_DEST"
        rm -f "$AGENTS_DEST"
    fi
    mkdir -p "$AGENTS_DEST"
    rsync -a --delete "$AGENTS_SRC"/ "$AGENTS_DEST"/
fi

# --- 追加で必要なら ---------------------------------------------------------
# GOPATH を使う場合だけ有効化（Go 1.21 以降は通常不要）
# export GOPATH="$HOME/go"

echo "✅ dotfiles symlink 完了"
