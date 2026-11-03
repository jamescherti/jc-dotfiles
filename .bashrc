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
#

#-------------------------------------------------------------------------------
# CHECKS
#-------------------------------------------------------------------------------

if [[ -z "$BASH" ]]; then
  return
fi

_JC_BASHRC_LOADED=1

# shellcheck disable=SC1090
if [[ -r ~/.profile && -z "$_JC_PROFILE_SOURCING_BASHRC" ]]; then
  source ~/.profile
fi

#-------------------------------------------------------------------------------
# GLOBAL VARIABLES
#-------------------------------------------------------------------------------
TMOUT=650
if ((UID == 0)); then
  TMOUT="60"
fi

# Maximum number of lines to retain in the .bash_history file.
HISTFILESIZE="6000"

# Number of commands to keep in the current session's history list.
HISTSIZE="$HISTFILESIZE"

HISTTIMEFORMAT="%F %T " # 2018-05-17 19:24:05

#-------------------------------------------------------------------------------
# FEATURES
#-------------------------------------------------------------------------------
# Automatically restore the last working directory from the previous
# interactive Bash session.
JC_RESTORE_LAST_DIR=0

# Path of the file that records the last working directory, enabling automatic
# restoration when $JC_RESTORE_LAST_DIR is set to a non-zero value.
JC_RESTORE_LAST_DIR_FILE="$HOME/.bash_lastdir"

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

# Enable support for the fasd command-line utility, which provides fast access
# to frequently used files and directories.
JC_FASD=0

# Change JC_FIX_GPG_TTY to 1 to synchronize the GPG agent with the current
# terminal environment by detecting the active TTY and informing the agent where
# to display passphrase prompts. This fix runs automatically via PROMPT_COMMAND,
# which ensures that GPG prompts follow the user when switching between
# different terminal windows or tmux panes.
JC_FIX_GPG_TTY=0

#-------------------------------------------------------------------------------
# Reset variables
#-------------------------------------------------------------------------------
PROMPT_COMMAND=""

#-------------------------------------------------------------------------------
# INIT
#-------------------------------------------------------------------------------
if [[ -r ~/.bashrc-before.local ]]; then
  # shellcheck disable=SC1090
  source ~/.bashrc-before.local
fi

case $- in
*i*)
  # Interactive
  ;;
*)
  # If not running interactively, don't do anything
  if [[ -r ~/.bashrc-after.local ]]; then
    # shellcheck disable=SC1090
    source ~/.bashrc-after.local
  fi

  return
  ;;
esac

#-------------------------------------------------------------------------------
# Variables
#-------------------------------------------------------------------------------
INPUTRC=~/.inputrc

#-------------------------------------------------------------------------------
# OPTIONS
# -s = enable | -u = disable
#-------------------------------------------------------------------------------
# Adjust terminal dimensions dynamically after each command, updating LINES and
# COLUMNS as needed.
[[ -n "$DISPLAY" ]] && shopt -s checkwinsize

# By default, Bash can autocomplete hostnames (such as those in /etc/hosts) when
# you type ssh, ping, or similar commands. This feature may slow down completion
# if the network has many hosts or if hostname completion is not needed, so it
# can be disabled with shopt -u hostcomplete.
shopt -u hostcomplete &>/dev/null

# Autocorrect minor typos in 'cd' commands. The cdspell option allows Bash to
# automatically correct minor spelling errors when using cd. For instance, if
# you type cd /usr/local, Bash interpret it as cd /usr/local.
shopt -s cdspell &>/dev/null

# Correct minor typos in directory names during pathname expansion. The dirspell
# option works similarly to cdspell but applies to directory name expansion in
# general. When enabled, it corrects minor spelling errors in directory names
# during tab-completion, helping to quickly locate intended directories even if
# typed inaccurately.
shopt -s dirspell &>/dev/null

# Setting progcomp enables pathname expansion without expanding variable
# expressions ($VAR) within the completion, so the original variable names are
# preserved in the command line.
shopt -s progcomp &>/dev/null

# The histverify option allows users to review and edit commands before
# execution when recalling them from history with history expansion (! commands
# like !!, !number, or !string).
shopt -s histverify &>/dev/null

# The nocaseglob option allows case-insensitive matching for filename expansion
# (also known as "pathname expansion"), which is the feature that expands
# patterns with wildcards (*, ?, [abc], etc.) to match filenames and directory
# names.
shopt -s nocaseglob &>/dev/null

