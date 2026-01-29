#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: update_repos.sh [--no-checkout] [ROOT]

ROOT defaults to the current directory.

Options:
  --no-checkout  If current branch is not the default branch, only fetch.
  -h, --help     Show this help.
USAGE
}

no_checkout=0
root=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-checkout)
      no_checkout=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [ -z "$root" ]; then
        root="$1"
      else
        echo "Unknown argument: $1" >&2
        usage >&2
        exit 2
      fi
      ;;
  esac
  shift
 done

root="${root:-$(pwd)}"

find "$root" -name .git -type d -prune -print0 | while IFS= read -r -d '' gitdir; do
  repo="$(dirname "$gitdir")"
  echo "== $repo"

  if [ -n "$(git -C "$repo" status --porcelain)" ]; then
    echo "  skip: dirty"
    echo
    continue
  fi

  if ! git -C "$repo" remote get-url origin >/dev/null 2>&1; then
    echo "  skip: no origin"
    echo
    continue
  fi

  default_branch="$(git -C "$repo" ls-remote --symref origin HEAD 2>/dev/null | awk '/^ref:/ {sub("refs\/heads\/", "", $2); print $2; exit}')"
  if [ -z "$default_branch" ]; then
    default_branch="$(git -C "$repo" remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF; exit}')"
  fi

  if [ -z "$default_branch" ]; then
    echo "  skip: cannot detect default branch"
    echo
    continue
  fi

  current_branch="$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"

  if [ "$no_checkout" -eq 1 ] && [ "$current_branch" != "$default_branch" ]; then
    git -C "$repo" fetch origin "$default_branch"
    echo "  fetched: $default_branch (no checkout)"
    echo
    continue
  fi

  git -C "$repo" fetch origin "$default_branch"
  if [ "$current_branch" != "$default_branch" ]; then
    git -C "$repo" checkout "$default_branch"
  fi
  git -C "$repo" pull --ff-only origin "$default_branch"
  echo "  updated: $default_branch"
  echo

done
