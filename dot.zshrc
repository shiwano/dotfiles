export TERM=xterm-256color
export LANG=ja_JP.UTF-8
export XDG_CONFIG_HOME=$HOME/.config
export LS_COLORS='di=01;36'

export GOPATH=$HOME/code

bindkey -e
bindkey '^]'   vi-find-next-char
bindkey '^[^]' vi-find-prev-char

if command -v brew 2>&1 >/dev/null; then
  export BREW_PREFIX=$(brew --prefix)
else
  export BREW_PREFIX='/usr/local'
fi

# Completions and Site Functions -----------------------------------------------

zstyle ':completion:*:*:make:*' tag-order 'targets'

# If you receive "zsh compinit: insecure directories" warnings when attempting
# to load these completions, you may need to run these commands:
#  chmod go-w '/opt/homebrew/share'
#  chmod -R go-w '/opt/homebrew/share/zsh'
if [ -d $BREW_PREFIX/share/zsh-completions ]; then
  FPATH=$BREW_PREFIX/share/zsh-completions:$FPATH
fi

if [ -d $BREW_PREFIX/share/zsh/site-functions ]; then
  FPATH=$BREW_PREFIX/share/zsh/site-functions:$FPATH
fi

autoload -Uz compinit
compinit

# Envs -------------------------------------------------------------------------

export PATH=$HOME/bin:$BREW_PREFIX/bin:$BREW_PREFIX/sbin:$GOPATH/bin:$PATH
export MANPATH=$BREW_PREFIX/share/man:$BREW_PREFIX/man:/usr/share/man

if [ -d $BREW_PREFIX/Cellar/coreutils ]; then
  export PATH="$BREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
  export MANPATH="$BREW_PREFIX/opt/coreutils/libexec/gnuman:$MANPATH"
fi

if [ -d $BREW_PREFIX/Cellar/gnu-sed ]; then
  export PATH="$BREW_PREFIX/opt/gnu-sed/libexec/gnubin:$PATH"
  export MANPATH="$BREW_PREFIX/opt/gnu-sed/libexec/gnuman:$MANPATH"
fi

if [ -d $BREW_PREFIX/Cellar/openssl ]; then
  export PATH="$BREW_PREFIX/opt/openssl/bin:$PATH"
fi

if [ -d $BREW_PREFIX/Caskroom/google-cloud-sdk ]; then
  source "$BREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
  source "$BREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
fi

if [ -d ${HOME}/.local ] ; then
  export PATH="$HOME/.local/bin:$PATH"
fi

if [ -d ${HOME}/.pub-cache ] ; then
  export PATH="$HOME/.pub-cache/bin:$PATH"
fi

# fzf --------------------------------------------------------------------------

if command -v fzf 2>&1 >/dev/null; then
  export FZF_DEFAULT_OPTS="--exact --ansi --cycle --filepath-word --exit-0 \
    --preview='fzf-preview file {}' \
    --layout=reverse \
    --info hidden \
    --marker='X' \
    --history-size=5000 \
    --tiebreak=index \
    --bind=tab:down \
    --bind=shift-tab:up \
    --bind=ctrl-a:select-all \
    --bind=ctrl-l:toggle \
    --bind=ctrl-h:toggle \
    --bind=ctrl-w:backward-kill-word \
    --bind=ctrl-u:word-rubout \
    --bind=up:preview-page-up \
    --bind=down:preview-page-down \
    --bind=ctrl-u:half-page-up \
    --bind=ctrl-d:half-page-down"
  export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --sort path \
    -g '!**/.git'"
fi

# asdf -------------------------------------------------------------------------

if [ -e $BREW_PREFIX/opt/asdf/libexec/asdf.sh ]; then
  . $BREW_PREFIX/opt/asdf/libexec/asdf.sh
fi

# Nix --------------------------------------------------------------------------

if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
  . $HOME/.nix-profile/etc/profile.d/nix.sh;
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

# Vim --------------------------------------------------------------------------

if command -v nvim 2>&1 >/dev/null; then
  if [ -n "${NVIM}" ]; then
    alias vi='echo "already open nvim"'
    alias vim='echo "already open nvim"'
    alias nvim='echo "already open nvim"'
  else
    alias vi='nvim'
  fi
  alias vimdiff='nvim -d'
  export EDITOR='nvim'
else
  alias vi='vim'
  export EDITOR='vim'
fi

# Functions --------------------------------------------------------------------

function compress {
  if [ -f $1 ] ; then
    tar -zcvf $1.tar.gz $1
  elif [ -d $1 ] ; then
    tar -zcvf $1.tar.gz $1
  else
    echo "'$1' is not a valid file or directory!"
  fi
}

