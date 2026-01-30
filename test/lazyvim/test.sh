#!/bin/bash
set -e

# Test that all required tools are installed
echo "Testing LazyVim feature installation..."

# Test Neovim
if command -v nvim >/dev/null 2>&1; then
    echo "✓ Neovim installed: $(nvim --version | head -1)"
else
    echo "✗ Neovim not found"
    exit 1
fi

# Test ripgrep
if command -v rg >/dev/null 2>&1; then
    echo "✓ ripgrep installed: $(rg --version | head -1)"
else
    echo "✗ ripgrep not found"
    exit 1
fi

# Test fd
if command -v fd >/dev/null 2>&1; then
    echo "✓ fd installed: $(fd --version)"
elif command -v fdfind >/dev/null 2>&1; then
    echo "✓ fd-find installed: $(fdfind --version)"
else
    echo "✗ fd not found"
    exit 1
fi

# Test fzf
if command -v fzf >/dev/null 2>&1; then
    echo "✓ fzf installed: $(fzf --version)"
else
    echo "✗ fzf not found"
    exit 1
fi

# Test lazygit
if command -v lazygit >/dev/null 2>&1; then
    echo "✓ lazygit installed: $(lazygit --version)"
else
    echo "✗ lazygit not found"
    exit 1
fi

# Test git
if command -v git >/dev/null 2>&1; then
    echo "✓ git installed: $(git --version)"
else
    echo "✗ git not found"
    exit 1
fi

# Test environment variables
if [ "$EDITOR" = "nvim" ]; then
    echo "✓ EDITOR is set to nvim"
else
    echo "✗ EDITOR is not set correctly (expected 'nvim', got '$EDITOR')"
    exit 1
fi

echo ""
echo "All tests passed!"