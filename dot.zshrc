# 補完機能有効
fpath=($HOME/.zsh/completion ${fpath})
autoload -U compinit
compinit

# 256色
export TERM=xterm-256color

# 文字コードの設定
export LANG=ja_JP.UTF-8

# PATH
PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH
export MANPATH=/usr/local/share/man:/usr/local/man:/usr/share/man

if [ -d /usr/local/Cellar/coreutils ]; then
  PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
  MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
fi

if [ -d /usr/local/Cellar/gnu-sed ]; then
  PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
  MANPATH="/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH"
fi

if [ -d /usr/local/Cellar/openssl ]; then
  PATH="/usr/local/opt/openssl/bin:$PATH"
fi

if [ -d /usr/local/Caskroom/google-cloud-sdk ]; then
  PATH="/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin:$PATH"
fi

if [ -d ${HOME}/.anyenv ] ; then
  PATH="$HOME/.anyenv/bin:$PATH"
  eval "$(anyenv init -)"
  for D in `find $HOME/.anyenv/envs -maxdepth 1 -type d`; do
    PATH="$D/shims:$PATH"
  done
fi

if [ -d /usr/local/heroku ] ; then
  export PATH="/usr/local/heroku/bin:$PATH"
fi

if [ -d "$HOME/code/src/github.com/flutter/flutter" ] ; then
  export PATH="$HOME/code/src/github.com/flutter/flutter/bin:$PATH"
  export PATH="$HOME/.pub-cache/bin:$PATH"
fi

if [ -d "$HOME/Library/Android/sdk" ] ; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
fi

if [ -d ${HOME}/.local ] ; then
  PATH="$HOME/.local/bin:$PATH"
fi

export XDG_CONFIG_HOME=$HOME/.config

# Go
export GOPATH=$HOME/code
PATH="$GOPATH/bin:$PATH"
export GO15VENDOREXPERIMENT=1
export GO111MODULE=on
export GOENV_DISABLE_GOPATH=1

# android sdks
if [ -d /Applications/android-sdk-macosx ]; then
  PATH="/Applications/android-sdk-macosx/tools:$PATH"
fi

# vim
if [ -d $HOME/Applications/MacVim.app ]; then
  alias vim='$HOME/Applications/MacVim.app/Contents/MacOS/Vim "$@"'
  alias gvim='open -a $HOME/Applications/MacVim.app "$@"'
  alias vimdiff=$HOME/Applications/MacVim.app/Contents/MacOS/vimdiff
fi

if type nvim > /dev/null; then
  alias vi='nvim'
  alias vimdiff='nvim -d'
  export EDITOR='nvim'
else
  alias vi='vim'
  export EDITOR='vim'
fi

# direnv
if type direnv > /dev/null; then
  eval "$(direnv hook zsh)"
fi

# vi風キーバインド
# bindkey -v

# 関数
function find-grep { find . -name $1 -type f -print | xargs grep -n --binary-files=without-match $2 }
function find-sed { find . -name $1 -type f | xargs gsed -i $2 }

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
  if type python > /dev/null; then
    if python -V 2>&1 | grep -qm1 'Python 3\.'; then
      python -m http.server ${1-5000}
    else
      python -m SimpleHTTPServer ${1-5000}
    fi
  fi
}

function grep-git-files {
  [ $@ ] && git ls-files -z . | xargs -0 ag --pager="less -R --no-init --quit-if-one-screen" --smart-case $@
}

function move-to-ghq-directory {
  local p="$(ghq list | peco --select-1)"
  [ $p ] && cd $(ghq root)/$p
}

function edit-git-grepped-file {
  if [ $@ ]; then
    local s="$(grep-git-files $@ | peco --select-1)"
    [ $s ] && shift $# && vim +"$(echo $s | cut -d : -f2)" "$(echo $s | cut -d : -f1)"
  fi
}

function edit-git-file {
  local dir=${1-.}
  local s="$(git ls-files $dir | peco --select-1)"
  [ $s ] && shift $# && vi $s
}

function edit-git-changed-file {
  local s="$({ git diff --name-only | cat & git diff --cached --name-only | cat & git ls-files --others --exclude-standard | cat } | cat | sort | uniq | peco --select-1)"
  [ $s ] && shift $# && vi $s
}

# エイリアスの設定
alias ls='ls --color=auto'
alias ll='ls -l --block-size=KB'
alias la='ls -A'
alias lal='ls -l -A --block-size=KB'
alias livereload='guard start -i -B -G ~/dotfiles/tools/livereload.Guardfile'
alias tmux='tmuxx'
alias search='ag -g . | ag '
alias authorize-shiwano='curl https://github.com/shiwano.keys >> ~/.ssh/authorized_keys'

alias s='git status'
alias g='move-to-ghq-directory'
alias v='edit-git-changed-file'
alias vv='edit-git-file'
alias gg='grep-git-files'
alias ggv='edit-git-grepped-file'

autoload zmv
alias zmv='noglob zmv -W'
alias zcp='noglob zmv -C'
alias zln='noglob zmv -L'
alias zsy='noglob zmv -Ls'

alias docker-rm-all='docker rm $(docker ps -a -q)'
alias docker-rmi-all='docker rmi $(docker images -q)'
alias docker-sh='docker run -it --entrypoint sh'

alias lsof-listen='lsof -i -P | grep "LISTEN"'

alias go-get='GO111MODULE=off go get -u'

# プロンプトの設定
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '[%b]'
zstyle ':vcs_info:*' actionformats '[%b|%a]'
ZSHFG=`expr $RANDOM / 128`

function precmd {
  psvar=()
  LANG=en_US.UTF-8 vcs_info
  [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"

  if [ $ZSHFG -ge 250 ]; then
    ZSHFG=0
  fi

  ZSHFG=`expr $ZSHFG + 10`
  RPROMPT="%1(v|%F{$ZSHFG}%1v%f|)"
}

case ${UID} in
0)
  PROMPT="%B%{[31m%}%/#%{[m%}%b "
  PROMPT2="%B%{[31m%}%_#%{[m%}%b "
  SPROMPT="%B%{[31m%}%r is correct? [n,y,a,e]:%{[m%}%b "
  [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
      PROMPT="%{[37m%}${HOST%%.*} ${PROMPT}"
  ;;
*)
  PROMPT="%{[31m%}%/%%%{[m%} "
  PROMPT2="%{[31m%}%_%%%{[m%} "
  SPROMPT="%{[31m%}%r is correct? [n,y,a,e]:%{[m%} "
  [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
      PROMPT="%{[37m%}${HOST%%.*} ${PROMPT}"
  ;;
esac

# 補完設定
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

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
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# cdのタイミングで自動的にpushd
setopt auto_pushd

# 複数の zsh を同時に使う時など history ファイルに上書きせず追加
setopt append_history

# 補完候補が複数ある時に、一覧表示
setopt auto_list

# auto_list の補完候補一覧で、ls -F のようにファイルの種別をマーク表示しない
setopt no_list_types

# 保管結果をできるだけ詰める
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

# ディレクトリを水色にする｡
export LS_COLORS='di=01;36'

# ファイルリスト補完でもlsと同様に色をつける｡
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# cd をしたときにlsを実行する
function chpwd() { ls }

# ディレクトリ名だけで､ディレクトリの移動をする｡
setopt auto_cd

# C-s, C-qを無効にする。
setopt no_flow_control

# C-p C-n でコマンド履歴検索
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(\history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

# ローカルの .zshrc を読み込む
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# PATH の重複を消す
typeset -U path PATH
