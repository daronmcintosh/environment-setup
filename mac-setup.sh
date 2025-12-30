#!/bin/bash
set -ou pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# TODO: checkout https://gist.github.com/shortjared/c22745d791f84ea9cecd8f804a084d01

install_mac_packages() {
  echo "installing mac packages"
  brew bundle --file="$SCRIPT_DIR/Brewfile"
}

install_ohmyzsh() {
  echo "installing ohmyzsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [ ! -d "$P10K_DIR" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  fi

  AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
  if [ ! -d "$AUTOSUGGESTIONS_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"
  fi

  # git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
  chsh -s $(which zsh)
}

setup_dotfiles() {
  echo "configuring dotfiles..."

  DOTFILES_DIR=$HOME/.dotfiles
  if [ ! -d "$DOTFILES_DIR" ]; then
    git clone --bare git@github.com:daronmcintosh/dotfiles.git "$DOTFILES_DIR"
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
  echo "configuring neovim..."
  NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  if [ ! -d "$NVIM_DIR" ]; then
    git clone git@github.com:daronmcintosh/kickstart.nvim.git "$NVIM_DIR"
  fi
}

setup_asdf() {
  echo "configuring asdf..."
  # add asdf to path so the following commands work
  export PATH="$PATH:~/.asdf/bin"
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git 2>/dev/null || true
  asdf plugin add kubectl https://github.com/asdf-community/asdf-kubectl.git 2>/dev/null || true
  asdf plugin add k3d https://github.com/spencergilbert/asdf-k3d.git 2>/dev/null || true
  asdf plugin add pnpm 2>/dev/null || true
  # install all tools in .tools_version: https://asdf-vm.com/manage/configuration.html#tool-versions
  asdf install
}

main() {
  install_mac_packages
  install_ohmyzsh
  setup_dotfiles # TODO: ensure tmux config is working
  setup_neovim
  setup_asdf
}

echo "starting mac setup..."
main
echo "mac setup complete!"
