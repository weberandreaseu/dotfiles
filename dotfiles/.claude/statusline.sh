#!/bin/bash
# Claude Code status line: model name, context window usage, and (when inside
# a git repo) the checked-out branch.
set -euo pipefail

input="$(cat)"

model="$(jq -r '.model.display_name // "Claude"' <<<"$input")"
cwd="$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$input")"
used_pct="$(jq -r '.context_window.used_percentage // empty' <<<"$input")"

reset=$'\033[0m'
dim=$'\033[2m'
branch_icon=$'' # nf-dev-git_branch

context_part="${dim}ctx n/a${reset}"
if [ -n "$used_pct" ]; then
    pct_int="${used_pct%.*}"
    if [ "$pct_int" -ge 90 ]; then
        color=$'\033[31m' # red
    elif [ "$pct_int" -ge 70 ]; then
        color=$'\033[33m' # yellow
    else
        color=$'\033[32m' # green
    fi
    context_part="${color}ctx ${pct_int}%${reset}"
fi

branch_part=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch="$(git -C "$cwd" branch --show-current 2>/dev/null || true)"
    if [ -z "$branch" ]; then
        short_sha="$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null || true)"
        if [ -n "$short_sha" ]; then
            branch="detached@${short_sha}"
        fi
    fi
    if [ -n "$branch" ]; then
        dirty=""
        if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
            dirty=" *"
        fi
        branch_part=" ${dim}·${reset} ${branch_icon} ${branch}${dirty}"
    fi
fi

printf '%s %s %s%s\n' "$model" "${dim}·${reset}" "$context_part" "$branch_part"