# Enable "**" pattern to match files, directories, and all nested subdirectories
# in pathname expansion.
shopt -s globstar &>/dev/null

# Allows cd VAR to work if $VAR is set to a directory.
# Convenient if you often use environment variables for directories.
shopt -s cdable_vars &>/dev/null

# Lets you type a directory name without cd to change into it. Can speed up
# navigation in the shell.
shopt -s autocd &>/dev/null

# Bash remembers where commands are: When you type a command like ls or mycmd,
# Bash remembers its location (full path) in a cache called the hash table. This
# makes Bash faster because it doesn't have to search your PATH every time.
# Problem: If you replace a command during your session (for example, you
# install a new version of a program, or overwrite a script with a different
# version), Bash might still use the old cached path instead of the new one.
# the "shopt -s checkhash" option fixes this:
# shopt -s checkhash

# The direxpand option changes how Bash handles directory names in the readline
# buffer during tab-completion. When direxpand is enabled, any shorthand paths,
# like ~ for the home directory, are replaced with the fully expanded path
# (e.g., /home/user) upon completion.
# shopt -s direxpand &>/dev/null

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
alias df='df -h -x overlay -x aufs -x tmpfs -x devtmpfs --print-type'
alias ncdu="ncdu --color dark"
alias tree="tree -C --gitignore"
alias mv="mv -i"
alias mode='stat -c "%a %n"'
alias yamllint="yamllint -c ~/.yamllint_global.yml"

alias br="git --no-pager branch"
alias g="git"
alias glp="git log -p"
alias grep="grep --color=auto --exclude-dir=.git"

rg() {
  if [ -z "$_JC_NCPU" ]; then
    _jc_ncpu >/dev/null
  fi

  command rg --sort=none --hidden --no-messages --no-heading \
    --threads="$_JC_NCPU" "$@"
}

fd() {
  if [ -z "$_JC_NCPU" ]; then
    _jc_ncpu >/dev/null
  fi

  command fd --color=never --hidden --threads="$_JC_NCPU" "$@"
}

alias rgf='rg --fixed-strings'
alias rgl='rg --files-with-matches'
alias rgq='rg --quiet'
if type -P rg >/dev/null 2>&1; then
  alias gr='rg'
else
  alias gr='grep -R -i --no-messages'
fi

# shellcheck disable=SC2139
alias fdf="fd --type file"
alias fdd="fd --type d"
alias fdq='fd --quiet'

alias gitroot='cd "$(command git rev-parse --show-toplevel)"'
alias gt=gitroot
alias gd="git diff HEAD"
alias gl="git log"
alias gp="git push"
alias gpf="git push --force"
alias gpl="git pull"
alias gb='git branch'
alias gs="git show"
alias ca=wcalc

alias 7z_level9="7z -r -mx 9"
alias 7z_ultra='7z -t7z -mx=9 -mfb=273 -ms -md=31 -myx=9 -mtm=- -mmt -mmtf \
  -md=1536m -mmf=bt3 -mmc=10000 -mpb=0 -mlc=0'

if type -P colordiff &>/dev/null; then
  alias diff=colordiff
fi

alias ipython='ipython --no-confirm-exit'
if type -P ipython &>/dev/null; then
  alias py=ipython
  alias ipy=ipython
else
  alias py='python -q'
  alias ipy='python -q'
fi

if type -P bat &>/dev/null; then
  alias cat='bat --plain --paging=never'
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
# JC NPROC
#-------------------------------------------------------------------------------
# Scale build concurrency to the hardware thread count and restrict the load
# average to ensure the environment stays responsive by leaving one core
# available for other tasks.
#
# Alternative to: export MAKEFLAGS="-j `nproc` -l `nproc --ignore=1`"

alias make='make -j$(ncpu) -l$(ncpu --ignore=1)'

#-------------------------------------------------------------------------------
# Misc
#-------------------------------------------------------------------------------
if [[ -n "$TERM" && -t 0 ]]; then
  # Disable flow control to prevent Vim from freezing when CTRL-s is pressed.
  # The 'stty -ixon' command disables the XON/XOFF flow control, which is
  # typically triggered by CTRL-s (pause) and CTRL-q (resume) in the terminal.
  command stty -ixon 2>/dev/null
fi

