#!/bin/bash

input=$(cat)

readonly ICON_FOLDER=$(printf "\xef\x81\xbb") # nf-fa-folder
readonly ICON_BRANCH=$(printf "\xee\x82\xa0") # nf-dev-git_branch
readonly ICON_WORKTREE="🌳 "
readonly BAR_WIDTH=10
readonly COLOR_BG='\033[38;2;108;108;120m'
readonly COLOR_RESET='\033[0m'

model=$(echo "$input" | jq -r '.model.display_name // empty' | sed 's/ [0-9.]*$//')
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# --- Git 情報 ---
branch=""
worktree_prefix=""
dir=""

if git rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  git_dir=$(git rev-parse --git-dir 2>/dev/null)
  git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null)

  if [ "$git_dir" != "$git_common_dir" ]; then
    worktree_prefix="$ICON_WORKTREE"
    dir=$(basename "$(dirname "$git_common_dir")")
  else
    dir=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
  fi
else
  dir=$(echo "$input" | jq -r '.workspace.current_dir // empty' | xargs basename 2>/dev/null)
fi

# --- プログレスバー ---
filled=$((ctx_pct * BAR_WIDTH / 100))
empty=$((BAR_WIDTH - filled))

if [ "$ctx_pct" -ge 75 ]; then
  color_bar='\033[31m'
elif [ "$ctx_pct" -ge 50 ]; then
  color_bar='\033[33m'
else
  color_bar='\033[38;2;140;160;220m'
fi

bar=""
[ "$filled" -gt 0 ] && bar="${color_bar}$(printf "%${filled}s" | tr ' ' '█')"
[ "$empty" -gt 0 ] && bar="${bar}${COLOR_BG}$(printf "%${empty}s" | tr ' ' '█')"

# --- 出力 ---
branch_seg=""
[ -n "$branch" ] && branch_seg=" | ${worktree_prefix}${ICON_BRANCH}${branch}"

echo "[${model}] ${ICON_FOLDER}${dir}${branch_seg}"
echo -e "${bar}${COLOR_RESET} ${ctx_pct}% | $(printf '$%.2f' "$cost")"
