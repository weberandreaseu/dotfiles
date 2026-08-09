#!/bin/bash
set -euo pipefail

RUNS=7
PROFILE=0
TTY=0

usage() {
    cat <<'USAGE'
Usage: ./test/test-zsh-startup.sh [--runs N] [--tty] [--profile]

Options:
  --runs N    Number of timing runs (default: 7)
  --tty       Measure via pseudo-tty (closer to opening a new terminal tab)
  --profile   Include a zprof breakdown of top startup functions
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --runs)
            RUNS="$2"
            shift 2
            ;;
        --tty)
            TTY=1
            shift
            ;;
        --profile)
            PROFILE=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if ! [[ "$RUNS" =~ ^[0-9]+$ ]] || [[ "$RUNS" -lt 1 ]]; then
    echo "--runs must be a positive integer" >&2
    exit 1
fi

run_once() {
    if [[ "$TTY" -eq 1 ]]; then
        { /usr/bin/time -f '%e' script -qfc 'zsh -i -c exit' /dev/null >/dev/null; } 2>&1 | tail -n1
    else
        { /usr/bin/time -f '%e' zsh -i -c exit >/dev/null; } 2>&1 | tail -n1
    fi
}

calc_stats() {
    local file="$1"
    local sorted_file
    sorted_file="$(mktemp /tmp/zsh-startup-sorted.XXXXXX)"

    sort -n "$file" > "$sorted_file"

    local n avg median min max
    n="$(wc -l < "$sorted_file")"
    avg="$(awk '{sum += $1} END {printf "%.3f", sum / NR}' "$file")"
    min="$(head -n1 "$sorted_file")"
    max="$(tail -n1 "$sorted_file")"

    if (( n % 2 == 1 )); then
        median="$(awk -v mid=$(( (n + 1) / 2 )) 'NR==mid {printf "%.3f", $1}' "$sorted_file")"
    else
        median="$(awk -v mid=$(( n / 2 )) 'NR==mid {a=$1} NR==mid+1 {printf "%.3f", (a + $1) / 2}' "$sorted_file")"
    fi

    rm -f "$sorted_file"
    printf 'avg=%ss median=%ss min=%ss max=%ss' "$avg" "$median" "$min" "$max"
}

echo "== Zsh startup benchmark =="
echo "Mode: $([[ "$TTY" -eq 1 ]] && echo 'pseudo-tty' || echo 'direct shell')"
echo "Runs: $RUNS"
echo

times_file="$(mktemp /tmp/zsh-startup-times.XXXXXX)"
trap 'rm -f "$times_file"' EXIT

for i in $(seq 1 "$RUNS"); do
    t="$(run_once)"
    echo "$t" >> "$times_file"
    printf 'run %d: %ss\n' "$i" "$t"
done

echo
stats="$(calc_stats "$times_file")"
echo "Summary: $stats"

if [[ "$PROFILE" -eq 1 ]]; then
    echo
    echo "== zprof top entries =="
    tmp_zdot="$(mktemp -d /tmp/zsh-prof.XXXXXX)"
    trap 'rm -f "$times_file"; rm -rf "$tmp_zdot"' EXIT

    cp "$HOME/.zshrc" "$tmp_zdot/.zshrc"
    cp "$HOME/.zshenv" "$tmp_zdot/.zshenv"
    [[ -f "$HOME/.alias.zsh" ]] && cp "$HOME/.alias.zsh" "$tmp_zdot/.alias.zsh"
    [[ -f "$HOME/.p10k.zsh" ]] && cp "$HOME/.p10k.zsh" "$tmp_zdot/.p10k.zsh"

    {
        echo 'zmodload zsh/zprof'
        cat "$tmp_zdot/.zshrc"
    } > "$tmp_zdot/.zshrc.with-prof"
    mv "$tmp_zdot/.zshrc.with-prof" "$tmp_zdot/.zshrc"

    ZDOTDIR="$tmp_zdot" HOME="$HOME" zsh -i -c 'zprof; exit' 2>/dev/null | head -n 30
fi
