#!/bin/sh
set -e

# Options from devcontainer-feature.json
VERSION="${VERSION:-stable}"
CONFIGREPO="${CONFIGREPO:-}"

echo "Installing LazyVim dependencies..."

# Detect architecture
ARCH="$(uname -m)"
case "$ARCH" in
x86_64) ARCH="x86_64" ;;
aarch64 | arm64) ARCH="arm64" ;;
*) echo "Unsupported architecture: $ARCH" && exit 1 ;;
esac

# Install packages based on package manager
install_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      build-essential \
      ripgrep \
      fd-find \
      fzf \
      unzip \
      xclip \
      wl-clipboard
    # Create fd symlink (Debian/Ubuntu package is fd-find)
    ln -sf "$(which fdfind)" /usr/local/bin/fd 2>/dev/null || true
    apt-get clean
    rm -rf /var/lib/apt/lists/*
  elif command -v apk >/dev/null 2>&1; then
    apk add --no-cache \
      ca-certificates \
      curl \
      git \
      build-base \
      ripgrep \
      fd \
      fzf \
      unzip \
      xclip \
      wl-clipboard
  elif command -v dnf >/dev/null 2>&1; then
    dnf install -y \
      ca-certificates \
      curl \
      git \
      gcc \
      gcc-c++ \
      make \
      ripgrep \
      fd-find \
      fzf \
      unzip \
      xclip \
      wl-clipboard
    dnf clean all
  elif command -v yum >/dev/null 2>&1; then
    yum install -y \
      ca-certificates \
      curl \
      git \
      gcc \
      gcc-c++ \
      make \
      ripgrep \
      fzf \
      unzip \
      xclip
    yum clean all
  elif command -v pacman >/dev/null 2>&1; then
    pacman -Syu --noconfirm \
      ca-certificates \
      curl \
      git \
      base-devel \
      ripgrep \
      fd \
      fzf \
      unzip \
      xclip \
      wl-clipboard
  else
    echo "Unsupported package manager"
    exit 1
  fi
}

# Install Neovim
install_neovim() {
  echo "Installing Neovim ($VERSION)..."

  # Alpine uses musl, so we must use the package manager
  if command -v apk >/dev/null 2>&1; then
    if [ "$VERSION" = "nightly" ]; then
      echo "Warning: nightly not available via apk, using edge/testing"
      apk add --no-cache neovim --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community
    else
      apk add --no-cache neovim
    fi
  else
    # glibc-based systems can use GitHub releases
    if [ "$VERSION" = "nightly" ]; then
      NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-${ARCH}.tar.gz"
    else
      NVIM_URL="https://github.com/neovim/neovim/releases/download/stable/nvim-linux-${ARCH}.tar.gz"
    fi

    curl -fsSL "$NVIM_URL" -o /tmp/nvim.tar.gz
    tar -xzf /tmp/nvim.tar.gz -C /tmp
    cp -r /tmp/nvim-linux-${ARCH}/* /usr/local/
    rm -rf /tmp/nvim.tar.gz /tmp/nvim-linux-${ARCH}
  fi

  echo "Neovim installed: $(nvim --version | head -1)"
}

# Install lazygit
install_lazygit() {
  echo "Installing lazygit..."

  # Alpine has lazygit in community repo
  if command -v apk >/dev/null 2>&1; then
    apk add --no-cache lazygit --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community
  else
    LAZYGIT_VERSION=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')

    if [ "$ARCH" = "arm64" ]; then
      LAZYGIT_ARCH="arm64"
    else
      LAZYGIT_ARCH="x86_64"
    fi

    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz" -o /tmp/lazygit.tar.gz
    tar -xzf /tmp/lazygit.tar.gz -C /tmp lazygit
    install /tmp/lazygit /usr/local/bin
    rm -rf /tmp/lazygit /tmp/lazygit.tar.gz
  fi

  echo "lazygit installed: $(lazygit --version)"
}

# Clone config repository if specified
clone_config() {
  if [ -n "$CONFIGREPO" ]; then
    echo "Cloning nvim config from $CONFIGREPO..."

    # Determine target user's home directory
    if [ -n "$_REMOTE_USER" ] && [ "$_REMOTE_USER" != "root" ]; then
      TARGET_HOME=$(getent passwd "$_REMOTE_USER" | cut -d: -f6)
      TARGET_USER="$_REMOTE_USER"
    elif [ -n "$_CONTAINER_USER" ] && [ "$_CONTAINER_USER" != "root" ]; then
      TARGET_HOME=$(getent passwd "$_CONTAINER_USER" | cut -d: -f6)
      TARGET_USER="$_CONTAINER_USER"
    else
      TARGET_HOME="/root"
      TARGET_USER="root"
    fi

    CONFIG_DIR="$TARGET_HOME/.config/nvim"

    # Clone the repository
    if [ -d "$CONFIG_DIR" ]; then
      echo "Config directory already exists, skipping clone"
    else
      mkdir -p "$(dirname "$CONFIG_DIR")"
      git clone "$CONFIGREPO" "$CONFIG_DIR"

      # Fix ownership if not root
      if [ "$TARGET_USER" != "root" ]; then
        chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config"
      fi
    fi

    echo "Config cloned to $CONFIG_DIR"
  fi
}

# Main installation
install_packages
install_neovim
install_lazygit
clone_config

echo "LazyVim dependencies installed successfully!"

