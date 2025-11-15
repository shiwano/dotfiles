bindkey -e

# Envs -------------------------------------------------------------------------

if [ -n "$TMUX" ]; then
	export TERM=tmux-256color
else
	export TERM=xterm-256color
fi

export LANG=ja_JP.UTF-8
export XDG_CONFIG_HOME=$HOME/.config
export LS_COLORS='di=01;36'

export GOPATH=$HOME/code
export CLAUDE_CONFIG_DIR=$HOME/.config/claude

if command -v brew >/dev/null 2>&1; then
	export BREW_PREFIX=$(brew --prefix)
else
	export BREW_PREFIX='/nonexistent'
fi

# Completions ------------------------------------------------------------------

# Limit completion suggestions for make to only target names
zstyle ':completion:*:*:make:*' tag-order 'targets'

# Define command lookup paths for sudo completion
zstyle ':completion:*:sudo:*' command-path $BREW_PREFIX/bin /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# Set color for file list completion like ls
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# If you receive "zsh compinit: insecure directories" warnings when attempting
# to load these completions, you may need to run these commands:
#  chmod go-w '/opt/homebrew/share'
#  chmod -R go-w '/opt/homebrew/share/zsh'
if [ -d $BREW_PREFIX/share/zsh-completions ]; then
	FPATH=$BREW_PREFIX/share/zsh-completions:$FPATH
fi

autoload -Uz compinit
compinit

if command -v jj >/dev/null 2>&1; then
	source <(jj util completion zsh)
fi

if [ -d $BREW_PREFIX/Caskroom/google-cloud-sdk ]; then
	. "$BREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
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

if command -v mise >/dev/null 2>&1; then
	eval "$(mise activate zsh)"
fi

# Nix --------------------------------------------------------------------------

