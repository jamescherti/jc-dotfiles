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
# Distributed under terms of the MIT license.
#
# Copyright (C) 2004-2024 James Cherti
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
  PATH="/opt/local/bin:$PATH"
  PATH="/opt/local/libexec/gnubin:$PATH"
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
# Emacs integration
#-------------------------------------------------------------------------------
if [ "$INSIDE_EMACS" = 'vterm' ]; then
  # vterm-clear-scrollback does exactly what the name suggests: it clears the
  # current buffer from the data that it is not currently visible.
  # vterm-clear-scrollback is bound to C-c C-l. This function is typically used
  # with the clear function provided by the shell to clear both screen and
  # scrollback. In order to achieve this behavior, you need to add a new shell
  # alias.
  clear() {
    vterm_printf "51;Evterm-clear-scrollback"
    tput clear
  }
fi

#-------------------------------------------------------------------------------
# Local profile
#-------------------------------------------------------------------------------
# shellcheck disable=SC1090
[ -f ~/.profile.local ] && source ~/.profile.local
