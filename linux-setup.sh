#!/bin/bash
set -eou pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_ohmyzsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "ohmyzsh already installed, skipping"
    return
  fi
  echo "installing oh my zsh and cloning custom plugins"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [ ! -d "$P10K_DIR" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  fi

  AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
  if [ ! -d "$AUTOSUGGESTIONS_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"
  fi

  chsh -s $(which zsh)
}

setup_dotfiles() {
  echo "setting up dotfiles"

  DOTFILES_DIR=$HOME/.dotfiles
  if [ ! -d "$DOTFILES_DIR" ]; then
    dotfiles_url="https://github.com/daronmcintosh/dotfiles.git"
    if [ -n "${SSH_AUTH_SOCK:-}" ] || [ -f "$HOME/.ssh/id_ed25519" ] || [ -f "$HOME/.ssh/id_rsa" ]; then
      dotfiles_url="git@github.com:daronmcintosh/dotfiles.git"
    fi
    git clone --bare "$dotfiles_url" "$DOTFILES_DIR"
  fi

  if git --work-tree=$HOME --git-dir=$DOTFILES_DIR checkout; then
    echo "checked out dotfiles"
  else
    echo "dotfiles conflict. stashing"
    git --work-tree=$HOME --git-dir=$DOTFILES_DIR stash
    git --work-tree=$HOME --git-dir=$DOTFILES_DIR checkout
  fi

  git --work-tree=$HOME --git-dir=$DOTFILES_DIR config --local status.showUntrackedFiles no
}

setup_neovim(){
  echo "setting up neovim"
  NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  if [ ! -d "$NVIM_DIR" ]; then
    git clone https://github.com/daronmcintosh/kickstart.nvim.git "$NVIM_DIR"
  fi
}

install_mise() {
  if command -v mise &>/dev/null; then
    echo "mise already installed, skipping"
    return
  fi
  echo "installing mise"
  curl -fsSL https://mise.run | sh
}

setup_mise() {
  echo "configuring mise..."
  export PATH="$HOME/.local/bin:$PATH"

  mkdir -p "$HOME/.config/mise"
  ln -sf "$SCRIPT_DIR/mise.toml" "$HOME/.config/mise/config.toml"
  mise trust "$SCRIPT_DIR/mise.toml"
  mise install
}

install_neovim(){
  echo "installing neovim"
  if command -v nvim &>/dev/null; then
    echo "neovim already installed, skipping"
    return
  fi
  mkdir -p "$HOME/.local"
  (
    cd "$(mktemp -d)"
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    tar -C "$HOME/.local" -xzf nvim-linux-x86_64.tar.gz
    mv "$HOME/.local/nvim-linux-x86_64" "$HOME/.local/nvim"
  )
}

install_linux_packages() {
  echo "installing linux packages"
  # for debian based distros
  sudo apt update && xargs -a "$SCRIPT_DIR/linux-packages.txt" sudo apt install -y
}

main() {
  install_linux_packages
  install_ohmyzsh
  install_neovim
  setup_neovim
  setup_dotfiles # TODO: ensure tmux config is working
  install_mise
  setup_mise
}

main

