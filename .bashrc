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
#
# Distributed under terms of the MIT license.
#
# Copyright (C) 2004-2025 James Cherti
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

#-------------------------------------------------------------------------------
# CHECKS
#-------------------------------------------------------------------------------

if [[ -z "$BASH" ]]; then
  return
elif [[ $_JC_BASHRC_LOADED != '' ]]; then
  return
else
  _JC_BASHRC_LOADED=1
fi

#-------------------------------------------------------------------------------
# GLOBAL VARIABLES
#-------------------------------------------------------------------------------
TMOUT=650
TMOUT_ROOT=60

# Maximum number of lines to retain in the .bash_history file.
HISTFILESIZE="6000"

# Number of commands to keep in the current session's history list.
HISTSIZE="$HISTFILESIZE"

HISTTIMEFORMAT="%F %T " # 2018-05-17 19:24:05
HISTCONTROL=ignoredups:ignorespace

#-------------------------------------------------------------------------------
# FEATURES
#-------------------------------------------------------------------------------
# Display the current Git branch in the shell prompt (PS1)
JC_PS1_GIT_BRANCH=0

# Display the count of unread mails in the shell prompt (PS1)
JC_PS1_MAILDIR=0

# Directory containing the mail (e.g., to "$HOME/Mail")
JC_PS1_MAILDIR_PATH="$HOME/Mail"

# Use trash-rm as a safer alternative to rm by moving files to the trash instead
# of deleting them permanently.
#
# JC_TRASH_CLI=1 replaces the standard 'rm' command with a wrapper function
# that:
# - Provides a detailed summary of all specified files and directories,
#   including total size and file count.
# - Prompts the user for confirmation before proceeding with the deletion.
# - Moves files to the trash using 'trash-put' instead of permanently deleting
#   them with 'rm'.
# - Reports the current size of the trash in megabytes after each deletion.
# - Optionally wraps 'trash-empty' with an interactive prompt before purging the
#   trash.
#
# This setup is only activated for non-root users when 'trash-put' is available
# and 'JC_TRASH_CLI' is set to a non-zero value.
#
JC_TRASH_CLI=1

# Enable Emacs integration for vterm and EAT, configuring shell-side support for
# features such as prompt tracking and message passing
JC_EMACS_INTEGRATION=0

#-------------------------------------------------------------------------------
# INIT
#-------------------------------------------------------------------------------
if [[ -f ~/.bashrc-before.local ]]; then
  # shellcheck disable=SC1090
  source ~/.bashrc-before.local
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
# -s = enable | -u = disable
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

# Combine multi-line commands into a single history entry
shopt -s cmdhist

# Preserve literal newlines in multi-line commands
shopt -s lithist

# Enable appending to the history file, rather than overwriting it.
shopt -s histappend

# Append new commands to history, clear in-memory history, reload from file, and
# preserve existing PROMPT_COMMAND
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

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
alias ncdu="ncdu --color off"
alias tree="tree -C --gitignore"
alias mv="mv -i"
alias mode='stat -c "%a %n"'

alias br="git --no-pager branch"
alias g="git"
alias glp="git log -p"
alias grep="grep --color=auto --exclude-dir=.git"
alias rg="rg --hidden --no-messages --no-heading"
alias fd="fd --hidden"
alias fdf="fd --type file"
alias fdd="fd --type d"

alias gitroot='cd "$(command git rev-parse --show-toplevel)"'
alias gt=gitroot
alias gd="git diff HEAD"
alias gl="git log"
alias gp="git push"
alias gpf="git push --force"
alias gpl="git pull"
alias gb='git branch'

alias mountall='sudo udiskie-mount -a --recursive'
alias 7z_level9="7z -r -mx 9"
alias 7z_ultra='7z -t7z -mx=9 -mfb=273 -ms -md=31 -myx=9 -mtm=- -mmt -mmtf -md=1536m -mmf=bt3 -mmc=10000 -mpb=0 -mlc=0'

if command -v colordiff >/dev/null 2>&1; then
  alias diff=colordiff
fi

alias ipython='ipython --no-confirm-exit'
if command -v ipython >/dev/null 2>&1; then
  alias py=ipython
  alias ipy=ipython
else
  alias py='python -q'
  alias ipy='python -q'
fi

