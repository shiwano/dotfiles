export TERM=xterm-256color
export LANG=ja_JP.UTF-8
export XDG_CONFIG_HOME=$HOME/.config
export LS_COLORS='di=01;36'

export GOPATH=$HOME/code
export GO15VENDOREXPERIMENT=1
export GO111MODULE=on

bindkey -e

# Completion -------------------------------------------------------------------

fpath=($HOME/.zsh/completion ${fpath})
autoload -U compinit
compinit

# Color scheme -----------------------------------------------------------------

BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

base16_tomorrow-night

# PATH -------------------------------------------------------------------------

export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$GOPATH/bin:$PATH
export MANPATH=/usr/local/share/man:/usr/local/man:/usr/share/man

if [ -d /usr/local/Cellar/coreutils ]; then
  export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
  export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
fi

if [ -d /usr/local/Cellar/gnu-sed ]; then
  export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
  export MANPATH="/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH"
fi

if [ -d /usr/local/Cellar/openssl ]; then
  export PATH="/usr/local/opt/openssl/bin:$PATH"
fi

if [ -d /usr/local/Caskroom/google-cloud-sdk ]; then
  source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
  source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
fi

if [ -d ${HOME}/.anyenv ] ; then
  export PATH="$HOME/.anyenv/bin:$PATH"
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

if [ -d ${HOME}/.local ] ; then
  export PATH="$HOME/.local/bin:$PATH"
fi

if [ -d /usr/local/share/android-sdk ]; then
  export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"
  export PATH="/usr/local/share/android-sdk/tools/bin:$PATH"
fi

if [ -d /usr/local/heroku ] ; then
  export PATH="/usr/local/heroku/bin:$PATH"
fi

# Vim --------------------------------------------------------------------------

if type nvim > /dev/null; then
  if [ -n "${NVIM_LISTEN_ADDRESS}" ]; then
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

# direnv -----------------------------------------------------------------------

if type direnv > /dev/null; then
  eval "$(direnv hook zsh)"
fi

# fzf -----------------------------------------------------------------------

if type fzf > /dev/null; then
  export FZF_DEFAULT_OPTS="--layout=reverse --info hidden"
  export FZF_DEFAULT_COMMAND="rg --files --hidden -g '!.git'"
fi

# Functions --------------------------------------------------------------------

function find-grep {
  find . -name $1 -type f -print | xargs grep -n --binary-files=without-match $2
}

function find-sed {
  find . -name $1 -type f | xargs gsed -i $2
}

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
  [ $@ ] && git ls-files -z . | xargs -0 rg -n -p $@ | less -R --no-init --quit-if-one-screen
}

function move-to-ghq-directory {
  local p="$(ghq list | fzf)"
  [ $p ] && cd $(ghq root)/$p
}

function edit-git-grepped-file {
  if [ $@ ]; then
    local s="$(git ls-files -z . | xargs -0 rg -n $@ | fzf)"
    [ $s ] && shift $# && vi +"$(echo $s | cut -d : -f2)" "$(echo $s | cut -d : -f1)"
  fi
}

function edit-git-file {
  local dir=${1-.}
  local s="$(git ls-files $dir | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}')"
  [ $s ] && shift $# && vi $s
}

function edit-git-changed-file {
  local s1="$({
    (git diff --name-only | xargs -I '{}' realpath --relative-to=. $(git rev-parse --show-toplevel)/'{}') |
    cat & (git diff --cached --name-only | xargs -I '{}' realpath --relative-to=. $(git rev-parse --show-toplevel)/'{}') |
    cat & git ls-files --others --exclude-standard | cat } | cat | sort | uniq
  )"
  if [ $s1 ]; then
    local s2="$(echo $s1 | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}')"
    [ $s2 ] && shift $# && vi $s2
  fi
}

function select-history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
}

# Aliases ----------------------------------------------------------------------

alias ls='ls --color=auto'
alias ll='ls -l --block-size=KB'
alias la='ls -A'
alias lal='ls -l -A --block-size=KB'
alias tmux='tmuxx'
alias authorize-shiwano='curl https://github.com/shiwano.keys >> ~/.ssh/authorized_keys'
alias lsof-listen='lsof -i -P | grep "LISTEN"'
alias reload-shell='exec $SHELL -l'
alias go-get='GO111MODULE=off go get -u'
alias go-test-build-all='go test -run=^$ ./...'
alias dotfiles='cd ~/dotfiles'

alias s='git status'
alias r='git restore' # hide 'r' which is zsh's built-in command
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

if type docker > /dev/null; then
  alias docker-rm-all='docker rm $(docker ps -a -q)'
  alias docker-rmi-all='docker rmi $(docker images -q)'
  alias docker-sh='docker run -it --entrypoint sh'
fi

if type bazelisk > /dev/null; then
  alias bazel='bazelisk'
fi

if type ibazel > /dev/null; then
  alias ibazel-go-test='ibazel --run_output_interactive=false -nolive_reload test :go_default_test'
fi

# Prompt -----------------------------------------------------------------------

autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '%b'
zstyle ':vcs_info:*' actionformats '%b|%a'

() {
  local icon_cat=$'\Uf61a '
  local icon_key=$'\Uf805 '
  local icon_folder=$'\Uf450 '
  local icon_network=$'\Ufbf1 '

  case ${UID} in
    0)
      local prompt_face="${icon_key}"
      ;;
    *)
      local prompt_face="${icon_cat}"
      ;;
  esac

  if [ -n "${NVIM_LISTEN_ADDRESS}" ]; then
    PROMPT="%{[31m%}nvim $ %{[m%}"
  else
    PROMPT="%{[31m%}${icon_folder}%~ ${prompt_face}%{[m%}"
  fi

  PROMPT2="%{[31m%}| %{[m%}"
  SPROMPT="%{[31m%}%r is correct? [n,y,a,e]:%{[m%} "
  [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
    PROMPT="%{[31m%}${icon_network}${HOST%%.*} ${PROMPT}"
}

if [ -z "${NVIM_LISTEN_ADDRESS}" ]; then
  PREEXEC_START_TIME=`date +%s`

  function precmd {
    psvar=()
    LANG=en_US.UTF-8 vcs_info
    [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"

    local icon_clock=$'\Uf017 '
    local icon_git_branch=$'\Uf418 '
    local end_time=`date +%s`
    local run_time=$((end_time - PREEXEC_START_TIME))

      if [ "$(whoami)" = 'shiwano' ]; then
        RPROMPT="%{[35m%}${icon_clock}${run_time}s%{[m%} %1(v|%{[34m%}${icon_git_branch}%1v%{[m%}|)"
      else
        local icon_user=$'\Uf2c0 '
        RPROMPT="%{[35m%}${icon_clock}${run_time}s%{[m%} %1(v|%{[34m%}${icon_git_branch}%1v%{[m%}|) %{[36m%}${icon_user}%n%{[m%}"
      fi
  }

  function preexec {
    PREEXEC_START_TIME=`date +%s`
  }
fi

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

# ファイルリスト補完でもlsと同様に色をつける｡
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# cd をしたときにlsを実行する
function chpwd() { ls }

# ディレクトリ名だけで､ディレクトリの移動をする｡
setopt auto_cd

# C-s, C-qを無効にする。
setopt no_flow_control

# .zshrc.local -----------------------------------------------------------------

[ -f ~/.zshrc.local ] && source ~/.zshrc.local
typeset -U path PATH # Remove duplicated PATHs.
