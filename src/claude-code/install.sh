#!/bin/sh
set -e

echo "Installing Claude Code CLI (standalone)..."

# Built-in devcontainer feature variables
REMOTE_USER="${_REMOTE_USER:-root}"
REMOTE_USER_HOME="${_REMOTE_USER_HOME:-/root}"

# Install dependencies
if command -v apt-get >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends ca-certificates curl
    apt-get clean
    rm -rf /var/lib/apt/lists/*
elif command -v apk >/dev/null 2>&1; then
    apk add --no-cache ca-certificates curl
elif command -v dnf >/dev/null 2>&1; then
    dnf install -y ca-certificates curl
    dnf clean all
elif command -v yum >/dev/null 2>&1; then
    yum install -y ca-certificates curl
    yum clean all
elif command -v pacman >/dev/null 2>&1; then
    pacman -Syu --noconfirm ca-certificates curl
fi

# Install Claude Code as the remote user so it lands in their home directory
# The installer places files in ~/.local/bin/claude and ~/.local/share/claude/
export HOME="$REMOTE_USER_HOME"
curl -fsSL https://claude.ai/install.sh | bash

# Symlink claude to /usr/local/bin so it's available system-wide
# The installer creates ~/.local/bin/claude -> ~/.local/share/claude/versions/<ver>
CLAUDE_BIN="$REMOTE_USER_HOME/.local/bin/claude"
if [ -L "$CLAUDE_BIN" ]; then
    CLAUDE_TARGET=$(readlink -f "$CLAUDE_BIN")
    ln -sf "$CLAUDE_TARGET" /usr/local/bin/claude
elif [ -f "$CLAUDE_BIN" ]; then
    ln -sf "$CLAUDE_BIN" /usr/local/bin/claude
fi

# Fix ownership of all files the installer created in the user's home
if [ "$REMOTE_USER" != "root" ]; then
    chown -R "$REMOTE_USER:$REMOTE_USER" "$REMOTE_USER_HOME/.local" 2>/dev/null || true
    chown -R "$REMOTE_USER:$REMOTE_USER" "$REMOTE_USER_HOME/.cache" 2>/dev/null || true
fi

echo "Claude Code installed: $(claude --version 2>/dev/null || echo 'OK')"
echo "Claude Code CLI installed successfully!"
