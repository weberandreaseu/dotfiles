#!/bin/bash
set -e

HOME_DIR="/home/testuser"
PASSED=0
FAILED=0

pass() {
    echo "✓ $1"
    ((PASSED++)) || true
}

fail() {
    echo "✗ $1"
    ((FAILED++)) || true
}

echo "=== Dotfiles Test Suite ==="
echo

cd "$HOME_DIR"

echo "--- Syntax Tests ---"

if zsh -n .zshrc 2>/dev/null; then
    pass "Zsh syntax valid"
else
    fail "Zsh syntax error"
fi

echo
echo "--- Load Tests ---"

if zsh -i -c "source .zshrc; exit 0" 2>/dev/null; then
    pass "Zsh loads without error"
else
    fail "Zsh failed to load"
fi

echo
echo "--- Startup Performance Tests ---"

ZSH_STARTUP_MAX_SECONDS="${ZSH_STARTUP_MAX_SECONDS:-0.20}"
ZSH_STARTUP_RUNS="${ZSH_STARTUP_RUNS:-5}"
ZSH_STARTUP_TIMES=""

# Warm startup cache once (for example compdump/lazy completion state).
zsh -i -c exit >/dev/null 2>&1 || true

for _ in $(seq 1 "$ZSH_STARTUP_RUNS"); do
    if [ -x /usr/bin/time ]; then
        STARTUP_SECONDS=$( { /usr/bin/time -f '%e' zsh -i -c exit >/dev/null; } 2>&1 )
    else
        TIMEFORMAT='%R'
        STARTUP_SECONDS=$( { time zsh -i -c exit >/dev/null; } 2>&1 )
    fi
    ZSH_STARTUP_TIMES+="$STARTUP_SECONDS\n"
done

ZSH_STARTUP_MEDIAN=$(printf "%b" "$ZSH_STARTUP_TIMES" | sort -n | awk 'NF {a[++n]=$1} END {if (n == 0) {print "nan"; exit 1} if (n % 2) {printf "%.3f", a[(n+1)/2]} else {printf "%.3f", (a[n/2]+a[n/2+1])/2}}')
ZSH_STARTUP_AVG=$(printf "%b" "$ZSH_STARTUP_TIMES" | awk 'NF {sum+=$1; n++} END {if (n == 0) {print "nan"; exit 1} printf "%.3f", sum/n}')

echo "  startup runs: $ZSH_STARTUP_RUNS"
echo "  startup avg: ${ZSH_STARTUP_AVG}s"
echo "  startup median: ${ZSH_STARTUP_MEDIAN}s"
echo "  startup threshold: ${ZSH_STARTUP_MAX_SECONDS}s"

if awk -v m="$ZSH_STARTUP_MEDIAN" -v max="$ZSH_STARTUP_MAX_SECONDS" 'BEGIN {exit !(m <= max)}'; then
    pass "Zsh interactive startup median <= ${ZSH_STARTUP_MAX_SECONDS}s"
else
    fail "Zsh interactive startup median too slow (${ZSH_STARTUP_MEDIAN}s > ${ZSH_STARTUP_MAX_SECONDS}s)"
fi

echo
echo "--- Alias Tests ---"

ZSH_ALIASES=$(zsh -i -c "alias" 2>/dev/null || echo "")

if echo "$ZSH_ALIASES" | grep -q "^ll="; then
    pass "Alias 'll' exists"
else
    fail "Alias 'll' not found"
fi

if echo "$ZSH_ALIASES" | grep -q "^la="; then
    pass "Alias 'la' exists"
else
    fail "Alias 'la' not found"
fi

echo
echo "--- Git Config Tests ---"

if git config --global user.name >/dev/null 2>&1; then
    pass "Git user.name configured"
else
    fail "Git user.name not configured"
fi

if git config --global user.email >/dev/null 2>&1; then
    pass "Git user.email configured"
else
    fail "Git user.email not configured"
fi

echo
echo "--- Tools Tests ---"

if command -v mise &> /dev/null; then
    pass "mise installed"
else
    fail "mise not found"
fi

if zsh -i -c "command -v node >/dev/null && node --version >/dev/null" 2>/dev/null; then
    if zsh -i -c "node --version" >/dev/null 2>&1; then
        pass "node installed"
    else
        fail "node not runnable"
    fi
else
    fail "node not found"
fi

if zsh -i -c "command -v npm >/dev/null && npm --version >/dev/null" 2>/dev/null; then
    if zsh -i -c "npm --version" >/dev/null 2>&1; then
        pass "npm installed"
    else
        fail "npm not runnable"
    fi
else
    fail "npm not found"
fi

if zsh -i -c "command -v java >/dev/null && java --version >/dev/null" 2>/dev/null; then
    pass "Temurin Java installed via mise"
else
    fail "Temurin Java not found or not runnable via mise"
fi

for tool in claude fzf zoxide opencode; do
    if zsh -i -c "command -v $tool >/dev/null && $tool --version >/dev/null" 2>/dev/null; then
        pass "$tool installed via mise"
    else
        fail "$tool not found or not runnable via mise"
    fi
done

if zsh -i -c "command -v kubectl >/dev/null && kubectl version --client >/dev/null" 2>/dev/null; then
    pass "kubectl installed via mise"
else
    fail "kubectl not found or not runnable via mise"
fi

if command -v docker &> /dev/null || [ -f /usr/bin/docker ]; then
    pass "docker installed"
else
    echo "  (docker requires root to install, skipping)"
fi

if command -v code &> /dev/null || [ -f /usr/bin/code ]; then
    pass "VS Code installed"
else
    echo "  (VS Code requires root to install, skipping)"
fi

if [ -d "$HOME/.local/share/JetBrains/Toolbox" ]; then
    pass "JetBrains Toolbox installed"
else
    fail "JetBrains Toolbox not found"
fi

echo
echo "--- Dotfiles State Tests ---"

if grep -q '^"flatpak:be\.alexandervanhee\.gradia" = "latest"$' "$HOME/git/dotfiles/mise.toml"; then
    pass "Gradia is managed as a Flatpak application"
else
    fail "Gradia Flatpak application is missing"
fi

FLATPAK_ENV_FILE="$HOME/.config/environment.d/flatpak.conf"
if [ -f "$FLATPAK_ENV_FILE" ] \
    && grep -q '/var/lib/flatpak/exports/share' "$FLATPAK_ENV_FILE" \
    && grep -q '\${HOME}/.local/share/flatpak/exports/share' "$FLATPAK_ENV_FILE"; then
    pass "Flatpak desktop entries are on XDG_DATA_DIRS"
else
    fail "Flatpak desktop-entry paths are missing from XDG_DATA_DIRS"
fi

if ! grep -q '^\[tools\]' "$HOME/git/dotfiles/mise.toml" \
    && grep -q '^\[tools\]' "$HOME/.config/mise/config.toml"; then
    pass "mise tools have one managed global source"
else
    fail "mise tool configuration is duplicated or missing"
fi

if (cd "$HOME/git/dotfiles" && mise bootstrap dotfiles status --missing >/dev/null 2>&1); then
    pass "mise dotfiles status clean"
else
    fail "mise dotfiles status reports drift"
fi

echo
echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo

if [ $FAILED -gt 0 ]; then
    exit 1
fi

exit 0
