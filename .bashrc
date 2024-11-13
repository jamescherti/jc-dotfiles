#!/usr/bin/env bash
#
# Author: James Cherti
# URL: https://github.com/jamescherti/jc-dotfiles
#
# Description:
# ------------
# Bash configuration (.bashrc).
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

#-------------------------------------------------------------------------------
# GLOBAL VARIABLES
#-------------------------------------------------------------------------------
TMOUT=650
TMOUT_ROOT=60

# Maximum number of lines to retain in the .bash_history file.
HISTFILESIZE="100000"

# Number of commands to keep in the current session's history list.
HISTSIZE="$HISTFILESIZE"

PS1_GIT_BRANCH=1
PS1_MAILDIR_PATH="$HOME/.maildir"
PS1_MAILDIR=1

#-------------------------------------------------------------------------------
# CHECKS
#-------------------------------------------------------------------------------
if [[ $_JC_BASHRC_LOADED != '' ]]; then
  return
else
  _JC_BASHRC_LOADED=1
fi

if [[ -f ~/.profile ]]; then
  # shellcheck disable=SC1090
  source ~/.profile
fi

if [[ -z "$BASH" ]]; then
  return
fi

case $- in
*i*)
  # Interactive
  ;;
*)
  # If not running interactively, don't do anything
  return
  ;;
esac

if [ "$USER" = "root" ]; then
  TMOUT="$TMOUT_ROOT"
fi

#-------------------------------------------------------------------------------
# OPTIONS
#-------------------------------------------------------------------------------
# Adjust terminal dimensions dynamically after each command, updating LINES and
# COLUMNS as needed.
[[ $DISPLAY ]] && shopt -s checkwinsize

# By default, Bash can autocomplete hostnames (such as those in `/etc/hosts`)
# when you type `ssh`, `ping`, or similar commands. This feature may slow
# down completion if the network has many hosts or if hostname completion
# is not needed, so it can be disabled with `shopt -u hostcomplete`.
shopt -u hostcomplete

# Enable case-insensitive pattern matching for conditional commands, pattern
# substitution, and programmable completion. When `nocasematch` is set, pattern
# matching in `case` statements, `[[ ... ]]` conditions, and pattern
# substitutions becomes case-insensitive.
shopt -s nocasematch

# The `direxpand` option changes how Bash handles directory names in the readline
# buffer during tab-completion. When `direxpand` is enabled, any shorthand paths,
# like `~` for the home directory, are replaced with the fully expanded path
# (e.g., `/home/user`) upon completion.
# shopt -s direxpand >/dev/null 2>&1

# Autocorrect minor typos in 'cd' commands. The `cdspell` option allows Bash to
# automatically correct minor spelling errors when using `cd`. For instance, if
# you type `cd /usr/loacl`, Bash will interpret it as `cd /usr/local`.
shopt -s cdspell

# Correct minor typos in directory names during pathname expansion. The
# `dirspell` option works similarly to `cdspell` but applies to directory name
# expansion in general. When enabled, it corrects minor spelling errors in
# directory names during tab-completion, helping to quickly locate intended
# directories even if typed inaccurately.
shopt -s dirspell >/dev/null 2>&1

# Setting `progcomp` enables pathname expansion without expanding variable
# expressions (`$VAR`) within the completion, so the original variable names are
# preserved in the command line.
shopt -s progcomp

# The `ignoreeof` option prevents the shell from exiting when you press
# `CTRL-D` (end-of-file).
set -o ignoreeof

# The `histverify` option allows users to review and edit commands before
# execution when recalling them from history with history expansion (`!`
# commands like `!!`, `!number`, or `!string`).
shopt -s histverify

# The `nocaseglob` option allows case-insensitive matching for filename
# expansion (also known as "pathname expansion"), which is the feature that
# expands patterns with wildcards (`*`, `?`, `[abc]`, etc.) to match filenames
# and directory names.
# shopt -s nocaseglob

