#!/bin/bash
set -e

echo "Testing Claude Code feature installation..."

# Test Claude Code CLI
if command -v claude >/dev/null 2>&1; then
    echo "✓ Claude Code installed: $(claude --version)"
else
    echo "✗ Claude Code not found"
    exit 1
fi

echo ""
echo "All tests passed!"
