# Envs -------------------------------------------------------------------------

export LANG=ja_JP.UTF-8
export XDG_CONFIG_HOME=$HOME/.config

export GOPATH=$HOME/code
export CLAUDE_CONFIG_DIR=$HOME/.config/claude

if command -v brew >/dev/null 2>&1; then
	export BREW_PREFIX=$(brew --prefix)
else
	export BREW_PREFIX='/nonexistent'
fi

# PATH -------------------------------------------------------------------------

export PATH=$BREW_PREFIX/bin:$BREW_PREFIX/sbin:$GOPATH/bin:$PATH
export MANPATH=$BREW_PREFIX/share/man:$BREW_PREFIX/man:/usr/share/man

if [ -d $BREW_PREFIX/opt/coreutils ]; then
	export PATH="$BREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
	export MANPATH="$BREW_PREFIX/opt/coreutils/libexec/gnuman:$MANPATH"
fi

if [ -d $BREW_PREFIX/opt/gnu-sed ]; then
	export PATH="$BREW_PREFIX/opt/gnu-sed/libexec/gnubin:$PATH"
	export MANPATH="$BREW_PREFIX/opt/gnu-sed/libexec/gnuman:$MANPATH"
fi

if [ -d $BREW_PREFIX/opt/gawk ]; then
	export PATH="$BREW_PREFIX/opt/gawk/libexec/gnubin:$PATH"
	export MANPATH="$BREW_PREFIX/opt/gawk/libexec/gnuman:$MANPATH"
fi

if [ -d ${HOME}/.local/bin ] ; then
	export PATH="$HOME/.local/bin:$PATH"
fi

# mise -------------------------------------------------------------------------

if [ -d "$HOME/.local/share/mise/shims" ]; then
	export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

# Nix --------------------------------------------------------------------------

if [ -e "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]; then
	. "${HOME}/.nix-profile/etc/profile.d/nix.sh"
fi

# Neovim -----------------------------------------------------------------------

if command -v nvim >/dev/null 2>&1; then
	export EDITOR='nvim'
else
	export EDITOR='vi'
fi

# PATH deduplication -----------------------------------------------------------

typeset -U path PATH
export PATH=$HOME/dotfiles/bin:$PATH