function extract {
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

function static-httpd {
  if command -v python 2>&1 >/dev/null; then
    if python -V 2>&1 | grep -qm1 'Python 3\.'; then
      python -m http.server ${1-5000}
    else
      python -m SimpleHTTPServer ${1-5000}
    fi
  elif command -v python3 2>&1 >/dev/null; then
    python3 -m http.server ${1-5000}
  fi
}

function move-to-ghq-directory {
  local items="$(echo 'dotfiles'; ghq list)"
  local s="$(echo -e $items | fzf --preview '' --prompt 'GitRepos> ')"
  [ -z "$s" ] && return
  [ "$s" = "dotfiles" ] && cd ~/dotfiles || cd $(ghq root)/$s
}

function edit-git-grepped-file {
  local search=$1
  [ -z "$search" ] && return
  local files="$(git grep -n --color=always "$search")"
  local s="$(echo -e $files | fzf -m --preview 'fzf-preview grepped {}' --prompt 'GitFiles> ')"
  [ -z "$s" ] && return
  local escaped_s=$(echo "$s" | awk '{gsub("\x27", "\x27\x27")}1')
  vi -c "cexpr '$escaped_s' | copen"
}

function edit-git-file {
  local dir=${1-.}
  local files="$(git ls-files $dir)"
  local s="$(echo -e $files | fzf --prompt 'GitFiles> ')"
  [ -z "$s" ] && return
  print -s "vi $s" && fc -AI
  vi $s
}

function edit-git-changed-file {
  local files="$(git status -s -u --no-renames | grep -v -E '^D ')"
  if [ -z "$files" ]; then
    edit-git-file
    return
  fi
  local s="$(echo -e $files | fzf --preview 'fzf-preview diff $(echo {} | cut -c4-)'  --prompt 'GitFiles> ' | cut -c4-)"
  [ -z "$s" ] && return
  print -s "vi $s" && fc -AI
  vi $s
}

function copy-file-path-to-clipboard {
  local dir=${1-}
  local files="$(rg --files --hidden --follow --sort path -g '!**/.git' $dir 2>/dev/null)"
  local s="$(echo -e $files | fzf --prompt 'Files> ')"
  [ -z "$s" ] && return
  printf "%s" "$s" | pbcopy
  echo "Copied to clipboard: $s"
}

function copy-changed-file-path-to-clipboard {
  local files="$(git status -s -u --no-renames | grep -v -E '^D ')"
  local s="$(echo -e $files | fzf --preview 'fzf-preview diff $(echo {} | cut -c4-)' --prompt 'GitFiles> ' | cut -c4-)"
  [ -z "$s" ] && return
  printf "%s" "$s" | pbcopy
  echo "Copied to clipboard: $s"
}

function copy-image-path-to-clipboard {
  local dir=${1-}
  local files="$(rg --files --hidden --follow --sort path -g '!**/.git' -g '*.{png,jpg,jpeg,gif,svg,bmp,tiff,webp}' $dir 2>/dev/null)"
  local s="$(echo -e $files | fzf --prompt 'Images> ')"
  [ -z "$s" ] && return
  printf "%s" "$s" | pbcopy
  echo "Copied to clipboard: $s"
}

function switch-git-branch() {
  local branches=$(git mru | tac)
  local s="$(echo -e $branches | fzf --no-sort --preview '' --prompt 'GitBranches> ' | cut -d' ' -f1)"
  [ -z "$s" ] && return
  git switch $s
}

function add-git-files() {
  local files="$(git status -s -u --no-renames | grep -v -E "^M ")"
  [ -z "$files" ] && return
  echo -e $files | fzf -m --preview 'fzf-preview diff $(echo {} | cut -c4-)' --prompt 'GitFiles> ' | cut -c4- | tr '\n' ' ' | xargs -n1 git add && git status
}

function restore-git-files() {
  local files="$(git status -s -u --no-renames | grep -v -E "^[MA] ")"
  [ -z "$files" ] && return
  echo -e $files | fzf -m --preview 'fzf-preview diff $(echo {} | cut -c4-)' --prompt 'GitFiles> ' | cut -c4- | tr '\n' ' ' | xargs -n1 git restore && git status
}

function unstage-git-files() {
  local files="$(git status -s -u --no-renames | grep -E "^[MA] ")"
  [ -z "$files" ] && return
  echo -e $files | fzf -m --preview 'fzf-preview diff $(echo {} | cut -c4-)' --prompt 'GitFiles> ' | cut -c4- | tr '\n' ' ' | xargs -n1 git reset HEAD && git status
}

function select-history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt 'History> ' --preview="")
  CURSOR=$#BUFFER
}

function remove-last-command() {
  local last_command=$(fc -ln -1)
  fc -p $last_command
}

function local-ip-address() {
  ip addr show | grep -o 'inet [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | grep -v '127.0.0.1'
}

