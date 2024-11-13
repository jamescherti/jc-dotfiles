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
# Copyright (C) 2004-2024 James Cherti
#
# Distributed under terms of the GNU General Public License version 3.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

set -euf -o pipefail

LIST_FILES=(.tmux.conf)

run() {
  echo "[RUN]" "$@"
  "$@"
}

main() {
  if ! type -P rsync &>/dev/null; then
    echo "Error: 'rsync' not found in \$PATH" >&2
    exit 1
  fi

  # Synchronize all files (no delete, just rsync)
  local file
  for file in "${LIST_FILES[@]}"; do
    local opts=(--recursive --links --human-readable
      --times --atimes)
    rsync "${opts[@]}" "$file" "$HOME/$file"
    echo "[INSTALL] $HOME/$file"
  done
}

main "$@"
