#!/bin/bash
set -eou pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_ohmyzsh() {
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
    git clone --bare https://github.com/daronmcintosh/dotfiles.git "$DOTFILES_DIR"
  fi

  git --work-tree=$HOME --git-dir=$DOTFILES_DIR checkout
  if [ $? = 0 ]; then
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

install_asdf() {
  # linux needs to install asdf manually (mac uses brew)
  echo "installing asdf"
  if [ ! -d "$HOME/.asdf" ]; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
  fi
}

setup_asdf() {
  echo "configuring asdf..."
  # add asdf to path so the following commands work
  export PATH="$PATH:~/.asdf/bin"

  # install plugins from shared list
  while read -r line; do
    [ -z "$line" ] && continue
    asdf plugin add $line 2>/dev/null || true
  done < "$SCRIPT_DIR/asdf-plugins.txt"

  # install all tools in .tools_version: https://asdf-vm.com/manage/configuration.html#tool-versions
  asdf install
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
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    tar -C "$HOME/.local" -xzf nvim-linux64.tar.gz
    mv "$HOME/.local/nvim-linux64" "$HOME/.local/nvim"
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
  install_asdf
  setup_asdf
}

main

