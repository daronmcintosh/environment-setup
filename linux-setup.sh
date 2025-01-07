#!/bin/bash
set -ou pipefail

install_ohmyzsh() {
  echo "installing oh my zsh and cloning custom plugins"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  # git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
  chsh -s $(which zsh)
}

setup_dotfiles() {
  echo "setting up dotfiles"

  DOTFILES_DIR=$HOME/.dotfiles
  git clone --bare https://github.com/daronmcintosh/dotfiles.git $DOTFILES_DIR

  git --work-tree=$HOME --git-dir=$DOTFILES_DIR checkout
  if [ $? = 0 ]; then
    echo "checked out dotfiles"
  else
    echo "dotfiles conflict. stashing"
    git --work-tree=$HOME --git-dir=$DOTFILES_DIR stash
  fi

  git --work-tree=$HOME --git-dir=$DOTFILES_DIR checkout
  git --work-tree=$HOME --git-dir=$DOTFILES_DIR config --local status.showUntrackedFiles no
}

setup_neovim(){
  echo "setting up neovim"
  git clone https://github.com/daronmcintosh/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
}

install_asdf() {
  # https://blog.joaograssi.com/windows-subsystem-for-linux-with-oh-my-zsh-conemu/
  echo "installing asdf"
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2

  # add asdf to path so the following commands work
  export PATH="$PATH:~/.asdf/bin"
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  asdf plugin add kubectl https://github.com/asdf-community/asdf-kubectl.git
  asdf plugin add k3d https://github.com/spencergilbert/asdf-k3d.git
  # install all tools in .tools_version: https://asdf-vm.com/manage/configuration.html#tool-versions
  asdf install
}

install_neovim(){
  echo "installing neovim"
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
  sudo rm -rf /opt/nvim
  sudo tar -C /opt -xzf nvim-linux64.tar.gz
}

install_linux_packages() {
  echo "installing linux packages"
  # for debian based distros
  # TODO: replace exa with eza
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

main

