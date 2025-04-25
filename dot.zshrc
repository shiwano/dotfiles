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

if command -v brew >/dev/null 2>&1; then
	export BREW_PREFIX=$(brew --prefix)
else
	export BREW_PREFIX='/nonexistent'
fi

# Completions ------------------------------------------------------------------

zstyle ':completion:*:*:make:*' tag-order 'targets'

# If you receive "zsh compinit: insecure directories" warnings when attempting
# to load these completions, you may need to run these commands:
#  chmod go-w '/opt/homebrew/share'
#  chmod -R go-w '/opt/homebrew/share/zsh'
if [ -d $BREW_PREFIX/share/zsh-completions ]; then
	FPATH=$BREW_PREFIX/share/zsh-completions:$FPATH
fi

autoload -Uz compinit
compinit

if [ -d $BREW_PREFIX/Caskroom/google-cloud-sdk ]; then
	source "$BREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
fi

# PATH -------------------------------------------------------------------------

export PATH=$HOME/bin:$BREW_PREFIX/bin:$BREW_PREFIX/sbin:$GOPATH/bin:$PATH
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

if [ -d ${HOME}/.local ] ; then
	export PATH="$HOME/.local/bin:$PATH"
fi

if [ -d ${HOME}/.pub-cache ] ; then
	export PATH="$HOME/.pub-cache/bin:$PATH"
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
		-g '!**/.asdf' \
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
else
	if [ -d $BREW_PREFIX/opt/openjdk ]; then
		export JAVA_HOME="$BREW_PREFIX/opt/openjdk"
		export PATH=$JAVA_HOME/bin:$PATH
	fi
fi

if [ -d "$HOME/Library/Android/sdk" ]; then
	export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
fi

# Neovim -----------------------------------------------------------------------

if command -v nvim >/dev/null 2>&1; then
	if [ -n "${NVIM}" ]; then
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

# Functions --------------------------------------------------------------------

compress() {
	if [ -f $1 ] ; then
		tar -zcvf $1.tar.gz $1
	elif [ -d $1 ] ; then
		tar -zcvf $1.tar.gz $1
	else
		echo "'$1' is not a valid file or directory!"
	fi
}

extract() {
	if [ -f $1 ] ; then
		case $1 in
			*.tar.bz2)   tar xvjf $1    ;;
			*.tar.gz)    tar xvzf $1    ;;
			*.tar.xz)    tar xvJf $1    ;;
			*.bz2)       bunzip2 $1     ;;
			*.rar)       unrar x $1     ;;
			*.gz)        gunzip $1      ;;
			*.tar)       tar xvf $1     ;;
			*.tbz2)      tar xvjf $1    ;;
			*.tgz)       tar xvzf $1    ;;
			*.zip)       unzip $1       ;;
			*.Z)         uncompress $1  ;;
			*.7z)        7z x $1        ;;
			*.lzma)      lzma -dv $1    ;;
			*.xz)        xz -dv $1      ;;
			*)           echo "don't know how to extract '$1'..." ;;
		esac
	else
		echo "'$1' is not a valid file!"
	fi
}

static-httpd() {
	if command -v python >/dev/null 2>&1; then
		if python -V 2>&1 | grep -qm1 'Python 3\.'; then
			python -m http.server ${1-5000}
		else
			python -m SimpleHTTPServer ${1-5000}
		fi
	elif command -v python3 >/dev/null 2>&1; then
		python3 -m http.server ${1-5000}
	fi
}

move-to-git-repository() {
	local items="$(echo 'dotfiles'; ghq list)"
	[ -z "$items" ] && return
	local s="$(echo -e $items | fzf --preview '' --prompt 'MoveTo> ')"
	[ -z "$s" ] && return
	[ "$s" = "dotfiles" ] && cd ~/dotfiles || cd $(ghq root)/$s
}

edit-git-grepped-files() {
	local prompt="$(prompt-pwd)/"
	local search=$1
	[ -z "$search" ] && return
	local files="$(git grep -n --color=always "$search")"
	[ -z "$files" ] && return
	local s="$(echo -e $files | fzf -m --preview 'fzf-preview file {}' --prompt $prompt)"
	[ -z "$s" ] && return

	if [ "$(echo "$s" | wc -l)" -eq 1 ]; then
		local file=$(echo "$s" | awk -F ':' '{print $1}')
		local line=$(echo "$s" | awk -F ':' '{print $2}')
		print -s "vi $file" && fc -AI
		vi +"$line" "$file"
	else
		local escaped_s=$(echo "$s" | awk '{gsub("\x27", "\x27\x27")}1')
		vi -c "cexpr '$escaped_s' | copen"
	fi
}

