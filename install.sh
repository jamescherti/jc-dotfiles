#!/usr/bin/env bash
#
# Requirements:
#   - rsync
#
# Author: James Cherti
# URL: https://github.com/jamescherti/jc-dotfiles
#
# Description:
# ------------
# Install the dotfiles into the home directory.
#
# License:
# --------
# Distributed under terms of the MIT license.
#
# Copyright (C) 2004-2026 James Cherti
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# shellcheck disable=SC2269
set -euf -o pipefail

LIST_FILES=(
  .gitattributes.global
  .gitconfig
  .gitignore.global
  .tmux.conf
  .profile
  .bashrc
  .bash_profile
  .inputrc
  .ignore
  .wcalcrc
  .colorgcc
  .gtkrc-2.0
  .Xresources
  .alsoftrc
  .ansible-lint_global.yml
  .hidden
  .mypy.ini
  .pep257
  .proselintrc
  .puppet-lint.rc
  .pylintrc
  .yamllint_global.yml
  .fasdrc

  # Dirs
  .parallel
  .config
  .ccache
  .dosbox
  .elodie
  .ipython
)

run() {
  echo "[RUN]" "$@"
  "$@"
}

main() {
  if ! command -v rsync &>/dev/null; then
    echo "Error: 'rsync' not found in \$PATH" >&2
    exit 1
  fi

  SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
  cd "$SCRIPT_DIR"

  # Required directories
  mkdir -p ~/.config

  # Synchronize all files (no delete, just rsync)
  local file
  local opts=(-a)
  for file in "${LIST_FILES[@]}"; do
    if [[ -f "$file" ]]; then
      echo "$HOME/$file"
    elif [[ -d "$file" ]]; then
      echo "$HOME/$file/"
    else
      echo "Error: $HOME/$file/" >&2
    fi
    opts+=("$file")
  done

  if [[ "${JC_DOTFILES_UNATTENDED:-}" = "" ]] \
    && [[ "${JC_DOTFILES_UNATTENDED:-}" -eq 0 ]]; then
    echo
    read -r -p "Install the above files? [y,n] " ANSWER
    if [[ "$ANSWER" != "y" ]]; then
      echo "Interrupted." >&2
      exit 1
    fi
  fi

  # echo rsync "${opts[@]}" "$HOME/"
  mkdir -p ~/.git-templates
  echo

  rsync "${opts[@]}" "$HOME/"

  if type -P devemacs &>/dev/null; then
    # Set the core Git editor to devemacs
    git config --global core.editor "devemacs -nw"
  fi

  local delta_exists=0
  if type -P delta &>/dev/null; then
    delta_exists=1
  fi

  local difft_exists=0
  if type -P difft &>/dev/null; then
    difft_exists=1
  fi

  # Configure Delta settings whenever the binary is present
  if [[ $delta_exists -ne 0 ]]; then
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.side-by-side true
  fi

  local less_cmd
  less_cmd=less
  if [[ $difft_exists -ne 0 ]]; then
    # Difftastic exists: make it the default and keep delta aside
    git config --global diff.external difft
    git config --global core.pager "$less_cmd"
    git config --global pager.diff "$less_cmd"
    git config --global pager.show "$less_cmd"
    git config --global pager.log "$less_cmd"
    git config --global pager.difftool "$less_cmd"

    # Don't prompt when running difftool
    git config --global difftool.prompt false

    # Define the tool and the command
    git config --global diff.tool "difftastic"

    # shellcheck disable=SC2016
    git config --global difftool.difftastic.cmd 'difft "$LOCAL" "$REMOTE"'

    if [[ $delta_exists -ne 0 ]]; then
      # Explicit Delta diff
      git config --global alias.ddiff '!git -c core.pager=delta -c pager.diff=delta diff --no-ext-diff'
    fi

    # git d  -> Structural diff
    # git config --global alias.d "diff"

    # git ds -> Show recent commit with difftastic
    # git config --global alias.ds "show --ext-diff"

    # git dl -> Log with structural patches
    # git config --global alias.dl "log -p --ext-diff"
  elif [[ $delta_exists -ne 0 ]]; then
    # Only delta exists: use delta as the primary pager
    git config --global core.pager delta

    # Explicit Delta diff (same behavior as ndiff in this fallback state)
    git config --global alias.ddiff "diff"

    # git config --global alias.d "diff"
    # git config --global alias.ds "show"
    # git config --global alias.dl "log -p"

  fi

  # Legacy
  rm -f ~/.config/mpv/scripts/autoload.lua
  rm -f ~/.config/mpv/scripts/delete-file.lua
  rm -f ~/.config/mpv/scripts/freeze-geometry.lua
  rm -f ~/.config/mpv/scripts/keep-session.lua
  rm -f ~/.config/mpv/scripts/pause-indicator.lua
  rm -f ~/.config/mpv/scripts/regularly-write-watch-later-config.lua
  rm -f ~/.config/mpv/scripts/show-filename.lua

  # Pathaction
  cp -uv "$SCRIPT_DIR/.default_pathaction.yaml" "$HOME/.pathaction.yaml"

  echo "Success."
}

main "$@"
