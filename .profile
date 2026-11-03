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
# This file is POSIX compliant. It can work with POSIX sh.
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

# shellcheck disable=SC1091
[ -f "$HOME/.profile-before.local" ] && . "$HOME/.profile-before.local"

#----------------------------------------------------------------------------
# The PATH environment variable
#----------------------------------------------------------------------------
append_path() {
  case ":$PATH:" in
  *:"$1":*) ;;
  *)
    PATH="${PATH:+$PATH:}$1"
    ;;
  esac
}

prepend_path() {
  case ":$PATH:" in
  *:"$1":*) ;;
  *)
    PATH="$1${PATH:+:$PATH}"
    ;;
  esac
}

_jc_add_local_path() {
  if [ -z "$1" ]; then
    return 1
  fi
  prepend_path "$1/bin"
  export MANPATH="$1/share/man:$MANPATH"
  export INFOPATH="$1/share/info:$INFOPATH"
  export LD_LIBRARY_PATH="$1/lib64:$1/lib:$LD_LIBRARY_PATH"
  export C_INCLUDE_PATH="$1/include:$LD_LIBRARY_PATH"
  export CPLUS_INCLUDE_PATH="$1/include:$LD_LIBRARY_PATH"
}

append_path '/usr/local/sbin'
append_path '/usr/local/bin'
append_path '/usr/bin'

append_path '/sbin'
append_path '/bin'
append_path '/usr/sbin'

_jc_add_local_path "$HOME/.local"

if [ -z "$BASH_VERSION" ]; then
  if [ -z "$OSTYPE" ] && [ "$(uname)" = "Darwin" ]; then
    OSTYPE=darwin
  fi
fi

case "$OSTYPE" in
darwin*)
  # Mac Port
  PATH="/opt/local/libexec/gnubin:/opt/local/bin:$PATH"
  ;;
esac

# Force PATH to be environment
export PATH

# Unset GLOBSORT, before anything else is sourced This variable will be part of
# bash => 5.3 The rationale is that the user should always be able to expect
# that the snippets be processed in a deterministic order.
unset -v GLOBSORT

# Unload _jc_add_local_path
# unset -f append_path

# Termcap is outdated, old, and crusty
unset TERMCAP

# Man is much better than us at figuring this out
unset MANPATH

#----------------------------------------------------------------------------
# Other environment variables
#----------------------------------------------------------------------------
export LESS="-RFXSMi -x4"
export PAGER="less"

export MANWIDTH=79
export MANPAGER=less
export EDITOR=vim
export LS_COLORS=''

# The sdcv command line interface
export STARDICT_DATA_DIR=~/.sdcv_dict
export SDCV_HISTSIZE=0
export SDCV_PAGER=less

export XZ_OPT=-9e

export TMPDIR="/tmp/tmp_$USER"
if ! [ -d "$TMPDIR" ]; then
  mkdir -p "$TMPDIR"
  chmod 700 "$TMPDIR"
fi

# Mac: Silence the message "Default Interactive shell is now zsh"
export BASH_SILENCE_DEPRECATION_WARNING=1

# Instruct difftastic to silently exit when it evaluates files with identical
# content.
#
# When Git pipes a 0-byte file (such as your .nosearch) to difftastic, the
# parser determines there is zero textual difference. By default, difftastic
# explicitly reports 'No changes.'.
#
# Enabling this variable modifies that default behavior:
# - Difftastic suppresses the text parsing fallback header.
# - Difftastic suppresses the 'No changes.' output string.
# - The command exits cleanly without printing to stdout.
export DFT_SKIP_UNCHANGED=true

export PYLINTRC="$HOME/.pylintrc"

# Centralize the cache directory to prevent Ruff from scattering .ruff_cache
# folders across individual project directories and cluttering the filesystem.
export RUFF_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/ruff"

#-------------------------------------------------------------------------------
# FASD
#-------------------------------------------------------------------------------
# Override fasd's default behavior of cluttering the $HOME directory with its
# data files by explicitly defining a dedicated subdirectory for its data.
_FASD_DATA_DIR="$HOME/.fasd_data"
export _FASD_DATA="$_FASD_DATA_DIR/fasd"
if ! [ -d "$_FASD_DATA_DIR" ]; then
  mkdir -p "$_FASD_DATA_DIR"
fi

#-------------------------------------------------------------------------------
# ncpu
#-------------------------------------------------------------------------------
if [ -z "$_JC_NCPU_SCRIPT" ]; then
  _JC_NCPU_SCRIPT=$(command -v ncpu 2>/dev/null) || _JC_NCPU_SCRIPT=""
fi

