#!/bin/bash
set -ou pipefail

install_neovim(){
  echo "installing neovim"
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
  sudo rm -rf /opt/nvim
  sudo tar -C /opt -xzf nvim-linux64.tar.gz
}

install_linux_packages() {
  echo "installing linux packages"
  # for debian based distros
  sudo apt update && sudo apt install -y \
    bat \
    exa \
    ca-certificates \
    curl \
    git \
    neofetch \
    tmux \
    unzip \
    wget \
    zip \
    zsh
}

main() {
  install_linux_packages
  install_ohmyzsh
  install_neovim
  setup_dotfiles # TODO: ensure tmux config is working
  setup_neovim
  install_asdf
}

source ./functions.sh
main

