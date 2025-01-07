#!/bin/bash
set -ou pipefail

BREW_PKGS=(
  asdf
  bat
  eza
	fastfetch
	gh
  neovim
  tmux
  wget
  zoxide
  zsh
)
BREW_CASK_PKGS=(
  alt-tab
  docker
  google-cloud-sdk
  ghostty
  raycast
  rectangle
)

install_mac_packages() {
  echo "installing mac packages"
  for i in "${BREW_PKGS[@]}"; do brew install $i; done
  for i in "${BREW_CASK_PKGS[@]}"; do brew install --cask $i; done
}

install_ohmyzsh() {
  echo "installing ohmyzsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  # git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
  chsh -s $(which zsh)
}

setup_dotfiles() {
  echo "configuring dotfiles..."

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
  echo "configuring neovim..."
  git clone https://github.com/daronmcintosh/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
}

setup_asdf() {
  echo "configuring asdf..."
  # add asdf to path so the following commands work
  export PATH="$PATH:~/.asdf/bin"
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  asdf plugin add kubectl https://github.com/asdf-community/asdf-kubectl.git
  asdf plugin add k3d https://github.com/spencergilbert/asdf-k3d.git
  asdf plugin add pnpm
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
