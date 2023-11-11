#!/bin/bash
set -eou pipefail
# TODO: maybe we can repurpose the repo to not only store dotfiles
# so we would update the setup script to clone repoName/dotfiles

install_packages() {
  echo "installing packages"
  # for debian based distros
  sudo apt update && sudo apt install -y \
    ca-certificates \
    curl \
    git \
    tmux \
    unzip \
    wget \
    zip \
    zsh \
    exa \
    bat \
    neofetch
}

install_ohmyzsh() {
  echo "installing oh my zsh and cloning custom plugins"
  # oh my zsh and custom plugins that need to be cloned
  # TODO: should I prompt to remove the $HOME/.oh-my-zsh/custom if it is there or remove the dir completely?
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

main() {
  install_packages
  install_ohmyzsh
  setup_dotfiles
  install_asdf
}

main

# TODO: docker will be manual install for mac and linux but a default one for windows with winget