# Enable "**" pattern to match files, directories, and all nested subdirectories
# in pathname expansion.
# shopt -s globstar >/dev/null 2>&1

#-------------------------------------------------------------------------------
# History
#-------------------------------------------------------------------------------

# Enable appending to the history file, rather than overwriting it.
shopt -s histappend

HISTTIMEFORMAT="%F %T " # 2018-05-17 19:24:05
HISTCONTROL=""

#-------------------------------------------------------------------------------
# Aliases
#-------------------------------------------------------------------------------
alias h=history
alias rsync='rsync --info=progress2 --human-readable -v'
alias super-rsync='rsync -a --delete --hard-links --acls --xattrs --sparse'
alias l=ls
alias bc="bc --quiet"
alias cls="clear"
alias md="mkdir"
alias e='ranger'
alias df='df -h -x overlay -x aufs -x tmpfs -x devtmpfs --print-type'

alias br="git --no-pager branch"
alias g="git"
alias glp="git log -p"
alias gitroot='cd "$(command git rev-parse --show-toplevel)"'
alias gt=gitroot

if type -P colordiff >/dev/null 2>&1; then
  alias diff=colordiff
fi

#-------------------------------------------------------------------------------
# Typos
#-------------------------------------------------------------------------------
alias sl=ls
alias sls=ls
alias sll=ls

alias v='vim'
alias vi='vim'
alias fim=vim
alias vmi=vim

alias ex=exit
alias exut=exit
alias x=exit

#-------------------------------------------------------------------------------
# Misc
#-------------------------------------------------------------------------------
if [[ $TERM != '' ]]; then
  # Disable flow control to prevent Vim from freezing when CTRL-s is pressed.
  # The `stty -ixon` command disables the XON/XOFF flow control, which is
  # typically triggered by CTRL-s (pause) and CTRL-q (resume) in the terminal.
  stty -ixon
fi

# Fix: gpg: signing failed: Inappropriate ioctl for device
GPG_TTY="$(tty)"
export GPG_TTY

#-------------------------------------------------------------------------------
# PS1
#-------------------------------------------------------------------------------
ps1-git-branch() {
  if [[ $PS1_GIT_BRANCH -ne 0 ]]; then
    local branch_name
    branch_name=$("$GIT_BIN_PATH" symbolic-ref --short -q HEAD 2>/dev/null) \
      || return 0
    echo -e "($branch_name) "
    return 0
  fi
}

ps1-count-mails-maildir() {
  if [[ $PS1_MAILDIR -ne 0 ]] && [[ $PS1_MAILDIR_PATH != "" ]]; then
    local num_mails=0
    local subdir
    for subdir in cur new; do
      local maildir="$PS1_MAILDIR_PATH/$subdir"
      if [[ -d "$maildir" ]]; then
        local cur_num_mails=0
        cur_num_mails=$(find "$maildir" -maxdepth 1 -type f | wc -l)
        num_mails=$((num_mails + cur_num_mails))
      fi
    done

    if [[ $num_mails -gt 0 ]]; then
      echo "[Mails:$num_mails] "
    fi
  fi
}

Color_Off="\[\033[0m\]" # Text Reset
Green="\[\033[0;32m\]"  # Green
Blue="\[\033[0;34m\]"   # Blue
Yellow="\[\033[0;33m\]" # Yellow
PathShort="\w"
PS1="$Green\$(ps1-git-branch)$Color_Off$Blue"
PS1="${PS1}\$(ps1-count-mails-maildir)$Color_Off"
PS1="${PS1}$MYPROMPT$PS1_USER_COLOR\$USER$Color_Off "
PS1="${PS1}$Yellow$PathShort$Color_Off $ "

#-------------------------------------------------------------------------------
# Local bashrc
#-------------------------------------------------------------------------------
# shellcheck disable=SC1090
[ -f ~/.bashrc.local ] && source ~/.bashrc.local