#-------------------------------------------------------------------------------
# GPG
#-------------------------------------------------------------------------------
jc-fix-gpg-tty() {
  local current_tty
  current_tty=$(command tty 2>/dev/null) || return

  # Only update the agent if the TTY has changed
  if [[ "$GPG_TTY" != "$current_tty" ]]; then
    # Fix:
    # gpg: signing failed: Inappropriate ioctl for device [GNUPG:] FAILURE sign
    # gpg: signing failed: Inappropriate ioctl for device fatal: failed to write
    # commit object
    export GPG_TTY="$current_tty"

    # When using tmux, ensure gpg-agent updates its TTY when the session is
    # reattached
    if [[ -n "$TMUX" ]] && type -P gpg-connect-agent &>/dev/null; then
      command gpg-connect-agent updatestartuptty /bye &>/dev/null || :
    fi
  fi
}

if [[ ${JC_FIX_GPG_TTY:-1} -ne 0 ]]; then
  # Check if running inside tmux or GNU screen
  if [[ -n "$TMUX" || -n "$STY" ]]; then
    # Multiplexer detected: hook into PROMPT_COMMAND.
    #
    # It must be in the PROMPT_COMMAND if you use tools like tmux, screen, or
    # frequently detach and reattach to Emacs daemon frames.
    if [[ $_JC_FIX_GPG_TTY_DONE = "" ]]; then
      _JC_FIX_GPG_TTY_DONE=1
      if [[ -z "${PROMPT_COMMAND:-}" ]]; then
        PROMPT_COMMAND="jc-fix-gpg-tty"
      else
        PROMPT_COMMAND="jc-fix-gpg-tty; $PROMPT_COMMAND"
      fi
    fi
  else
    # Standard terminal detected: run exactly once during startup
    jc-fix-gpg-tty
  fi
fi

#-------------------------------------------------------------------------------
# PS1
#-------------------------------------------------------------------------------
jc-ps1-git-branch-slow() {
  if [[ $JC_PS1_GIT_BRANCH -ne 0 ]]; then
    local branch_name
    # Run the plumbing command directly in the condition to avoid a separate
    # evaluation step
    if branch_name=$(command git symbolic-ref --short -q HEAD 2>/dev/null); then
      printf '(%s) ' "$branch_name"
    fi
  fi
}

