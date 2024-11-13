#!/usr/bin/env sh
#
# Author: James Cherti
# URL: https://github.com/jamescherti/jc-dotfiles
#
# Description:
# ------------
# A '.profile' file configuration file that is executed when a user logs into
# their account or starts a new shell session.
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

if test "$_JC_PROFILE_LOADED" != ''; then
  return
else
  _JC_PROFILE_LOADED=1
fi

# shellcheck disable=SC1091
[ -f /etc/profile ] && . /etc/profile

#----------------------------------------------------------------------------
# The PATH environment variable
#----------------------------------------------------------------------------
_jc_append_path() {
  test -L "$1" && return
  ! test -d "$1" && return
  case ":$PATH:" in
  *:"$1":*) ;;
  *)
    PATH="${PATH:+$PATH:}$1"
    ;;
  esac
}

_jc_add_local_path() {
  if [ -z "$1" ]; then
    return 1
  fi
  _jc_append_path "$1/bin"
  export MANPATH="$1/share/man:$MANPATH"
  export INFOPATH="$1/share/info:$INFOPATH"
  export LD_LIBRARY_PATH="$1/lib:$LD_LIBRARY_PATH"
  export PKG_CONFIG_PATH="$1/lib/pkgconfig:$PKG_CONFIG_PATH"
  export CMAKE_PREFIX_PATH="$1:$CMAKE_PREFIX_PATH"
}

_jc_append_path '/sbin'
_jc_append_path '/bin'
_jc_append_path '/usr/sbin'
_jc_append_path '/usr/bin'
_jc_append_path '/usr/local/sbin'
_jc_append_path '/usr/local/bin'

_jc_add_local_path "$HOME/.local"
case "$OSTYPE" in
darwin*)
  # Mac Port
  _jc_append_path "/opt/local/bin"
  _jc_append_path "/opt/local/libexec/gnubin"
  ;;
esac

#----------------------------------------------------------------------------
# Other environment variables
#----------------------------------------------------------------------------
export LESS="-X -F -R"
export PAGER="less"

export MANWIDTH=79
export MANPAGER=less
export EDITOR=vim
export LS_COLORS=''

# The sdcv command line interface
export STARDICT_DATA_DIR=~/.sdcv_dict
export SDCV_HISTSIZE=0
export SDCV_PAGER=less

export TMPDIR="/tmp/tmp_$USER"
if ! test -d "/tmp/tmp_$USER"; then
  install -d --mode=700 "/tmp/tmp_$USER"
fi

#-------------------------------------------------------------------------------
# Local profile
#-------------------------------------------------------------------------------
# shellcheck disable=SC1090
[ -f ~/.profile.local ] && source ~/.profile.local