edit-git-files() {
	local prompt="$(prompt-pwd)/"
	local dir=${1-.}
	local files="$(git ls-files $dir)"
	[ -z "$files" ] && return
	local s="$(echo -e $files | fzf -m --prompt $prompt)"
	[ -z "$s" ] && return

	if [ "$(echo "$s" | wc -l)" -eq 1 ]; then
		print -s "vi $s" && fc -AI
		vi $s
	else
		local escaped=$(echo "$s" | awk '{gsub("\x27", "\x27\x27"); print $0 ":1:1"}')
		vi -c "cexpr '$escaped' | copen"
	fi
}

edit-git-changed-files() {
	local prompt="$(prompt-pwd)/"
	local files="$(git status -s -u --no-renames | grep -v -E '^D ')"
	if [ -z "$files" ]; then
		edit-git-files
		return
	fi
	local s="$(echo -e $files | fzf -m --preview 'fzf-preview diff $(echo {} | cut -c4-)'	--prompt $prompt | cut -c4-)"
	[ -z "$s" ] && return

	if [ "$(echo "$s" | wc -l)" -eq 1 ]; then
		print -s "vi $s" && fc -AI
		vi $s
	else
		local escaped=$(echo "$s" | awk '{gsub("\x27", "\x27\x27"); print $0 ":1:1"}')
		vi -c "cexpr '$escaped' | copen"
	fi
}

copy-file-paths-to-clipboard() {
	local prompt="$(prompt-pwd)/"
	local dir=${1-}
	local files="$(rg --files --hidden --follow --sort path -g '!**/.git' $dir 2>/dev/null)"
	[ -z "$files" ] && return
	local s="$(echo -e $files | fzf -m --prompt $prompt)"
	[ -z "$s" ] && return
	printf "%s" "$s" | pbcopy
	echo -e "\e[36mCopied to clipboard:\e[0m\n$s"
}

copy-changed-file-paths-to-clipboard() {
	local prompt="$(prompt-pwd)/"
	local files="$(git status -s -u --no-renames | grep -v -E '^D ')"
	[ -z "$files" ] && return
	local s="$(echo -e $files | fzf -m --preview 'fzf-preview diff $(echo {} | cut -c4-)' --prompt $prompt | cut -c4-)"
	[ -z "$s" ] && return
	printf "%s" "$s" | pbcopy
	echo -e "\e[36mCopied to clipboard:\e[0m\n$s"
}

copy-image-paths-to-clipboard() {
	local prompt="$(prompt-pwd)/"
	local dir=${1-}
	local files="$(rg --files --hidden --follow --sort path -g '!**/.git' -g '*.{png,jpg,jpeg,gif,svg,bmp,tiff,webp}' $dir 2>/dev/null)"
	[ -z "$files" ] && return
	local s="$(echo -e $files | fzf -m --prompt $prompt)"
	[ -z "$s" ] && return
	printf "%s" "$s" | pbcopy
	echo -e "\e[36mCopied to clipboard:\e[0m\n$s"
}

git-switch-branch() {
	local branches=$(git mru | tac)
	[ -z "$branches" ] && return
	local s="$(echo -e $branches | fzf --no-sort --preview '' --prompt 'GitSwitch> ' | cut -d' ' -f1)"
	[ -z "$s" ] && return
	git switch $s
}

git-add-files() {
	local prompt="$(prompt-pwd)/"
	local files="$(git status -s -u --no-renames | grep -v -E "^[MAD] ")"
	[ -z "$files" ] && return
	local s="$(echo -e $files | fzf -m --preview 'fzf-preview diff $(echo {} | cut -c4-)' --prompt $prompt | cut -c4-)"
	[ -z "$s" ] && return
	echo -e $s | tr '\n' ' ' | xargs -n1 git add
	git status
}

git-restore-files() {
	local prompt="$(prompt-pwd)/"
	local files="$(git status -s -u --no-renames | grep -v -E "^(M|A|D|UU|AA|DD|DU|UD) " | grep -v -E "^\?\? ")"
	[ -z "$files" ] && return
	local s="$(echo -e $files | fzf -m --preview 'fzf-preview diff $(echo {} | cut -c4-)' --prompt $prompt | cut -c4-)"
	[ -z "$s" ] && return
	echo -e $s | tr '\n' ' ' | xargs -n1 git restore
	git status
}

git-unstage-files() {
	local prompt="$(prompt-pwd)/"
	local files="$(git status -s -u --no-renames | grep -E "^(M|A|D|UU|AA|DD|DU|UD) ")"
	[ -z "$files" ] && return
	local s="$(echo -e $files | fzf -m --preview 'fzf-preview diff $(echo {} | cut -c4-)' --prompt $prompt | cut -c4-)"
	[ -z "$s" ] && return
	echo -e $s | tr '\n' ' ' | xargs -n1 git reset HEAD
	git status
}

