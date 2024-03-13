#!/bin/bash
set -ou pipefail

install_mac_packages() {
  echo "installing mac packages"
}

main() {
  source ./functions.sh

  install_mac_packages
  install_ohmyzsh
  setup_dotfiles # TODO: ensure tmux config is working
  # TODO: setup_neovim
  install_asdf
}

main


