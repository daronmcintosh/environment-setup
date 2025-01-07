#!/bin/bash
set -ou pipefail

install_mac_packages() {
  echo "installing mac packages"
  brew install bat eza fastfetch gh neovim tmux wget zoxide zsh 
}

main() {
  install_mac_packages
  install_ohmyzsh
  setup_dotfiles # TODO: ensure tmux config is working
  setup_neovim
  install_asdf
}

main
