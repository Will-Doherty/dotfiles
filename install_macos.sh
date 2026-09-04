#!/usr/bin/env bash
set -e

if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Install Xcode Command Line Tools, then rerun this script."
  exit 1
fi

brew install git
brew install neovim
brew install tmux
brew install ripgrep
brew install fd
brew install pipx
brew install tree-sitter-cli
brew install yazi
brew install ffmpeg
brew install sevenzip
brew install jq
brew install poppler
brew install fzf
brew install zoxide
brew install imagemagick

pipx ensurepath
pipx install jedi-language-server || pipx upgrade jedi-language-server

mkdir -p ~/.local/share/nvim/site/pack/plugins/start
mkdir -p ~/.local/share/nvim/site/pack/colors/start
mkdir -p ~/.config

clone_or_update() {
  repo="$1"
  dest="$2"

  if [ -d "$dest/.git" ]; then
    git -C "$dest" pull
  else
    rm -rf "$dest"
    git clone "$repo" "$dest"
  fi
}

clone_or_update https://github.com/nvim-lua/plenary.nvim ~/.local/share/nvim/site/pack/plugins/start/plenary.nvim
clone_or_update https://github.com/nvim-telescope/telescope.nvim ~/.local/share/nvim/site/pack/plugins/start/telescope.nvim
clone_or_update https://github.com/folke/flash.nvim ~/.local/share/nvim/site/pack/plugins/start/flash.nvim
clone_or_update https://github.com/kylechui/nvim-surround ~/.local/share/nvim/site/pack/plugins/start/nvim-surround
clone_or_update https://github.com/nvim-treesitter/nvim-treesitter ~/.local/share/nvim/site/pack/plugins/start/nvim-treesitter
clone_or_update https://github.com/nvim-treesitter/nvim-treesitter-textobjects ~/.local/share/nvim/site/pack/plugins/start/nvim-treesitter-textobjects
clone_or_update https://github.com/mikavilpas/yazi.nvim ~/.local/share/nvim/site/pack/plugins/start/yazi.nvim
clone_or_update https://github.com/catppuccin/nvim ~/.local/share/nvim/site/pack/colors/start/catppuccin

if [ -e ~/.config/nvim ] && [ ! -L ~/.config/nvim ]; then
  mv ~/.config/nvim ~/.config/nvim.bak
fi

if [ -e ~/.tmux.conf ] && [ ! -L ~/.tmux.conf ]; then
  mv ~/.tmux.conf ~/.tmux.conf.bak
fi

if [ -e ~/.config/yazi ] && [ ! -L ~/.config/yazi ]; then
  mv ~/.config/yazi ~/.config/yazi.bak
fi

ln -sfn ~/.dotfiles/nvim ~/.config/nvim
ln -sfn ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -sfn ~/.dotfiles/yazi ~/.config/yazi

# Append the managed zsh block to ~/.zshrc. oh-my-zsh owns that file, so we
# append behind a marker rather than symlinking it. Guarded to stay idempotent.
zshrc_marker="# >>> dotfiles managed >>>"
if ! grep -qF "$zshrc_marker" ~/.zshrc 2>/dev/null; then
  {
    echo ""
    echo "$zshrc_marker"
    cat ~/.dotfiles/zsh/zshrc.snippet
    echo "# <<< dotfiles managed <<<"
  } >> ~/.zshrc
fi

nvim --headless '+TSUpdateSync' +qa
