#!/usr/bin/env bash
set -e

# ---------------------------------------------------------------------------
# Prerequisites
# ---------------------------------------------------------------------------

if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Install Xcode Command Line Tools, then rerun this script."
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Make brew available in this shell even on a fresh machine, where ~/.zprofile
# has not been sourced yet.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ---------------------------------------------------------------------------
# Command line tools
# ---------------------------------------------------------------------------

brew install \
  neovim \
  tmux \
  ripgrep \
  fd \
  fzf \
  zoxide \
  yazi \
  pipx \
  glow \
  tree-sitter-cli \
  uv \
  herdr \
  tuicr \

# uv and herdr are also distributed as curl installers, which is how this
# machine originally got them:
#   curl -LsSf https://astral.sh/uv/install.sh | sh
#   curl -fsSL https://herdr.dev/install.sh | sh
# Both are in homebrew/core, so we prefer brew for a single upgrade path.

# ---------------------------------------------------------------------------
# Shell
# ---------------------------------------------------------------------------

# Must run before the ~/.zshrc block below: the oh-my-zsh installer replaces
# ~/.zshrc with its own template (backing up any existing one). --unattended
# stops it from launching a subshell or running chsh.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
fi

# ---------------------------------------------------------------------------
# Python language server
# ---------------------------------------------------------------------------

pipx ensurepath
pipx install jedi-language-server || pipx upgrade jedi-language-server

# ---------------------------------------------------------------------------
# Neovim plugins
#
# No plugin manager: these are cloned straight into Neovim's native pack
# directory, where anything under */start/ is loaded automatically.
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# Treesitter parsers
# ---------------------------------------------------------------------------

nvim --headless '+TSUpdateSync' +qa