git-mergetool-file() {
	local prompt="$(prompt-pwd)/"
	local files="$(git status -s -u --no-renames | grep -E "^(UU|AA|DD) ")"
	[ -z "$files" ] && return
	local s="$(echo -e $files | fzf --preview 'fzf-preview diff $(echo {} | cut -c4-)' --prompt $prompt | cut -c4-)"
	[ -z "$s" ] && return
	print -s "git mergetool $s" && fc -AI
	git mergetool $s
	git status
}

git-stash-files() {
	local prompt="$(prompt-pwd)/"
	local files="$(git status -s -u --no-renames)"
	[ -z "$files" ] && return
	local s="$(echo -e "$files" | fzf -m --preview 'fzf-preview diff $(echo {} | cut -c4-)' --prompt $prompt | cut -c4-)"
	[ -z "$s" ] && return

	local new_files=()
	local existing_files=()
	while IFS= read -r file; do
		if git ls-files --error-unmatch "$file" > /dev/null 2>&1; then
			existing_files+=("$file")
		else
			new_files+=("$file")
		fi
	done <<< "$s"

	if [ ${#new_files[@]} -ne 0 ]; then
		git add "${new_files[@]}"
	fi
	git stash push -- "${existing_files[@]}" "${new_files[@]}"
	git status
}

select-history() {
	BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt 'History> ' --preview="")
	CURSOR=$#BUFFER
}

remove-last-command() {
	local last_command=$(fc -ln -1)
	fc -p "$last_command"
}

local-ip-address() {
	ip addr show | grep -o 'inet [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | grep -v '127.0.0.1'
}

ssh-add-key() {
  local key_path="$HOME/.ssh/id_rsa"
  if [ ! -f "$key_path" ]; then
    echo "ssh key not found: $key_path"
    return 1
  fi
  if ssh-add -l 2>/dev/null | grep -q "$key_path"; then
    echo "ssh key already added: $key_path"
    return
  fi
	ssh-add "$key_path"
}

# Aliases ----------------------------------------------------------------------

alias ls='ls --color=auto'
alias ll='ls -l --block-size=KB'
alias la='ls -A'
alias lal='ls -l -A --block-size=KB'
alias authorize-shiwano='curl https://github.com/shiwano.keys >> ~/.ssh/authorized_keys'
alias lsof-listen='lsof -i -P | grep "LISTEN"'
alias reload-shell='exec $SHELL -l'

alias a='git-add-files'
alias b='git-switch-branch'
alias s='git status'
alias u='git-unstage-files'
alias r='git-restore-files' # hide 'r' which is zsh's built-in command
alias t='git-stash-files'
alias g='move-to-git-repository'
alias v='edit-git-changed-files'
alias vv='edit-git-files'
alias gg='edit-git-grepped-files'
alias mt='git-mergetool-file'
alias files='copy-file-paths-to-clipboard'
alias files-changed='copy-changed-file-paths-to-clipboard'
alias images='copy-image-paths-to-clipboard'

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

if command -v go >/dev/null 2>&1; then
	alias go-build-all='go test -run=^$ ./... 1>/dev/null'
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

prompt-pwd() {
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

prompt-git-branch() {
	local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
	if [ -n "$branch" ]; then
		local icon_git_branch=$'\Ue0a0 '
		echo "$icon_git_branch$branch"
	else
		echo ''
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
	if [ -n "${NVIM}" ]; then
		primary_bg="#73DACA"
		secondary_fg="#73DACA"
	elif [ -n "${REMOTEHOST}${SSH_CONNECTION}" ]; then
		primary_bg="#FF9E64"
		secondary_fg="#FF9E64"
	fi

	local prompt_face
	if [ -n "${NVIM}" ]; then
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
	left_segment+="%K{$secondary_bg}%F{$secondary_fg}% "'$(prompt-pwd)'" %f%k"
	left_segment+="%F{$secondary_bg}${left_sep}%f"

	local right_segment=""
	right_segment+="%F{$secondary_fg} "'$(prompt-git-branch)'" %f"

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

zle -N select-history
bindkey '^r' select-history

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

# sudo でも補完の対象
zstyle ':completion:*:sudo:*' command-path $BREW_PREFIX/bin /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

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

# ファイルリスト補完でもlsと同様に色をつける｡
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

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

# Disable C-d to exit shell
_do_nothing() {}
zle -N _do_nothing
bindkey "^D" _do_nothing
setopt IGNORE_EOF

# Includes ---------------------------------------------------------------------

if command -v direnv >/dev/null 2>&1; then
	eval "$(direnv hook zsh)"
fi

if [ -e $BREW_PREFIX/opt/asdf/libexec/asdf.sh ]; then
	. $BREW_PREFIX/opt/asdf/libexec/asdf.sh
fi

if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
	. $HOME/.nix-profile/etc/profile.d/nix.sh;
fi

if [ -f ~/.zshrc.local ]; then
	. ~/.zshrc.local
fi

typeset -U path PATH # Remove duplicated PATHs.
