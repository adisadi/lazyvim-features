# LazyVim Dev Container Features

Dev Container Features for setting up LazyVim in development containers.

## Features

### lazyvim

Installs Neovim with LazyVim dependencies (ripgrep, fd, fzf, lazygit, clipboard support).

```json
"features": {
    "ghcr.io/adisadi/lazyvim-features/lazyvim:1": {}
}
```

#### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `stable` | Neovim version (`stable` or `nightly`) |
| `configRepo` | string | `""` | Git repository URL to clone as nvim config |

### lazyvim-dotnet

Extends LazyVim with .NET development tools (dotnet-ef, dotnet-outdated, EasyDotnet).

```json
"features": {
    "ghcr.io/adisadi/lazyvim-features/lazyvim-dotnet:1": {}
}
```

#### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `dotnetVersion` | string | `10.0` | .NET SDK version to install |

## Usage

Add to your `devcontainer.json`:

```json
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/adisadi/lazyvim-features/lazyvim:1": {}
    }
}
```

For .NET development:

```json
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/adisadi/lazyvim-features/lazyvim-dotnet:1": {
            "dotnetVersion": "9.0"
        }
    }
}
```

## Nvim Config Options

### Clone from a git repository

```json
{
    "features": {
        "ghcr.io/adisadi/lazyvim-features/lazyvim:1": {
            "configRepo": "https://github.com/your-user/nvim-config"
        }
    }
}
```

### Mount your local config

```json
{
    "features": {
        "ghcr.io/adisadi/lazyvim-features/lazyvim:1": {}
    },
    "mounts": [
        "source=${localEnv:HOME}/.config/nvim,target=/home/vscode/.config/nvim,type=bind"
    ]
}
```

## Clipboard Support

To enable clipboard sharing between the container and host, add the following to your `devcontainer.json`:

### X11

```json
{
    "containerEnv": {
        "DISPLAY": "${localEnv:DISPLAY}"
    },
    "mounts": [
        "source=/tmp/.X11-unix,target=/tmp/.X11-unix,type=bind"
    ]
}
```

### Wayland

```json
{
    "containerEnv": {
        "WAYLAND_DISPLAY": "${localEnv:WAYLAND_DISPLAY}",
        "XDG_RUNTIME_DIR": "/tmp"
    },
    "mounts": [
        "source=${localEnv:XDG_RUNTIME_DIR}/${localEnv:WAYLAND_DISPLAY},target=/tmp/${localEnv:WAYLAND_DISPLAY},type=bind"
    ]
}
```