#-------------------------------------------------------------------------------
# Typos
#-------------------------------------------------------------------------------
alias sl=ls
alias sls=ls
alias sll=ls

alias dc=cd

alias v='vim'
alias vi='vim'
alias fim=vim
alias vmi=vim

alias ex=exit
alias exut=exit
alias x=exit

alias lsblk-uuid='lsblk -o NAME,UUID,MOUNTPOINT,FSTYPE'

#-------------------------------------------------------------------------------
# Misc
#-------------------------------------------------------------------------------
if [[ $TERM != '' ]]; then
  # Disable flow control to prevent Vim from freezing when CTRL-s is pressed.
  # The `stty -ixon` command disables the XON/XOFF flow control, which is
  # typically triggered by CTRL-s (pause) and CTRL-q (resume) in the terminal.
  stty -ixon
fi

#-------------------------------------------------------------------------------
# GPG
#-------------------------------------------------------------------------------
# Fix: gpg: signing failed: Inappropriate ioctl for device
# Ensure gpg-agent uses the correct terminal for pinentry prompts in TTY-based
# environments
if [[ -f ~/.gnupg/gpg-agent.conf ]]; then
  GPG_TTY="$(tty)"
  export GPG_TTY
  if command -v gpg-connect-agent &>/dev/null; then
    gpg-connect-agent updatestartuptty /bye >/dev/null
  fi
fi

#-------------------------------------------------------------------------------
# PS1
#-------------------------------------------------------------------------------
ps1-git-branch() {
  if [[ $JC_PS1_GIT_BRANCH -ne 0 ]]; then
    local branch_name
    branch_name=$("git" symbolic-ref --short -q HEAD 2>/dev/null) \
      || return 0
    echo -e "($branch_name) "
    return 0
  fi
}

