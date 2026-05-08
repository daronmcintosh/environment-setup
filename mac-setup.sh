#!/bin/bash
set -eou pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# clone url into dir if missing, otherwise pull latest
clone_or_update() {
  local url=$1
  local dir=$2
  if [ -d "$dir" ]; then
    echo "updating $dir"
    git -C "$dir" pull --ff-only
  else
    echo "cloning $url to $dir"
    git clone "$url" "$dir"
  fi
}

install_homebrew() {
  if command -v brew &> /dev/null; then
    echo "homebrew already installed, skipping"
  else
    echo "installing homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # ensure brew is on PATH for the rest of the script (fresh installs don't have it yet)
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_mac_packages() {
  echo "installing mac packages"
  brew bundle --file="$SCRIPT_DIR/Brewfile"
}

install_ohmyzsh() {
  if [ -d "${ZSH:-$HOME/.oh-my-zsh}" ]; then
    echo "ohmyzsh already installed, skipping"
  else
    echo "installing ohmyzsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
  fi

  P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  clone_or_update https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"

  AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
  clone_or_update https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"

  # use system zsh, not brew zsh, to avoid /etc/shells changes
  local zsh_path=/bin/zsh
  local current_shell
  current_shell="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')"
  if [ "$current_shell" = "$zsh_path" ]; then
    echo "default shell already $zsh_path, skipping chsh"
  else
    chsh -s "$zsh_path"
  fi
}

setup_dotfiles() {
  echo "configuring dotfiles..."

  DOTFILES_DIR=$HOME/.dotfiles
  local first_run=0
  if [ ! -d "$DOTFILES_DIR" ]; then
    git clone --bare https://github.com/daronmcintosh/dotfiles.git "$DOTFILES_DIR"
    first_run=1
  fi

  local dotfiles_git=(git --work-tree="$HOME" --git-dir="$DOTFILES_DIR")

  if [ "$first_run" -eq 1 ]; then
    local checkout_output
    if checkout_output=$("${dotfiles_git[@]}" checkout 2>&1); then
      echo "checked out dotfiles"
    else
      echo "dotfiles conflict, backing up existing files"
      local backup_dir="$HOME/.dotfiles-backup-$(date +%Y-%m-%d_%H-%M-%S)"
      mkdir -p "$backup_dir"
      while read -r file; do
        [ -e "$HOME/$file" ] || continue
        mkdir -p "$backup_dir/$(dirname "$file")"
        mv "$HOME/$file" "$backup_dir/$file"
      done < <(printf '%s\n' "$checkout_output" | awk '/^[[:space:]]+[^[:space:]]/ {print $1}')
      echo "backed up conflicting files to $backup_dir"
      "${dotfiles_git[@]}" checkout
    fi
    "${dotfiles_git[@]}" config --local status.showUntrackedFiles no
  else
    echo "updating dotfiles"
    "${dotfiles_git[@]}" pull --ff-only
  fi
}

setup_neovim(){
  echo "configuring neovim..."
  NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  clone_or_update https://github.com/daronmcintosh/kickstart.nvim.git "$NVIM_DIR"
}

setup_asdf() {
  echo "configuring asdf..."
  # add asdf to path so the following commands work
  export PATH="$PATH:$HOME/.asdf/bin"

  # install plugins from shared list
  while read -r line; do
    [ -z "$line" ] && continue
    asdf plugin add $line 2>/dev/null || true
  done < "$SCRIPT_DIR/asdf-plugins.txt"

  # install all tools in .tools_version: https://asdf-vm.com/manage/configuration.html#tool-versions
  asdf install
}

main() {
  install_homebrew
  install_mac_packages
  install_ohmyzsh
  setup_dotfiles # TODO: ensure tmux config is working
  setup_neovim
  setup_asdf
}

echo "starting mac setup..."
main
echo "mac setup complete!"
