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
# of this software and associated documentation files (the “Software”), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# shellcheck disable=SC2269
JC_DOTFILES_UNATTENDED="$JC_DOTFILES_UNATTENDED"
set -euf -o pipefail

LIST_FILES=(
  .gitconfig
  .tmux.conf
  .profile
  .bashrc
  .bash_profile
  .inputrc
  .fdignore
  .wcalcrc
  .colorgcc
  .gtkrc-2.0
  .rgignore
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

  if [[ $JC_DOTFILES_UNATTENDED = "" ]] \
    && [[ $JC_DOTFILES_UNATTENDED -eq 0 ]]; then
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

  if type -P difft &>/dev/null; then
    # Set the external diff tool (This handles 'git diff')
    git config --global diff.external difft

    # git d  -> Structural diff
    git config --global alias.d "-c diff.external=difft diff"

    # git ds -> Show recent commit with difftastic
    git config --global alias.ds "-c diff.external=difft show --ext-diff"

    # git dl -> Log with structural patches
    git config --global alias.dl "-c diff.external=difft log -p --ext-diff"

    # Don't prompt when running difftool
    git config --global difftool.prompt false

    # Use a pager for difftool output
    git config --global pager.difftool true

    # Define the tool and the command
    git config --global diff.tool "difftastic"

    # shellcheck disable=SC2016
    git config --global difftool.difftastic.cmd 'difft "$LOCAL" "$REMOTE"'

    # Normal git diff
    git config --global alias.ndiff 'diff --no-ext-diff'
  else
    # Normal git diff
    git config --global alias.ndiff 'diff'
  fi

  echo "Success."
}

main "$@"
