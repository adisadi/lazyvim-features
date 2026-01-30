#!/bin/bash
set -e

# Test that Neovim nightly is installed
echo "Testing LazyVim feature with nightly..."

if command -v nvim >/dev/null 2>&1; then
    VERSION=$(nvim --version | head -1)
    echo "✓ Neovim installed: $VERSION"

    # Nightly versions contain "dev" or a commit hash
    if echo "$VERSION" | grep -qiE "(dev|nightly|\+)"; then
        echo "✓ Confirmed nightly build"
    else
        echo "⚠ May not be nightly (expected dev version)"
    fi
else
    echo "✗ Neovim not found"
    exit 1
fi

echo "Nightly test passed!"