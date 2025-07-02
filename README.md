# jc-dotfiles - James Cherti's Dotfiles

This repository houses James Cherti's dotfiles and configuration scripts:
* **Shell Configuration (.bashrc, .profile, and .bash_profile):** Optimized Bash shell settings for efficient command execution and interactive sessions.
* **Terminal Multiplexer (.tmux.conf):** Configuration for Tmux, enhancing terminal session management and productivity.
* **Readline configuration (.inputrc)**: Inputrc configuration that also allows using Alt-h, Alt-j, Alt-k, and Alt-l as a way to move the cursor.
* **Other:** .gitconfig, ranger, .fdignore, .wcalcrc, mpv, picom, feh, and various scripts and configuration files for managing system settings, aliases, and more.

Here are additional dotfiles and configuration files maintained by the same author:
- [jc-dotfiles @GitHub](https://github.com/jamescherti/jc-dotfiles): A collection of UNIX/Linux configuration files. You can either install them directly or use them as inspiration your own dotfiles.
- [bash-stdops @GitHub](https://github.com/jamescherti/bash-stdops): A collection of Bash helper shell scripts.
- [jc-gnome-settings](https://github.com/jamescherti/jc-gnome-settings): GNOME customizations that can be applied programmatically.
- [jc-firefox-settings @GitHub](https://github.com/jamescherti/jc-firefox-settings): Provides the user.js file, which holds settings to customize the Firefox web browser to enhance the user experience and security.
- [jc-gentoo-portage @GitHub](https://github.com/jamescherti/jc-gentoo-portage): Provides configuration files for customizing Gentoo Linux Portage, including package management, USE flags, and system-wide settings.
- [jc-xfce-settings](https://github.com/jamescherti/jc-xfce-settings): GNOME customizations that can be applied programmatically.
- [watch-xfce-xfconf](https://github.com/jamescherti/watch-xfce-xfconf/): A command-line tool that can be used to configure XFCE 4 programmatically using the *xfconf-query* commands displayed when XFCE 4 settings are modified.

## Installation

Here's how to install James Cherti's dotfiles:

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/jamescherti/jc-dotfiles
   ```

2. **Navigate to the jc-dotfiles directory:**

   ```bash
   cd jc-dotfiles
   ```

3. **Install:**

   ```bash
   ./install.sh
   ```

## Usage

### .bashrc

- Tmux/fzf auto complete: Pressing Ctrl-n calls a custom Bash autocomplete function that captures the current tmux scrollback buffer, extracts unique word-like tokens, and presents them via fzf for interactive fuzzy selection. The selected word is then inserted inline at the current cursor position using a readline binding.
- The `.bashrc` file can be extended by adding configurations to `~/.bashrc.local`.
- The `o` alias calls a function that provides a cross-platform way to open files or URLs using the appropriate command for the system. This function opens files or URLs using the appropriate command (`xdg-open` on Linux, `open` on macOS, and `start` on Windows). If more than 7 arguments are passed, the user is prompted for confirmation before proceeding.
  Example usage:
  ```
  o file1.jpg file2.png file3.jpeg
  ```
- Customizations in `.bashrc` to add to `~/.profile.local`:
  ```sh
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
  JC_EMACS_INTEGRATION=1  # Default: 0

  # Display the current Git branch in the shell prompt (PS1)
  JC_PS1_GIT_BRANCH=1  # Default: 0

  # Display the count of unread mails in the shell prompt (PS1)
  JC_PS1_MAILDIR=1  # Default: 0

  # Directory containing the mail (e.g., to "$HOME/Mail")
  JC_PS1_MAILDIR_PATH="$HOME/Mail"
  ```

## License

Distributed under terms of the MIT license.

Copyright (C) 2004-2025 [James Cherti](https://www.jamescherti.com).

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the “Software”), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Links

- [jc-dotfiles @GitHub](https://github.com/jamescherti/jc-dotfiles)

Related articles:
- [Enhancing Git configuration ~/.gitconfig for performance and usability](https://www.jamescherti.com/optimized-git-configuration-for-performance-and-usability/)
