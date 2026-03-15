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

if bash -n .bashrc 2>/dev/null; then
    pass "Bash syntax valid"
else
    fail "Bash syntax error"
fi

if zsh -n .zshrc 2>/dev/null; then
    pass "Zsh syntax valid"
else
    fail "Zsh syntax error"
fi

echo
echo "--- Load Tests ---"

if zsh -i -c "source .zshrc" 2>/dev/null; then
    pass "Zsh loads without error"
else
    fail "Zsh failed to load"
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
echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo

if [ $FAILED -gt 0 ]; then
    exit 1
fi

exit 0