function run-n-times() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: run-n-times <times> <command>"
    return 1
  fi
  local times="$1"
  local command="$2"
  if ! echo "$times" | grep -E '^[0-9]+$' > /dev/null; then
    echo "Invalid times. Only numeric values are allowed." "$times"
    return 1
  fi
  for i in $(seq 1 $times); do
    eval $command || { echo "FAILED"; break; }
  done
  echo -e "\e[90mTo run the same command again, use:"
  echo -e "for i in \$(seq 1 $times); do $command || { echo \"FAILED\"; break; }; done\e[0m"
}

# Aliases ----------------------------------------------------------------------

alias ls='ls --color=auto'
alias ll='ls -l --block-size=KB'
alias la='ls -A'
alias lal='ls -l -A --block-size=KB'
alias tmux='tmux-single-session'
alias authorize-shiwano='curl https://github.com/shiwano.keys >> ~/.ssh/authorized_keys'
alias lsof-listen='lsof -i -P | grep "LISTEN"'
alias reload-shell='exec $SHELL -l'

alias a='add-git-files'
alias b='switch-git-branch'
alias s='git status'
alias u='unstage-git-files'
alias r='restore-git-files' # hide 'r' which is zsh's built-in command
alias g='move-to-ghq-directory'
alias v='edit-git-changed-file'
alias vv='edit-git-file'
alias gg='edit-git-grepped-file'
alias files='copy-file-path-to-clipboard'
alias files-changed='copy-changed-file-path-to-clipboard'
alias images='copy-image-path-to-clipboard'

autoload zmv
alias zmv='noglob zmv -W'
alias zcp='noglob zmv -C'
alias zln='noglob zmv -L'
alias zsy='noglob zmv -Ls'

if command -v go 2>&1 >/dev/null; then
  alias go-build-all='go test -run=^$ ./... 1>/dev/null'
fi

if command -v docker 2>&1 >/dev/null; then
  alias docker-rm-all='docker rm $(docker ps -a -q)'
  alias docker-rmi-all='docker rmi $(docker images -q)'
  alias docker-rm-volumes-all='docker volume rm $(docker volume ls -qf dangling=true)'
  alias docker-run-sh='docker run -it --entrypoint sh'
fi

if command -v bazelisk 2>&1 >/dev/null; then
  alias bazel='bazelisk'
fi

if command -v ibazel 2>&1 >/dev/null; then
  alias ibazel-go-test='ibazel --run_output_interactive=false -nolive_reload test :go_default_test'
fi

if command -v bat 2>&1 >/dev/null; then
  alias cat='bat'
fi

if ! command -v pbcopy 2>&1 >/dev/null; then
  if command -v xsel 2>&1 >/dev/null; then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
  elif command -v xsel 2>&1 >/dev/null; then
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

function prompt_pwd() {
  local dir="$(print -P '%~')"
  local icon_repo=$'\Uea62 '

  if [[ $dir =~ '^~\/code\/src\/[^/]+\/[^/]+\/(.*)$' ]]; then
    echo "$icon_repo${match[1]}"
  elif [[ $dir =~ '^~\/dotfiles\/?(.*)$' ]]; then
    echo "$icon_repo${dir#*/}"
  else
    echo "$dir"
  fi
}

function prompt_git_branch() {
  local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if [ -n "$branch" ]; then
    local icon_git_branch=$'\Ue0a0 '
    echo "$icon_git_branch$branch"
  else
    local icon_untracked=$'\Uf115 '
    echo "${icon_untracked} untracked"
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
    secondary_bg="#FF9E64"
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
  left_segment+="%K{$secondary_bg}%F{$secondary_fg}% "'$(prompt_pwd)'" %f%k"
  left_segment+="%F{$secondary_bg}${left_sep}%f"

  local right_segment=""
  right_segment+="%F{$secondary_fg} "'$(prompt_git_branch)'" %f"

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
function chpwd() { ls }

# ディレクトリ名だけで､ディレクトリの移動をする｡
setopt auto_cd

# C-s, C-qを無効にする。
setopt no_flow_control

# Change open files limit and user processes limit.
# See: https://gist.github.com/tombigel/d503800a282fcadbee14b537735d202c
ulimit -n 200000
ulimit -u 2000

# Disable C-d to exit shell
function _do_nothing() {}
zle -N _do_nothing
bindkey "^D" _do_nothing
setopt IGNORE_EOF

# .zshrc.local -----------------------------------------------------------------

[ -f ~/.zshrc.local ] && source ~/.zshrc.local
typeset -U path PATH # Remove duplicated PATHs.

# direnv -----------------------------------------------------------------------

if command -v direnv 2>&1 >/dev/null; then
  eval "$(direnv hook zsh)"
fi
