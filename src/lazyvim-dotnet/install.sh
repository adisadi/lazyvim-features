#!/bin/sh
set -e

# Options from devcontainer-feature.json
DOTNETVERSION="${DOTNETVERSION:-10.0}"

echo "Installing LazyVim .NET extensions..."

# Install .NET SDK side-by-side if requested version differs from base
install_dotnet_sdk() {
    echo "Installing .NET SDK ${DOTNETVERSION}..."

    # Determine install directory
    if [ -d "/usr/share/dotnet" ]; then
        DOTNET_INSTALL_DIR="/usr/share/dotnet"
    elif [ -d "/usr/lib/dotnet" ]; then
        DOTNET_INSTALL_DIR="/usr/lib/dotnet"
    else
        DOTNET_INSTALL_DIR="/usr/share/dotnet"
    fi

    curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
    chmod +x /tmp/dotnet-install.sh
    /tmp/dotnet-install.sh --channel "$DOTNETVERSION" --install-dir "$DOTNET_INSTALL_DIR"
    rm -f /tmp/dotnet-install.sh

    # Ensure dotnet is in PATH
    if [ ! -f /usr/local/bin/dotnet ]; then
        ln -sf "$DOTNET_INSTALL_DIR/dotnet" /usr/local/bin/dotnet
    fi

    echo ".NET SDK installed: $(dotnet --list-sdks | grep "^${DOTNETVERSION}" || echo "${DOTNETVERSION}.x")"
}

# Get target user (non-root)
get_target_user() {
    if [ -n "$_REMOTE_USER" ] && [ "$_REMOTE_USER" != "root" ]; then
        echo "$_REMOTE_USER"
    elif [ -n "$_CONTAINER_USER" ] && [ "$_CONTAINER_USER" != "root" ]; then
        echo "$_CONTAINER_USER"
    else
        # Fallback: find first non-root user with a home directory
        getent passwd | awk -F: '$3 >= 1000 && $3 < 65534 {print $1; exit}'
    fi
}

# Install global dotnet tools
install_dotnet_tools() {
    echo "Installing .NET global tools..."

    TARGET_USER=$(get_target_user)
    if [ -z "$TARGET_USER" ]; then
        echo "Warning: No non-root user found, skipping tool installation"
        return
    fi

    DOTNET_PATH="/usr/local/bin/dotnet"
    su - "$TARGET_USER" -c "$DOTNET_PATH tool install --global dotnet-ef" || true
    su - "$TARGET_USER" -c "$DOTNET_PATH tool install --global dotnet-outdated-tool" || true
    su - "$TARGET_USER" -c "$DOTNET_PATH tool install --global EasyDotnet" || true

    # Add dotnet tools to PATH system-wide
    echo 'export PATH="$PATH:$HOME/.dotnet/tools"' > /etc/profile.d/dotnet-tools.sh
    chmod +x /etc/profile.d/dotnet-tools.sh

    echo ".NET tools installed for user: $TARGET_USER"
}

# Setup dev certificates
setup_dev_certs() {
    echo "Setting up HTTPS dev certificates..."

    TARGET_USER=$(get_target_user)
    if [ -z "$TARGET_USER" ]; then
        echo "Warning: No non-root user found, skipping dev-certs"
        return
    fi

    su - "$TARGET_USER" -c "/usr/local/bin/dotnet dev-certs https" || true
}

# Copy default nvim config if none exists
install_default_config() {
    TARGET_USER=$(get_target_user)
    if [ -z "$TARGET_USER" ]; then
        TARGET_HOME="/root"
        TARGET_USER="root"
    else
        TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
    fi

    CONFIG_DIR="$TARGET_HOME/.config/nvim"

    if [ ! -d "$CONFIG_DIR" ]; then
        echo "Installing default LazyVim config..."

        # Feature files are extracted to the same directory as install.sh
        SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

        if [ -d "$SCRIPT_DIR/nvim-config" ]; then
            mkdir -p "$(dirname "$CONFIG_DIR")"
            cp -r "$SCRIPT_DIR/nvim-config" "$CONFIG_DIR"

            if [ "$TARGET_USER" != "root" ]; then
                chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config"
            fi

            echo "Default config installed to $CONFIG_DIR"
        else
            echo "Warning: Default config not found in feature package"
        fi
    else
        echo "Nvim config already exists at $CONFIG_DIR, skipping"
    fi
}

# Main installation
install_dotnet_sdk
install_dotnet_tools
setup_dev_certs
install_default_config

echo "LazyVim .NET extensions installed successfully!"