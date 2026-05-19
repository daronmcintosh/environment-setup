#!/bin/bash
set -eou pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_homebrew() {
  if command -v brew &> /dev/null; then
    echo "homebrew already installed, skipping"
    return
  fi
  echo "installing homebrew"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_mac_packages() {
  echo "installing mac packages"
  brew bundle --file="$SCRIPT_DIR/Brewfile"
}

install_ohmyzsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "ohmyzsh already installed, skipping"
    return
  fi
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

  chsh -s $(which zsh)
}

setup_dotfiles() {
  echo "configuring dotfiles..."

  DOTFILES_DIR=$HOME/.dotfiles
  if [ ! -d "$DOTFILES_DIR" ]; then
    git clone --bare https://github.com/daronmcintosh/dotfiles.git "$DOTFILES_DIR"
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
  echo "configuring neovim..."
  NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  if [ ! -d "$NVIM_DIR" ]; then
    git clone https://github.com/daronmcintosh/kickstart.nvim.git "$NVIM_DIR"
  fi
}

setup_mise() {
  echo "configuring mise..."
  # mise is installed via Brewfile, already on PATH

  mkdir -p "$HOME/.config/mise"
  ln -sf "$SCRIPT_DIR/mise.toml" "$HOME/.config/mise/config.toml"
  mise trust "$SCRIPT_DIR/mise.toml"
  mise install
}

main() {
  install_homebrew
  install_mac_packages
  install_ohmyzsh
  setup_dotfiles # TODO: ensure tmux config is working
  setup_neovim
  setup_mise
}

echo "starting mac setup..."
main
echo "mac setup complete!"
