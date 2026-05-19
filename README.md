# environment-setup

Idempotent setup scripts for macOS, Linux, and Windows development environments. Scripts can be run multiple times safely.

## What Gets Installed

### CLI Tools (mac + linux)

- **Shell**: zsh, oh-my-zsh, powerlevel10k, zsh-autosuggestions
- **Editor**: neovim + [kickstart.nvim](https://github.com/daronmcintosh/kickstart.nvim)
- **Dev tools**: git, gh, lazygit, tmux
- **Search**: ripgrep, fd, bat, eza, zoxide
- **Languages**: go, node, pnpm (all via mise)

### mise Tools (shared: `mise-tools.txt`)

- nodejs
- pnpm
- go
- kubectl
- k3d
- uv

### GUI Apps (mac only, via Brewfile)

- Ghostty, Docker, VS Code
- Raycast, Rectangle, Alt-Tab, Stats
- Bruno, Numi, Spotify

### Windows

- Oh My Posh, Terminal Icons, PSReadLine
- FiraCode Nerd Font
- VS Code

## Prerequisites

| Platform | Requirement                             |
| -------- | --------------------------------------- |
| macOS    | None (Homebrew installed automatically) |
| Linux    | Debian/Ubuntu-based distro, sudo access |
| Windows  | PowerShell 5.1+, winget                 |

## Usage

### macOS

```sh
git clone git@github.com:daronmcintosh/environment-setup.git
cd environment-setup
./mac-setup.sh
```

### Linux

One-liner (downloads and runs):

```sh
bash <(curl -s https://raw.githubusercontent.com/daronmcintosh/environment-setup/main/linux-setup.sh)
```

Or clone and run:

```sh
git clone git@github.com:daronmcintosh/environment-setup.git
cd environment-setup
./linux-setup.sh
```

### Windows

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/daronmcintosh/environment-setup/main/windows-setup.ps1'))
```

## File Structure

```
├── mac-setup.sh          # macOS setup script
├── linux-setup.sh        # Linux setup script
├── windows-setup.ps1     # Windows setup script
├── Brewfile              # Homebrew packages (mac)
├── linux-packages.txt    # apt packages (linux)
├── mise-tools.txt        # Shared mise tools (mac + linux)
├── winstall.json         # winget packages (windows, unused)
└── Dockerfile            # Test linux setup in container
```

## Testing

### Linux (Docker)

```sh
docker build --progress=plain -t env-test . && docker run --rm -it env-test
```

### Windows

Use [Windows 11 dev environment](https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/) VM.

## Customization

- Edit `Brewfile` for mac packages
- Edit `linux-packages.txt` for linux packages
- Edit `mise-tools.txt` for language runtimes
- Dotfiles come from [daronmcintosh/dotfiles](https://github.com/daronmcintosh/dotfiles)