jc-ps1-git-branch() {
  if [[ $JC_PS1_GIT_BRANCH -ne 0 ]]; then
    local dir="$PWD"
    local head_file=""
    local git_marker=0

    # Fast path: Find .git/HEAD by walking up the directory tree in pure Bash
    while [[ -n "$dir" && "$dir" != "/" ]]; do
      if [[ -f "$dir/.git/HEAD" ]]; then
        head_file="$dir/.git/HEAD"
        git_marker=1
        break
      elif [[ -e "$dir/.git" ]]; then
        git_marker=1
        break
      fi
      dir="${dir%/*}"
    done

    if [[ $git_marker -eq 0 ]]; then
      return 0
    fi

    # If we found a standard Git repository
    if [[ -n "$head_file" ]]; then
      local head_ref
      # Read the first line of the file directly
      read -r head_ref <"$head_file" 2>/dev/null

      # If it is a standard branch, extract the name and exit immediately
      if [[ "$head_ref" == ref:\ refs/heads/* ]]; then
        printf '(%s) ' "${head_ref#ref: refs/heads/}"
        return 0
      fi
      return 0
    fi

    # Slow path fallback: Use the git binary for submodules, worktrees, or
    # detached HEADs
    local branch_name
    if branch_name=$(command git symbolic-ref --short -q HEAD 2>/dev/null); then
      printf '(%s) ' "$branch_name"
    fi
  fi
}

jc-ps1-count-mails-maildir() {
  if [[ $JC_PS1_MAILDIR -ne 0 ]] && [[ "$JC_PS1_MAILDIR_PATH" != "" ]]; then
    # The Maildir specification dictates that unread messages reside exclusively
    # in the 'new/' subdirectory.
    local maildir="$JC_PS1_MAILDIR_PATH/new"
    if [[ -d "$maildir" ]]; then
      local file
      # Use a loop with an immediate break to achieve O(1) time and memory
      # complexity. This avoids expanding thousands of files into an array if
      # the mailbox is large.
      for file in "$maildir"/*; do
        # If the directory is empty, Bash evaluates the glob as a literal
        # asterisk. Checking for existence (-e) or a symbolic link (-L) prevents
        # false positives.
        if [[ -e "$file" || -L "$file" ]]; then
          printf '[Unread mail] '
          break
        fi
      done
    fi
  fi
}

_jc_ps1_update() {
  _JC_PS1_GIT=""
  _JC_PS1_MAIL=""

  if [[ $JC_PS1_GIT_BRANCH -ne 0 ]]; then
    local dir="$PWD"
    local head_file=""
    local git_marker=0

    while [[ -n "$dir" && "$dir" != "/" ]]; do
      if [[ -f "$dir/.git/HEAD" ]]; then
        head_file="$dir/.git/HEAD"
        git_marker=1
        break
      elif [[ -e "$dir/.git" ]]; then
        git_marker=1
        break
      fi
      dir="${dir%/*}"
    done

    if [[ $git_marker -ne 0 ]]; then
      if [[ -n "$head_file" ]]; then
        local head_ref
        read -r head_ref <"$head_file" 2>/dev/null
        if [[ "$head_ref" == ref:\ refs/heads/* ]]; then
          _JC_PS1_GIT="(${head_ref#ref: refs/heads/}) "
        fi
      else
        local branch_name
        if branch_name=$(command \
          git symbolic-ref --short -q HEAD 2>/dev/null); then
          _JC_PS1_GIT="($branch_name) "
        fi
      fi
    fi
  fi

  if [[ $JC_PS1_MAILDIR -ne 0 ]] && [[ "$JC_PS1_MAILDIR_PATH" != "" ]]; then
    local maildir="$JC_PS1_MAILDIR_PATH/new"
    if [[ -d "$maildir" ]]; then
      local file
      for file in "$maildir"/*; do
        if [[ -e "$file" || -L "$file" ]]; then
          _JC_PS1_MAIL="[Unread mail] "
          break
        fi
      done
    fi
  fi
}

if [[ "$TERM" == *256color* ||
  "$TERM" == *truecolor* ||
  "$TERM" == *direct* ||
  "$TERM" == xterm* ||
  "$TERM" == screen* ||
  "$TERM" == tmux* ||
  "$TERM" == rxvt* ||
  "$TERM" == linux* ||
  "$TERM" == *kitty* ||
  "$TERM" == *alacritty* ||
  "$TERM" == *foot* ||
  "$TERM" == *wezterm* ||
  "$TERM" == eat* ]] \
  || { type -P tput &>/dev/null \
    && [[ $(command tput colors 2>/dev/null) -ge 8 ]]; }; then
  # shellcheck disable=SC2034
  Color_Off="\[\033[0m\]" # Text Reset
  # shellcheck disable=SC2034
  Green="\[\033[0;32m\]" # Green
  # shellcheck disable=SC2034
  Blue="\[\033[0;34m\]" # Blue
  # shellcheck disable=SC2034
  Yellow="\[\033[0;33m\]" # Yellow
  PathShort="\w"

  # Ensure PS1_USER_COLOR is wrapped if it only contains a raw color code If it
  # is already wrapped where it is defined, you can remove the \[ and \] here.
  if [[ -n "${PS1_USER_COLOR:-}" ]]; then
    Safe_User_Color="\[${PS1_USER_COLOR}\]"
  else
    Safe_User_Color=""
  fi

  PS1="${Green}\${_JC_PS1_GIT}${Color_Off}"
  PS1="${PS1}${Blue}\${_JC_PS1_MAIL}${Color_Off}"
  PS1="${PS1}${MYPROMPT:-}${Safe_User_Color}\$USER${Color_Off} "
  PS1="${PS1}${Yellow}${PathShort}${Color_Off} $ "
else
  PS1="\${_JC_PS1_GIT}"
  PS1="${PS1}\${_JC_PS1_MAIL}$MYPROMPT\$USER $PathShort $ "
fi

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

jc-bg-run-and-own() {
  "$@" &
}

jc-bg-run() {
  jc-bg-run-and-own "$@" &>/dev/null
  disown
}

jc-kill-gpg-agent() {
  command pkill gpgconf || :
  command pkill gpg-agent || :
  command gpgconf --kill gpg-agent || :
}

jc-fix-gpg-agent() {
  command gpg-connect-agent updatestartuptty /bye &>/dev/null || :
}

_jc_better_cd() {
  # Function: _jc_better_cd
  # Description:
  # 1. 'cd path/to/file' changes the directory to 'path/to' (the parent
  #    directory of 'file').
  # 2. You can switch to the previous directory using 'popd' or 'cd -' (the
  #    function adds directories to the top of the directory stack).
  # 3. 'cd path/to/dir with spaces' changes the directory to "path/to/dir with
  #    spaces".
  # 4. 'cd file:///home/user' changes the directory to "/home/user".
  # 5. Supports 'cd' flags (e.g. -P, -L) and '--' to handle paths starting with
  #    -.

  # Parse cd options (e.g. -P, -L)
  local -a opts
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -)
      popd >/dev/null || return 1
      return 0
      ;;
    --help)
      builtin cd --help || return "$?"
      return
      ;;
    --)
      shift
      break
      ;;
    -[!-]*)
      opts+=("$1")
      shift
      ;;
    *)
      break
      ;;
    esac
  done

  # Join paths
  local path
  if [[ $# -eq 0 ]]; then
    path="$HOME"
  else
    path="${1#file://}"
    shift

    local item
    for item in "$@"; do
      path="${path} ${item}"
    done
  fi

  # Canonicalize path without requirement on path existence
  path=$(command realpath -s -m "$path" 2>/dev/null || echo "$path")

  # Checks
  local errno=0
  if [[ -f "$path" ]]; then
    path=$(command dirname "$path")
  fi

  if ! [[ -d "$path" ]]; then
    echo "Error: cd: $path: No such file or directory" >&2
    return 1
  fi

  # Change the directory
  # || true to skip "Permission denied" when the directory is read-only.

  local run_popd=0
  if ! pushd . >/dev/null; then
    run_popd=0
  fi

  # Use -- to ensure path is not interpreted as a flag
  builtin cd "${opts[@]}" -- "$path" || errno=1
  if [[ $errno -ne 0 ]]; then
    echo "Error." >&2
    if [[ $run_popd -ne 0 ]]; then
      popd >/dev/null || return 1
    fi
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
# The _jc_xdg_open function provides a cross-platform way to open files or
# URLs using the appropriate command for the system, with argument validation,
# user confirmation for large inputs, and asynchronous execution to prevent
# blocking the shell session.
#
# This function opens files or URLs using the appropriate command:
# - xdg-open on Linux,
# - open on macOS,
# - start on Windows.
#
# If more than 7 arguments are passed, the user is prompted for confirmation
# before proceeding.
#
# It checks that each item passed exists before attempting to open it.
#-------------------------------------------------------------------------------
_JS_OPEN_BIN=xdg-open

case "$OSTYPE" in
darwin*)
  _JS_OPEN_BIN=open
  ;;
cygwin* | msys* | win32*)
  _JS_OPEN_BIN=start
  ;;
*)
  _JS_OPEN_BIN=xdg-open
  ;;
esac

_jc_xdg_open() {
  local item

  if (($# > 7)); then
    echo "$*"
    local answer
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
    command "$_JS_OPEN_BIN" "$item" &>/dev/null &
    disown
  done

  return 0
}

alias o="_jc_xdg_open"

#-------------------------------------------------------------------------------
# Better ls
#-------------------------------------------------------------------------------
_JC_GNU_LS=1
_JC_LS_CMD="ls"
case "$OSTYPE" in
darwin*)
  if type -P gls &>/dev/null; then
    _JC_LS_CMD="gls"
  else
    _JC_GNU_LS=0
  fi
  ;;
esac

_jc_better_ls() {
  local -a OPTS=()

  if [[ $_JC_GNU_LS -ne 0 ]]; then
    if [[ -n "$TERM" && "$TERM" != "dumb" ]]; then
      OPTS+=(--color=auto)
    fi

    command "$_JC_LS_CMD" "${OPTS[@]}" -X --human-readable \
      --hide=__pycache__ \
      --hide=*.elc \
      --hide=*.egg-info \
      "$@"
  else
    command "$_JC_LS_CMD" "${OPTS[@]}" "$@"
  fi
}

alias ls='_jc_better_ls'

#-------------------------------------------------------------------------------
# mawk
#-------------------------------------------------------------------------------

# The GNU awk (gawk) implementation is standard on many systems, but mawk is a
# bytecode-compiled implementation that is significantly faster.
if type -P mawk &>/dev/null; then
  alias awk=mawk
fi

#-------------------------------------------------------------------------------
# Configure FASD
#-------------------------------------------------------------------------------
if [[ $JC_FASD -ne 0 ]] && type -P fasd &>/dev/null; then
  _JC_FASD_ENABLED=1

  _jc_fasd_cd() {
    if [ $# -le 1 ]; then
      command fasd "$@"
    else
      local _fasd_ret
      _fasd_ret="$(command fasd -e 'printf %s' "$@")"
      [ -z "$_fasd_ret" ] && return
      [ -d "$_fasd_ret" ] && cd "$_fasd_ret" || echo "$_fasd_ret"
    fi
  }

  # This spawns a subshell, executes the fasd binary, captures the output, and
  # then evaluates it. Doing this on every single startup adds measurable
  # latency:
  # eval "$(command fasd --init bash-hook bash-ccomp bash-ccomp-install)"
  #
  # Cache the initialization script to a file and source it. You only need to
  # regenerate the cache if the fasd binary gets updated.
  _fasd_cache="$HOME/.fasd-init.bash"
  if [[ ! -s "$_fasd_cache" ]]; then
    # posix-alias: Defines standard POSIX-compatible aliases (a, s, d, f, sd,
    # sf, z, zz) and the fasd_cd shell function used for directory navigation.
    #
    # bash-hook: Appends a hook function to PROMPT_COMMAND that inspects
    # recently executed commands and logs accessed paths to the frecency
    # database in the background.
    #
    # bash-ccomp: Defines the Bash tab completion logic
    # (_fasd_bash_cmd_complete) and the registration helper function
    # (_fasd_bash_hook_cmd_complete).
    #
    # bash-ccomp-install: Registers the completion handler via 'complete -F' for
    # the fasd executable and its default aliases (fasd, a, s, d, f, sd, sf, z,
    # zz).
    command fasd --init posix-alias bash-hook bash-ccomp \
      bash-ccomp-install >|"$_fasd_cache"
  fi
  # shellcheck disable=SC1090
  source "$_fasd_cache"
  unset _fasd_cache

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
# FZF variables
#-------------------------------------------------------------------------------
if [[ "${_JC_FZF:-0}" -ne 0 ]]; then
  if command -v rg >/dev/null 2>&1; then
    FZF_DEFAULT_COMMAND="rg --threads=$_JC_NCPU --files --hidden --follow 2>/dev/null"
    export FZF_DEFAULT_COMMAND
  elif command -v fd >/dev/null 2>&1; then
    FZF_DEFAULT_COMMAND="fd --threads=$_JC_NCPU --color=never -H --type f --follow"
    export FZF_DEFAULT_COMMAND
  elif command -v fdfind >/dev/null 2>&1; then
    FZF_DEFAULT_COMMAND="fdfind --threads=$_JC_NCPU --color=never -H --type f"
    export FZF_DEFAULT_COMMAND
  else
    FZF_DEFAULT_COMMAND='find . -type d -name .git -prune -o -type f -print'
    export FZF_DEFAULT_COMMAND
  fi

  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_DEFAULT_OPTS="--cycle -i --multi --exact --bind alt-j:down,alt-k:up"
fi

#-------------------------------------------------------------------------------
# Tmux/fzf auto complete
# This defines a custom Bash autocomplete function that captures the current
# tmux scrollback buffer, extracts unique word-like tokens, and presents them
# via fzf for interactive fuzzy selection. The selected word is then inserted
# inline at the current cursor position using a readline binding.
#-------------------------------------------------------------------------------
if [[ "${_JC_FZF:-0}" -ne 0 ]]; then
  __tmux_fzf_autocomplete__() {
    # Capture the last 100,000 lines from the tmux scrollback buffer, reverse
    # order, and extract strings
    command tmux capture-pane -pS -100000 \
      |
      # Split input on spaces and newlines, remove duplicates while preserving
      # order, and keep only strings longer than 4 characters
      awk 'BEGIN { RS = "[ \t\n]" } length($0) > 4 && !seen[$0]++' \
      |
      # Invoke fzf for case-insensitive exact fuzzy matching, with results shown
      # in reverse order
      command fzf --no-sort --exact +i --tac
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
# bash-completion
#-------------------------------------------------------------------------------
_jc_lazy_bash_completion() {
  complete -r -D 2>/dev/null

  case "$OSTYPE" in
  # Mac OS X
  darwin*)
    if [[ -z "${BASH_COMPLETION_VERSINFO:-}" ]] \
      && [ -r /opt/local/etc/bash_completion ]; then
      # shellcheck disable=SC1091
      source /opt/local/etc/bash_completion
    fi

    if [ -r /opt/local/share/git/contrib/completion/git-completion.bash ]; then
      # shellcheck disable=SC1091
      source /opt/local/share/git/contrib/completion/git-completion.bash
    fi
    ;;
  # Linux
  linux-gnu*)
    if [[ -z "${BASH_COMPLETION_VERSINFO:-}" ]] \
      && [ -r /usr/share/bash-completion/bash_completion ]; then
      # shellcheck disable=SC1091
      source /usr/share/bash-completion/bash_completion
    fi
    ;;
  esac

  if [[ -n "${1:-}" ]] \
    && ! complete -p "$1" &>/dev/null \
    && declare -F _completion_loader &>/dev/null; then
    _completion_loader "$@"
  fi
  return 124
}

if [[ -z "${BASH_COMPLETION_VERSINFO:-}" || "$OSTYPE" == darwin* ]]; then
  complete -D -F _jc_lazy_bash_completion
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
  if [[ $# -eq 0 ]]; then
    return 1
  fi

  if ! type -P "$1" &>/dev/null; then
    echo "Error: $1 doesn't exist."
    return 1
  fi

  local cmd
  cmd=$(command basename "$1")
  local answer
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
  if type -P ginstall &>/dev/null; then
    alias install=ginstall
  fi

  if type -P grm &>/dev/null; then
    alias rm=grm
  fi

  if type -P gfind &>/dev/null; then
    alias find=gfind
  fi
  ;;
esac

#-------------------------------------------------------------------------------
# Trash
#-------------------------------------------------------------------------------
if [[ $EUID -ne 0 ]] && [[ $JC_TRASH_CLI -ne 0 ]] \
  && type -P trash-put &>/dev/null; then
  # Confirm
  _jc_confirm_proceed() {
    local ANSWER
    read -r -p "Proceed? [y,n] " ANSWER
    if [[ "$ANSWER" != "y" ]]; then
      return 1
    fi
    return 0
  }

  # Display the trash size
  _jc_trash_size() {
    awk '{sum += $1} END {print sum}' <(command trash-list --size 2>/dev/null)
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

      size=$(command du -s "$arg" | awk '{print $1}')
      total_files_size=$((total_files_size + size))

      count=$(command find "$arg" -type f -o -type l | command wc -l)
      total_files=$((total_files + count))

      command find "$arg" -type f -o -type l
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

  _jc_trash_empty_wrapper() {
    command trash-list --size | command sort
    local ANSWER
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

  alias trash-empty=_jc_trash_empty_wrapper
  alias trash-rm=_jc_trash_put_wrapper
  alias trash-put=_jc_trash_put_wrapper
  alias rm=_jc_trash_put_wrapper
  alias real-rm='command rm -I'
else
  alias rm='rm -I'
  alias real-rm=rm
fi

#-------------------------------------------------------------------------------
# Emacs integration
#-------------------------------------------------------------------------------
if [[ "${JC_EMACS_INTEGRATION:-0}" -ne 0 ]]; then
  # vterm
  if [[ "$INSIDE_EMACS" == 'vterm' ]]; then
    # Some of the most useful features in vterm (e.g., directory-tracking and
    # prompt-tracking or message passing) require shell-side configurations. The
    # main goal of these additional functions is to enable the shell to send
    # information to vterm via properly escaped sequences. A function that helps
    # in this task, _jc_vterm_printf, is defined below. This function is widely
    # used throughout this readme.
    _jc_vterm_printf() {
      if [[ -n "$TMUX" ]] \
        && { [[ "${TERM%%-*}" == "tmux" ]] \
          || [[ "${TERM%%-*}" == "screen" ]]; }; then
        # Tell tmux to pass the escape sequences through
        printf "\ePtmux;\e\e]%s\007\e\\" "$1"
      elif [ "${TERM%%-*}" = "screen" ]; then
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$1"
      else
        printf "\e]%s\e\\" "$1"
      fi
    }

    jc-clear() {
      _jc_vterm_printf "51;Evterm-clear-scrollback"
      command tput clear
    }

    alias clear=jc-clear
  fi

  # Eat (Emulate A Terminal)
  # shellcheck disable=SC1091
  if [[ -n "$EAT_SHELL_INTEGRATION_DIR" ]]; then
    source "$EAT_SHELL_INTEGRATION_DIR/bash"
  fi
fi

#-------------------------------------------------------------------------------
# screen
#
# This function starts or attaches to a GNU Screen session when not already
# inside one.
#
# If at least one detached or attached session exists, attach to it.
#
# Otherwise, create a new session. If already running inside a Screen session,
# print a diagnostic message and fail.
#-------------------------------------------------------------------------------
_jc_screen_auto_attach() {
  if [[ -z "${STY}" ]]; then
    if command screen -ls &>/dev/null; then
      command screen -rx
      return $?
    else
      command screen
      return $?
    fi
  else
    printf '%s\n' "Already running inside a GNU Screen session."
    return 1
  fi
}

alias sc='_jc_screen_auto_attach'

#-------------------------------------------------------------------------------
# Restore the last recorded working directory at shell startup and persist
# the current directory on each prompt for reuse by future interactive sessions.
#-------------------------------------------------------------------------------
if [[ $JC_RESTORE_LAST_DIR -ne 0 ]]; then
  _jc_get_lastdir() {
    local lastdir
    if IFS= read -r lastdir <"$JC_RESTORE_LAST_DIR_FILE" 2>/dev/null \
      && [[ -d "$lastdir" ]]; then
      printf "%s\n" "$lastdir"
    else
      return 1
    fi
  }

  _JC_PREVIOUS_LASTDIR=""

  _jc_restore_lastdir() {
    # Do not restore the directory if ncdu_level is defined. This supports the
    # ncdu command-line tool when the user presses 'b' to open a shell,
    # preventing the script from overriding the directory ncdu intends to open.
    if [[ -z "${NCDU_LEVEL+x}" ]]; then
      local lastdir
      if IFS= read -r lastdir <"$JC_RESTORE_LAST_DIR_FILE" 2>/dev/null \
        && [[ -n "$lastdir" && -d "$lastdir" ]]; then
        cd "$lastdir" >/dev/null || return 1
      fi
    fi

    # Initialize the tracking variable to the starting directory
    _JC_PREVIOUS_LASTDIR="$PWD"
  }

  _jc_persist_lastdir() {
    # Compare the current PWD to the shell's last known PWD in memory first
    if [[ "$PWD" == "$_JC_PREVIOUS_LASTDIR" ]]; then
      return 0
    fi

    # Remove comment
    _JC_PREVIOUS_LASTDIR="$PWD"
    printf "%s\n" "$PWD" >"$JC_RESTORE_LAST_DIR_FILE"
  }

  _jc_restore_lastdir

  if [[ -z "$PROMPT_COMMAND" ]]; then
    PROMPT_COMMAND="_jc_persist_lastdir"
  else
    PROMPT_COMMAND="_jc_persist_lastdir; $PROMPT_COMMAND"
  fi
fi

#-------------------------------------------------------------------------------
# History
#-------------------------------------------------------------------------------

# 'ignoreboth' combines 'ignorespace' (commands starting with space) and
# 'ignoredups' (consecutive duplicates).
# 'erasedups' removes older instances of the same command to keep the list
# unique.
# NOTE: If you want to record absolutely every keystroke (including mistakes
# and duplicates), set this to an empty string.
HISTCONTROL=ignoredups

# Append to the history file, do not overwrite it.
shopt -s histappend

# Save multi-line commands as a single history entry.
shopt -s cmdhist

# Save multi-line commands with embedded newlines instead of semicolons.
shopt -s lithist

# History Option 1:
# -----------------
# Why Option 1 (history -a; history -n) is superior:
# - Performance: It appends only new commands to disk (-a) and reads only new
#   lines from disk (-n) into your current memory. It is fast and efficient.
# - Stability: It preserves your current session's command list. You can see what
#   you typed in this terminal versus what came from others.
#
# shopt -s histappend executes only once, at the very end of your session when
# you close the terminal or type exit.
# shopt -s histappend

# Enable appending to the history file, rather than overwriting it. Append new
# commands to history, clear in-memory history, reload from file, and preserve
# existing PROMPT_COMMAND:
#
if [[ -z "$PROMPT_COMMAND" ]]; then
  PROMPT_COMMAND="_jc_ps1_update; history -a"
else
  PROMPT_COMMAND="_jc_ps1_update; history -a; $PROMPT_COMMAND"
fi

# History Option 2:
# - Destructive: history -c clears your current session's memory entirely.
# - Slow: history -r re-reads the entire history file from disk every time you
#   press Enter. As your history grows to 100,000+ lines, this causes noticeable
#   lag.
# - Context Loss: Because it clears memory, you lose the distinction between
#   "what I just typed in this specific window" and "what I typed in another
#   window 5 seconds ago."
# PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

#-------------------------------------------------------------------------------
# Local bashrc
#-------------------------------------------------------------------------------
if [[ -r ~/.bashrc-after.local ]]; then
  # shellcheck disable=SC1090
  source ~/.bashrc-after.local
fi