if [ -e "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]; then
	. "${HOME}/.nix-profile/etc/profile.d/nix.sh"
fi

# fzf --------------------------------------------------------------------------

if command -v fzf >/dev/null 2>&1; then
	export FZF_DEFAULT_OPTS="--exact --ansi --cycle --filepath-word --exit-0 \
		--preview='fzf-preview file {}' \
		--layout=reverse \
		--marker='X' \
		--history-size=5000 \
		--tiebreak=index \
		--highlight-line \
		--info=inline-right \
		--ansi \
		--layout=reverse \
		--border=none \
		--color=bg+:#283457 \
		--color=bg:#191a22 \
		--color=border:#27a1b9 \
		--color=fg:#c0caf5 \
		--color=gutter:#16161e \
		--color=header:#ff9e64 \
		--color=hl+:#2ac3de \
		--color=hl:#2ac3de \
		--color=info:#545c7e \
		--color=marker:#ff007c \
		--color=pointer:#ff007c \
		--color=prompt:#2ac3de \
		--color=query:#c0caf5:regular \
		--color=scrollbar:#27a1b9 \
		--color=separator:#ff9e64 \
		--color=spinner:#ff007c \
		--bind=tab:down \
		--bind=shift-tab:up \
		--bind=ctrl-a:select-all \
		--bind=ctrl-l:toggle \
		--bind=ctrl-h:toggle \
		--bind=ctrl-w:backward-kill-word \
		--bind=up:preview-page-up \
		--bind=down:preview-page-down \
		--bind=ctrl-u:half-page-up \
		--bind=ctrl-d:half-page-down"
	export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --sort=path \
		-g '!**/.DS_Store' \
		-g '!**/node_modules' \
		-g '!**/code/pkg/mod' \
		-g '!**/code/pkg/sumdb' \
		-g '!**/__pycache__' \
		-g '!**/.pub-cache' \
		-g '!**/.bundle' \
		-g '!**/.android' \
		-g '!**/.cocoapods' \
		-g '!**/.gradle' \
		-g '!**/.zsh_sessions' \
		-g '!**/.claude' \
		-g '!**/.dropbox' \
		-g '!**/.ssh' \
		-g '!**/.atlas' \
		-g '!**/.cache' \
		-g '!**/.dart*' \
		-g '!**/.local' \
		-g '!**/.docker' \
		-g '!**/.npm' \
		-g '!**/.m2/repository' \
		-g '!**/.config/**/logs' \
		-g '!**/.config/**/undo' \
		-g '!**/swiftpm/cache' \
		-g '!**/.Trash' \
		-g '!**/.git'"
fi

# Android Studio and Android SDK -----------------------------------------------

if [ -d '/Applications/Android Studio.app/Contents/jre/Contents/Home' ]; then
	export JAVA_HOME='/Applications/Android Studio.app/Contents/jre/Contents/Home'
	export PATH=$JAVA_HOME/bin:$PATH
fi

if [ -d "$HOME/Library/Android/sdk" ]; then
	export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
fi

# Neovim -----------------------------------------------------------------------

if command -v nvim >/dev/null 2>&1; then
	if [ -n "${NVIM:-}" ]; then
		alias vi='echo "already open nvim"'
		alias vim='echo "already open nvim"'
		alias nvim='echo "already open nvim"'
	else
		alias vi='nvim'
		alias vim='nvim'
	fi
	alias vimdiff='nvim -d'
	export EDITOR='nvim'
else
	export EDITOR='vi'
fi

# ssh-key ----------------------------------------------------------------------

_ssh-add-key() {
  local key_path="$HOME/.ssh/id_rsa"
  if [ ! -f "$key_path" ]; then
    return 0
  fi

  if ! pgrep -u "$USER" ssh-agent >/dev/null; then
    echo "ssh-agent not running. Start ssh-agent? [y/n]"
    read -r ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      eval "$(ssh-agent -s)" >/dev/null
    else
      return 0
    fi
  fi

  if ssh-add -l 2>/dev/null | grep -q "$key_path"; then
    return 0
  fi

	ssh-add "$key_path"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _ssh-add-key

# Functions --------------------------------------------------------------------

vcs-move-to-repo() {
	FZF_PROMPT='MoveTo> ' vcs-select-repo | { read -r s && [ -n "$s" ] && cd "$s"; }
}

vcs-edit-changed-files() {
	local files=""
	if jj root >/dev/null 2>&1; then
		files="$(jj status --no-pager | grep -E '^\w ' | grep -v -E '^D ')"
	else
		files="$(git status -s -u --no-renames | grep -v -E '^D ')"
	fi
	if [ -z "$files" ]; then
		util-edit-selected-files
	else
		_edit-files "$(FZF_PROMPT='Edit> ' vcs-select-changed-files $1)"
	fi
}

util-edit-selected-files() {
	_edit-files "$(FZF_PROMPT='Edit> ' util-select-files $1)"
}

util-edit-grep-results() {
	_edit-files "$(FZF_PROMPT='Edit> ' util-select-grep-results $1)"
}

util-select-history() {
	BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt 'History> ' --preview="")
	CURSOR=$#BUFFER
}

util-remove-history() {
	local selected
	selected=$(history -n -r 1 | fzf --no-sort +m --prompt 'Remove History> ' --preview="")
	if [ -z "$selected" ]; then
		return 0
	fi
	local HISTORY_IGNORE="${(b)selected}"
	fc -W
	fc -p $HISTFILE $HISTSIZE $SAVEHIST
}

_edit-files() {
	if [ "$(echo "$1" | wc -l)" -eq 1 ]; then
		file=$(echo "$1" | awk -F: '{print $1}')
		print -s "vi $file" && fc -AI
	fi
	util-edit-files "$1"
}

# Aliases ----------------------------------------------------------------------

alias ls='ls --color=auto'
alias ll='ls -l --block-size=KB'
alias la='ls -A'
alias lal='ls -l -A --block-size=KB'
alias authorize-shiwano='curl https://github.com/shiwano.keys >> ~/.ssh/authorized_keys'
alias lsof-listen='lsof -i -P | grep "LISTEN"'
alias reload-shell='exec $SHELL -l'

alias s='vcs-status'
alias b='vcs-switch-branch'
alias r='vcs-restore-files'
alias t='vcs-stash-files'
alias g='vcs-move-to-repo'
alias v='vcs-edit-changed-files'
alias vv='util-edit-selected-files'
alias a='git-add-files'
alias u='git-unstage-files'
alias mt='git-mergetool-file'
alias gg='util-edit-grep-results'

autoload zmv
alias zmv='noglob zmv -W'
alias zcp='noglob zmv -C'
alias zln='noglob zmv -L'
alias zsy='noglob zmv -Ls'

if command -v tmux >/dev/null 2>&1; then
	if [ -z "$TMUX" ]; then
		alias tmux='tmux new-session -A -s main'
	fi
fi

if command -v docker >/dev/null 2>&1; then
	alias docker-rm-all='docker rm $(docker ps -a -q)'
	alias docker-rmi-all='docker rmi $(docker images -q)'
	alias docker-rm-volumes-all='docker volume rm $(docker volume ls -qf dangling=true)'
	alias docker-run-sh='docker run -it --entrypoint sh'
fi

if command -v bazelisk >/dev/null 2>&1; then
	alias bazel='bazelisk'
fi

if command -v ibazel >/dev/null 2>&1; then
	alias ibazel-go-test='ibazel --run_output_interactive=false -nolive_reload test :go_default_test'
fi

if command -v bat >/dev/null 2>&1; then
	alias cat='bat'
fi

if ! command -v pbcopy >/dev/null 2>&1; then
	if command -v xsel >/dev/null 2>&1; then
		alias pbcopy='xsel --clipboard --input'
		alias pbpaste='xsel --clipboard --output'
	elif command -v xclip >/dev/null 2>&1; then
		alias pbcopy='xclip -selection clipboard'
		alias pbpaste='xclip -selection clipboard -o'
	else
		alias pbcopy='echo "pbcopy: command not found" >&2'
		alias pbpaste='echo "pbpaste: command not found" >&2'
	fi
fi

# Prompt -----------------------------------------------------------------------

setopt prompt_subst
ZLE_RPROMPT_INDENT=0

_prompt-pwd() {
	local dir="$(print -P '%~')"
	dir="${dir%/}" # Remove trailing slash
	local icon_repo=$'\Uea62 '

	if [[ $dir =~ '^~\/code\/src\/[^/]+\/[^/]+\/(.*)$' ]]; then
		echo "$icon_repo${match[1]}"
	elif [[ $dir =~ '^~\/(dotfiles\/?.*)$' ]]; then
		echo "$icon_repo${match[1]}"
	else
		echo "$dir"
	fi
}

_prompt-vcs-branch() {
	if jj root >/dev/null 2>&1; then
		local bookmarks="$(jj log -r @ --no-graph -T 'bookmarks' 2>/dev/null)"
		if [ -n "$bookmarks" ] && [ "$bookmarks" != "" ]; then
			local icon_jj_branch=$'\Ue0a0 '
			echo "$icon_jj_branch$bookmarks"
		else
			local change_id="$(jj log -r @ --no-graph -T 'change_id.short()' 2>/dev/null)"
			if [ -n "$change_id" ]; then
				local icon_jj_branch=$'\Ue0a0 '
				echo "$icon_jj_branch@$change_id"
			else
				echo ''
			fi
		fi
	else
		local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
		if [ -n "$branch" ]; then
			local icon_git_branch=$'\Ue0a0 '
			echo "$icon_git_branch$branch"
		else
			echo ''
		fi
	fi
}

() {
	local icon_cat=$'\Uf011b '
	local icon_key=$'\Uf805 '
	local icon_folder=$'\Uf450 '
	local icon_network=$'\Ufbf1 '
	local icon_vim=$'\Ue62b '
	local icon_clock=$'\Uf017 '
	local left_sep=$'\Ue0b0 '

	local primary_bg="#7AA2F7"
	local primary_fg="#000000"
	local secondary_bg="#3B4261"
	local secondary_fg="#7AA2F7"
	if [ -n "${NVIM:-}" ]; then
		primary_bg="#73DACA"
		secondary_fg="#73DACA"
	elif [ -n "${REMOTEHOST}${SSH_CONNECTION}" ]; then
		primary_bg="#FF9E64"
		secondary_fg="#FF9E64"
	fi

	local prompt_face
	if [ -n "${NVIM:-}" ]; then
		prompt_face="${icon_vim}"
	elif [ "${UID}" -eq 0 ]; then
		prompt_face="${icon_key}"
	else
		prompt_face="${icon_cat}"
	fi

	local left_segment=""
	if [ -n "${REMOTEHOST}${SSH_CONNECTION}" ]; then
		left_segment+="%K{$primary_bg}%F{$primary_fg} ${icon_network}${HOST%%.*} %f%k"
	else
		left_segment+="%K{$primary_bg}%F{$primary_fg} %B${prompt_face}%b%f%k"
	fi
	left_segment+="%K{$secondary_bg}%F{$primary_bg}${left_sep}%f%k"
	left_segment+="%K{$secondary_bg}%F{$secondary_fg}% "'$(_prompt-pwd)'" %f%k"
	left_segment+="%F{$secondary_bg}${left_sep}%f"

	local right_segment=""
	right_segment+="%F{$secondary_fg} "'$(_prompt-vcs-branch)'" %f"

	PROMPT="${left_segment}"
	RPROMPT="${right_segment}"
	PROMPT2="%F{$secondary_fg} > %f "
	SPROMPT="%F{$secondary_fg}%r is correct? [n,y,a,e]: %f "
}

# History ----------------------------------------------------------------------

HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

zle -N util-select-history
bindkey '^r' util-select-history

_accept-line-with-typo-correction() {
	if [[ "$BUFFER" =~ ^gti\  ]]; then
		BUFFER="${BUFFER/gti /git }"
	fi
	zle accept-line
}

zle -N _accept-line-with-typo-correction
bindkey "^M" _accept-line-with-typo-correction

# Utilities --------------------------------------------------------------------

# シェルのプロセスごとに履歴を共有
setopt share_history

# 余分なスペースを削除してヒストリに記録する
setopt hist_reduce_blanks

# ヒストリにhistoryコマンドを記録しない
setopt hist_no_store

# ヒストリを呼び出してから実行する間に一旦編集できる状態になる
setopt hist_verify

# 行頭がスペースで始まるコマンドラインはヒストリに記録しない
setopt hist_ignore_space

# 直前と同じコマンドラインはヒストリに追加しない
setopt hist_ignore_dups

# 重複したヒストリは追加しない
setopt hist_ignore_all_dups

# 補完するかの質問は画面を超える時にのみに行う｡
LISTMAX=0

# cdのタイミングで自動的にpushd
setopt auto_pushd

# 複数の zsh を同時に使う時など history ファイルに上書きせず追加
setopt append_history

# 補完候補が複数ある時に、一覧表示
setopt auto_list

# auto_list の補完候補一覧で、ls -F のようにファイルの種別をマーク表示しない
setopt no_list_types

# 補完結果をできるだけ詰める
setopt list_packed

# 補完キー（Tab, Ctrl+I) を連打するだけで順に補完候補を自動で補完
setopt auto_menu

# カッコの対応などを自動的に補完
setopt auto_param_keys

# ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt auto_param_slash

# ビープ音を鳴らさないようにする
setopt no_beep

# コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt magic_equal_subst

# ファイル名の展開でディレクトリにマッチした場合末尾に / を付加する
setopt mark_dirs

# 8 ビット目を通すようになり、日本語のファイル名を表示可能
setopt print_eight_bit

# Ctrl+wで､直前の/までを削除する｡
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# cd をしたときにlsを実行する
chpwd() { ls }

# ディレクトリ名だけで､ディレクトリの移動をする｡
setopt auto_cd

# C-s, C-qを無効にする。
setopt no_flow_control

# Change open files limit and user processes limit.
# See: https://gist.github.com/tombigel/d503800a282fcadbee14b537735d202c
ulimit -n 200000
ulimit -u 2000

# Disable C-d to exit shell and C-z to suspend
_do_nothing() {}
zle -N _do_nothing
bindkey "^D" _do_nothing
setopt IGNORE_EOF
stty susp undef

# Integrations -----------------------------------------------------------------

if command -v direnv >/dev/null 2>&1; then
	eval "$(direnv hook zsh)"
fi

if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
	. "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
fi

if [ -f ~/.zshrc.local ]; then
	. ~/.zshrc.local
fi

typeset -U path PATH # Remove duplicated PATHs.

export PATH=$HOME/dotfiles/bin:$PATH