ps1-count-mails-maildir() {
  if [[ $JC_PS1_MAILDIR -ne 0 ]] && [[ $JC_PS1_MAILDIR_PATH != "" ]]; then
    local num_mails=0
    local subdir
    for subdir in cur new; do
      local maildir="$JC_PS1_MAILDIR_PATH/$subdir"
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
# Functions
#-------------------------------------------------------------------------------

kill-gpg-agent() {
  pkill gpgconf
  pkill gpg-agent
  gpgconf --kill gpg-agent
}

_jc_better_cd() {
  # Function: _jc_better_cd
  # Description:
  # 1. 'cd path/to/file' changes the directory to 'path/to' (the parent directory
  #    of 'file').
  # 2. You can switch to the previous directory using 'popd' or 'cd -' (the
  #    function adds directories to the top of the directory stack).
  # 3. 'cd path/to/dir with spaces' changes the directory to "path/to/dir with
  #    spaces".
  # 4. 'cd file:///home/user' changes the directory to "/home/user".

  # Previous directory ('cd -')
  if [[ $# -eq 1 ]] && [[ $1 = '-' ]]; then
    popd >/dev/null || return 1
    return 0
  fi

  # Join paths
  local path
  if [[ $# -eq 0 ]]; then
    path="$HOME"
  else
    path=$(echo "$1" | sed -e 's/^file:\/\///')
    shift

    local item
    for item in "$@"; do
      path="${path} ${item}"
    done
  fi

  # Checks
  local errno=0
  if [[ -f "$path" ]]; then
    path=$(dirname "$path")
  fi

  if ! [[ -d "$path" ]]; then
    echo "$(basename "$0"):" "cd: $path: No such file or directory" >&2
    return 1
  fi

  # Change the directory
  pushd . >/dev/null || return 1
  builtin cd "$path" >/dev/null 2>&1 || errno=1
  if [[ $errno -ne 0 ]]; then
    echo "Error." >&2
    popd >/dev/null || return 1
  fi

  return "$errno"
}

alias cd=_jc_better_cd
alias ..='cd ..'
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ..4='cd ../../../..'
alias ..5='cd ../../../../..'

#-------------------------------------------------------------------------------
# The `_jc_xdg_open` function provides a cross-platform way to open files or
# URLs using the appropriate command for the system, with argument validation,
# user confirmation for large inputs, and asynchronous execution to prevent
# blocking the shell session.
#
# This function opens files or URLs using the appropriate command:
# - `xdg-open` on Linux,
# - `open` on macOS,
# - `start` on Windows.
#
# If more than 7 arguments are passed, the user is prompted for confirmation
# before proceeding.
#
# It checks that each item passed exists before attempting to open it.
#-------------------------------------------------------------------------------
_js_open_bin=xdg-open

case "$OSTYPE" in
darwin*)
  _js_open_bin=open
  ;;
cygwin* | msys* | win32*)
  _js_open_bin=start
  ;;
*)
  _js_open_bin=xdg-open
  ;;
esac

_jc_xdg_open() {
  local item

  if [[ $# -gt 7 ]]; then
    echo "$*"
    read -r -p "Proceed? [y,n] " answer
    if [[ "$answer" != "y" ]]; then
      echo "Interrupted." >&2
      return 1
    fi
  fi

  for item in "$@"; do
    if ! [[ -e "$item" ]]; then
      echo "Error: $item does not exist." >&2
      return 1
    fi
  done

  for item in "$@"; do
    (
      xdg-open "$item" &>/dev/null &
      disown
    )
  done

  return 0
}

alias o="_jc_xdg_open"

#-------------------------------------------------------------------------------
# Better ls
#-------------------------------------------------------------------------------
_jc_better_ls() {
  OPTS=()
  if [[ -n "$TERM" && "$TERM" != "dumb" ]]; then
    OPTS+=(--color=auto)
  fi

  command ls "${OPTS[@]}" -X --human-readable \
    --hide=__pycache__ \
    --hide=*.elc \
    --hide=*.egg-info \
    "$@"
}

alias ls='_jc_better_ls'

#-------------------------------------------------------------------------------
# Configure FASD
#-------------------------------------------------------------------------------
if command -v fasd >/dev/null 2>&1; then
  _JC_FASD_ENABLED=1

  _jc_fasd_cd() {
    if [ $# -le 1 ]; then
      fasd "$@"
    else
      local _fasd_ret
      _fasd_ret="$(fasd -e 'printf %s' "$@")"
      [ -z "$_fasd_ret" ] && return
      [ -d "$_fasd_ret" ] && cd "$_fasd_ret" || echo "$_fasd_ret"
    fi
  }
  eval "$(fasd --init bash-hook bash-ccomp bash-ccomp-install)"
  alias j="_jc_fasd_cd -d"
fi

#-------------------------------------------------------------------------------
# FZF
#-------------------------------------------------------------------------------
# if [ -f /opt/local/share/fzf/shell/completion.bash ]; then
#   # shellcheck disable=SC1091
#   source /opt/local/share/fzf/shell/completion.bash
# fi

# Key bindings
_JC_FZF=0
if [[ -f /usr/share/doc/fzf/examples/key-bindings.bash ]]; then
  # Debian/Ubuntu
  # shellcheck disable=SC1091
  source /usr/share/doc/fzf/examples/key-bindings.bash
  _JC_FZF=1
elif [[ -f /opt/local/share/fzf/shell/key-bindings.bash ]]; then
  # Mac OS X (Macport)
  # shellcheck disable=SC1091
  source /opt/local/share/fzf/shell/key-bindings.bash
  _JC_FZF=1
elif [[ -f /usr/share/fzf/key-bindings.bash ]]; then
  # Arch Linux
  # shellcheck disable=SC1091
  source /usr/share/fzf/key-bindings.bash
  _JC_FZF=1
fi

#-------------------------------------------------------------------------------
# bash-completion
#-------------------------------------------------------------------------------
case "$OSTYPE" in
# Mac OS X
darwin*)
  if [ -f /opt/local/etc/bash_completion ]; then
    # shellcheck disable=SC1091
    source /opt/local/etc/bash_completion
  fi

  if [ -f /opt/local/share/git/contrib/completion/git-completion.bash ]; then
    # shellcheck disable=SC1091
    source /opt/local/share/git/contrib/completion/git-completion.bash
  fi
  ;;
# Linux
linux-gnu*)
  if [ -r /usr/share/bash-completion/bash_completion ]; then
    # shellcheck disable=SC1091
    source /usr/share/bash-completion/bash_completion
  fi
  ;;
esac

#-------------------------------------------------------------------------------
# Tmux/fzf auto complete
# This defines a custom Bash autocomplete function that captures the current
# tmux scrollback buffer, extracts unique word-like tokens, and presents them
# via fzf for interactive fuzzy selection. The selected word is then inserted
# inline at the current cursor position using a readline binding.
#-------------------------------------------------------------------------------
if [[ $_JC_FZF -ne 0 ]]; then
  __tmux_fzf_autocomplete__() {
    # Capture the last 100,000 lines from the tmux scrollback buffer, reverse
    # order, and extract strings
    tmux capture-pane -pS -100000 \
      |
      # Split input on spaces and newlines, remove duplicates while preserving
      # order, and keep only strings longer than 4 characters
      awk 'BEGIN { RS = "[ \t\n]" } length($0) > 4 && !seen[$0]++' \
      |
      # Invoke fzf for case-insensitive exact fuzzy matching, with results shown
      # in reverse order
      fzf --no-sort --exact +i --tac
  }

  __tmux_fzf_autocomplete_inline__() {
    local selected
    selected="$(__tmux_fzf_autocomplete__)"

    local before
    before="${READLINE_LINE:0:$READLINE_POINT}"

    local after
    after="${READLINE_LINE:$READLINE_POINT}"

    READLINE_LINE="${before}${selected}${after}"
    READLINE_POINT=$((READLINE_POINT + ${#selected}))
  }

  # Pressing Ctrl-n autocompletes from the Tmux scrollback buffer
  bind -x '"\C-n": "__tmux_fzf_autocomplete_inline__"'
fi

#-------------------------------------------------------------------------------
# Confirm before executing certain commands
#
# The function prompts the user for confirmation before running any system
# command. This helps to prevent accidental execution of potentially dangerous
# commands, such as shutdown, reboot, or poweroff, by requiring a user to
# explicitly confirm their intention to proceed.
#-------------------------------------------------------------------------------
_jc_confirm_command() {
  if [ "$#" -eq "0" ]; then
    return 1
  fi

  if ! command -v "$1" &>/dev/null; then
    echo "Error: $1 doesn't exist."
    return 1
  fi

  local cmd
  cmd=$(basename "$1")
  read -r -p "Do you really want to run '$cmd'? [y,n] " answer

  if [ "$answer" = "y" ]; then
    echo "$@"
    "$@"
    return "$?"
  else
    echo "Canceled."
  fi

  return 1
}

# /bin/rm  was removed from the lias
_jc_create_confirm_aliases() {
  local cmd
  for cmd in shutdown poweroff reboot; do
    # shellcheck disable=SC2139
    alias "$cmd"="_jc_confirm_command $cmd"
  done
}

_jc_create_confirm_aliases

#-------------------------------------------------------------------------------
# macOS
#
# This block checks if certain GNU utilities (prefixed with 'g' on macOS) are
# available and creates aliases to use them in place of their BSD counterparts.
# These aliases help ensure compatibility with GNU commands on macOS for tools
# like install, rm, ls, and find, if the GNU versions are installed via a
# package manager like Homebrew.
#-------------------------------------------------------------------------------
case "$OSTYPE" in
darwin*)
  if command -v ginstall &>/dev/null; then
    alias install=ginstall
  fi

  if command -v grm &>/dev/null; then
    alias rm=grm
  fi

  if command -v gls &>/dev/null; then
    alias ls=gls
  fi

  if command -v gfind &>/dev/null; then
    alias find=gfind
  fi
  ;;
esac

#-------------------------------------------------------------------------------
# Trash
#-------------------------------------------------------------------------------
if [[ $UID -ne 0 ]] && [[ $JC_TRASH_CLI -ne 0 ]] \
  && type -P trash-put >/dev/null 2>&1; then
  # Confirm
  _jc_confirm_proceed() {
    read -r -p "Proceed? [y,n] " ANSWER
    if [[ "$ANSWER" != "y" ]]; then
      return 1
    fi
    return 0
  }

  # Display the trash size
  _jc_trash_size() {
    local list_trash_size
    local total_trash_size=0
    readarray -t list_trash_size < <(trash-list --size | awk '{ print $1 }')
    if [[ ${#list_trash_size[@]} -gt 0 ]]; then
      for trash_size in "${list_trash_size[@]}"; do
        total_trash_size=$((total_trash_size + trash_size))
      done
    fi

    echo "$total_trash_size"
    return 0
  }

  _jc_summary_dirs() {
    local total_files_size=0
    local size
    local total_files=0
    local count

    local arg
    for arg in "$@"; do
      if [[ ${arg:0:1} = '-' ]]; then
        continue
      fi

      if ! [[ -L "$arg" ]] && ! [[ -e "$arg" ]]; then
        echo "$arg: no such file or directory" >&2
        return 1
      fi

      size=$(du -s "$arg" | awk '{print $1}')
      total_files_size=$((total_files_size + size))

      count=$(find "$arg" -type f -o -type l | wc -l)
      total_files=$((total_files + count))

      find "$arg" -type f -o -type l
    done

    echo
    total_files_size=$((total_files_size / 1024))
    echo "Size: $total_files_size Mb"
    echo "Number of files: $total_files"

    return 0
  }

  _jc_trash_put_wrapper() {
    if [[ $# -eq 0 ]]; then
      echo "Error: missing operand" >&2
      return 1
    fi

    # local item
    local num_files=0
    for item in "$@"; do
      if [[ $item =~ ^- ]]; then
        continue
      fi

      num_files=$((num_files + 1))
    done

    if [[ $num_files -eq 0 ]]; then
      echo "Not enough arguments." >&2
      return 1
    fi

    _jc_summary_dirs "$@" || return 1
    _jc_confirm_proceed || return 1

    # Move it to trash
    local errno=0
    command trash-put "$@" || errno="$?"

    # Check the size of the trash
    local total_trash_size
    total_trash_size=$(_jc_trash_size)

    if [[ $errno -eq 0 ]]; then
      total_trash_size=$((total_trash_size / 1024 / 1024))
      if [[ $total_trash_size -gt 0 ]]; then
        echo
        echo "(Trash size: $total_trash_size Mb)"
      fi
    fi

    return "$errno"
  }

  _trash_empty_wrapper() {
    trash-list --size | sort
    read -r -p "Empty the trash? (y,n) " ANSWER
    if [[ "$ANSWER" != "y" ]]; then
      return 1
    fi

    if command trash-empty --help | command grep -- '-f' &>/dev/null; then
      command trash-empty -f
    else
      command trash-empty
    fi
  }

  alias trash-empty=_trash_empty_wrapper
  alias trash-rm=_jc_trash_put_wrapper
  alias trash-put=_jc_trash_put_wrapper
  alias rm=_jc_trash_put_wrapper
  alias real-rm='$(type -P rm) -I'
else
  alias rm='rm -I'
  alias real-rm=rm
fi

#-------------------------------------------------------------------------------
# Emacs integration
#-------------------------------------------------------------------------------
if [[ $JC_EMACS_INTEGRATION -ne 0 ]]; then
  # vterm
  if [ "$INSIDE_EMACS" = 'vterm' ]; then
    # Some of the most useful features in vterm (e.g., directory-tracking and
    # prompt-tracking or message passing) require shell-side configurations. The
    # main goal of these additional functions is to enable the shell to send
    # information to vterm via properly escaped sequences. A function that helps
    # in this task, vterm_printf, is defined below. This function is widely used
    # throughout this readme.
    vterm_printf() {
      if [ -n "$TMUX" ] \
        && { [ "${TERM%%-*}" = "tmux" ] \
          || [ "${TERM%%-*}" = "screen" ]; }; then
        # Tell tmux to pass the escape sequences through
        printf "\ePtmux;\e\e]%s\007\e\\" "$1"
      elif [ "${TERM%%-*}" = "screen" ]; then
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$1"
      else
        printf "\e]%s\e\\" "$1"
      fi
    }

    clear() {
      vterm_printf "51;Evterm-clear-scrollback"
      tput clear
    }
  fi

  # Eat (Emulate A Terminal)
  # shellcheck disable=SC1091
  if [ -n "$EAT_SHELL_INTEGRATION_DIR" ]; then
    source "$EAT_SHELL_INTEGRATION_DIR/bash"
  fi
fi

#-------------------------------------------------------------------------------
# Local bashrc
#-------------------------------------------------------------------------------
if [[ -f ~/.bashrc-after.local ]]; then
  # shellcheck disable=SC1090
  source ~/.bashrc-after.local
fi
