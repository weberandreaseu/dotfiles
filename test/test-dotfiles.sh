#!/bin/bash
set -e

HOME_DIR="/home/testuser"
PASSED=0
FAILED=0

# Docker runs this script with a minimal PATH, so include user-local bins.
export PATH="$HOME_DIR/.local/bin:$HOME_DIR/.opencode/bin:$PATH"

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
    STARTUP_SECONDS=$( { /usr/bin/time -f '%e' zsh -i -c exit >/dev/null; } 2>&1 )
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

if echo "$ZSH_ALIASES" | grep -q "^gst="; then
    GST_TARGET=$(echo "$ZSH_ALIASES" | grep "^gst=" | grep -o "'.*'" | tr -d "'")
    if [ "$GST_TARGET" = "git status" ]; then
        pass "Alias 'gst' expands to 'git status'"
    else
        fail "Alias 'gst' found but expands to: $GST_TARGET"
    fi
else
    fail "Alias 'gst' not found"
fi

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
echo "--- Function Tests ---"

ZSH_FUNCTIONS=$(zsh -i -c "functions" 2>/dev/null || echo "")

if echo "$ZSH_FUNCTIONS" | grep -q "^__zoxide_z "; then
    pass "Function '__zoxide_z' loaded"
else
    fail "Function '__zoxide_z' not found"
fi

if echo "$ZSH_FUNCTIONS" | grep -q "^__zoxide_zi "; then
    pass "Function '__zoxide_zi' loaded"
else
    fail "Function '__zoxide_zi' not found"
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

if [ -f "$HOME/.local/bin/fzf" ]; then
    pass "fzf installed"
else
    fail "fzf not found"
fi

if [ -f "$HOME/.local/bin/zoxide" ] || ls "$HOME/.local/opt/zoxide-"*/bin/zoxide &>/dev/null; then
    pass "zoxide installed"
else
    fail "zoxide not found"
fi

if command -v mise &> /dev/null; then
    pass "mise installed"
else
    fail "mise not found"
fi

if command -v opencode &> /dev/null; then
    pass "opencode installed"
else
    fail "opencode not found"
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

if [ -d "$HOME/.sdkman" ]; then
    pass "SDKMAN installed"
else
    fail "SDKMAN not found"
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