# shellcheck disable=SC2120
_jc_ncpu() {
  if [ $# -gt 0 ] || [ -z "$_JC_NCPU" ]; then
    if ! [ -z "$_JC_NCPU_SCRIPT" ]; then
      # shellcheck disable=SC1090
      _JC_NCPU=$(command "$_JC_NCPU_SCRIPT" "$@")
    else
      # Fallback
      _JC_NCPU=$(getconf _NPROCESSORS_ONLN 2>/dev/null \
        || nproc 2>/dev/null \
        || sysctl -n hw.ncpu 2>/dev/null \
        || echo 1)
    fi
  fi

  echo "$_JC_NCPU"
}

alias ncpu=_jc_ncpu

if [ -z "$_JC_NCPU" ]; then
  _jc_ncpu >/dev/null
fi

#-------------------------------------------------------------------------------
# Custom environment
#-------------------------------------------------------------------------------
jc_env_path_delete() {
  # Validate to avoid, for example, `jc_env_path_delete 'PATH; rm -rf /' /tmp`
  case $1 in
  *[!A-Za-z0-9_]* | '') return 1 ;;
  esac

  eval "_pr_val=\${$1}"
  _pr_new=""

  while [ -n "$_pr_val" ]; do
    # Extract the first path component using POSIX parameter
    # expansion.
    _pr_dir="${_pr_val%%:*}"

    # This avoids an infinite loop when no : exists.
    if [ "$_pr_val" = "$_pr_dir" ]; then
      _pr_val=""
    else
      _pr_val="${_pr_val#*:}"
    fi

    # Reconstruction
    if [ "$_pr_dir" != "$2" ] && [ -n "$_pr_dir" ]; then
      _pr_new="${_pr_new}${_pr_new:+:}${_pr_dir}"
    fi
  done

  eval "export ${1}=\"\$_pr_new\""
  unset _pr_val _pr_new _pr_dir
}

# Usage: jc_env_path_append VAR "/path/to/dir"
jc_env_path_append() {
  # Validate to avoid, for example, `jc_env_path_append 'PATH; rm -rf /' /tmp`
  case $1 in
  *[!A-Za-z0-9_]* | '')
    return 1
    ;;
  esac

  jc_env_path_delete "$1" "$2"

  eval "_pa_val=\${$1}"

  if [ -z "$_pa_val" ]; then
    eval "$1=\"\$2\""
  else
    eval "$1=\"\$_pa_val:\$2\""
  fi

  eval 'export $1'

  unset _pa_val
}

# Usage: path_prepend VAR "/path/to/dir"
jc_env_path_prepend() {
  # Validate to avoid, for example, `path_prepend 'PATH; rm -rf /' /tmp`
  case $1 in
  *[!A-Za-z0-9_]* | '')
    return 1
    ;;
  esac

  jc_env_path_delete "$1" "$2"

  eval "_pp_val=\${$1}"

  if [ -z "$_pp_val" ]; then
    eval "$1=\"\$2\""
  else
    eval "$1=\"\$2:\$_pp_val\""
  fi

  eval 'export $1'

  unset _pp_val
}

#-------------------------------------------------------------------------------
# Python
#-------------------------------------------------------------------------------
export PYTHONPYCACHEPREFIX="$HOME/.cache/python_cache"
export MYPY_CACHE_DIR="$HOME/.cache/python_cache_mypy"
export PYTHON_EGG_CACHE="$HOME/.cache/python_cache_egg"
export PIP_DOWNLOAD_CACHE="$HOME/.cache/python_cache_pip_download"

#-------------------------------------------------------------------------------
# MISC
#-------------------------------------------------------------------------------
if [ -z "$OS_ID" ]; then
  OS_ID=$(
    # shellcheck disable=SC1091
    [ -r /etc/os-release ] && . /etc/os-release 2>/dev/null
    printf '%s\n' "${ID:-unknown}"
  )
  export OS_ID
fi

# Prepend the OS-specific binary directory to PATH if it exists and is not
# already included.
# shellcheck disable=SC2034
OS_BIN_DIR="$HOME/.local-$OS_ID/bin"
if [ -n "$OS_ID" ] && [ -d "$OS_BIN_DIR" ]; then
  case ":$PATH:" in
  *":$OS_BIN_DIR:"*) ;;
  *) export PATH="$OS_BIN_DIR:$PATH" ;;
  esac
fi

#-------------------------------------------------------------------------------
# OTHER
#-------------------------------------------------------------------------------
export BATCHFETCH_CHECK_UNTRACKED=1

#-------------------------------------------------------------------------------
# Local profile
#-------------------------------------------------------------------------------

# shellcheck disable=SC1091
[ -f "$HOME/.profile-after.local" ] && . "$HOME/.profile-after.local"

#-------------------------------------------------------------------------------
# Bashrc
#-------------------------------------------------------------------------------

if test "$BASH" \
  && test "$PS1" \
  && test -z "$POSIXLY_CORRECT" \
  && test "${0#-}" != sh \
  && test -r ~/.bashrc; then
  if [ -z "$_JC_BASHRC_LOADED" ]; then
    _JC_PROFILE_SOURCING_BASHRC=1
    # shellcheck disable=SC1090
    . ~/.bashrc
    unset _JC_PROFILE_SOURCING_BASHRC
    _JC_BASHRC_LOADED=1
  fi
fi
