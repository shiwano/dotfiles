# •âŠ®‹@”\—LŒø
autoload -U compinit
compinit

# •¶šƒR[ƒh‚Ìİ’è
export LANG=ja_JP.UTF-8

# ƒpƒX‚Ìİ’è
PATH=~/bin:/usr/local/bin:$PATH
export MANPATH=/usr/local/share/man:/usr/local/man:/usr/share/man
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # This loads RVM into a shell session.

#vim
if [ -d /Applications/MacVim.app ]; then
  export EDITOR=/Applications/MacVim.app/Contents/MacOS/Vim
  alias vi='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
  alias vim='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
fi

# ŠÖ”
find-grep () { find . -type f -print | xargs grep -n --binary-files=without-match $@ }

# vi•—ƒL[ƒoƒCƒ“ƒh
bindkey -v

# ƒGƒCƒŠƒAƒX‚Ìİ’è
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -A'
alias lal="ls -l -A"
alias vi='vim'
#alias cp="cp -i"
#alias mv="mv -i"
#alias rm="rm -i"
alias g='git'
alias s='git status'

# ƒvƒƒ“ƒvƒg‚Ìİ’è
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

# •âŠ®İ’è
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

# ƒVƒFƒ‹‚ÌƒvƒƒZƒX‚²‚Æ‚É—š—ğ‚ğ‹¤—L
setopt share_history

# —]•ª‚ÈƒXƒy[ƒX‚ğíœ‚µ‚ÄƒqƒXƒgƒŠ‚É‹L˜^‚·‚é
setopt hist_reduce_blanks

# ƒqƒXƒgƒŠ‚ÉhistoryƒRƒ}ƒ“ƒh‚ğ‹L˜^‚µ‚È‚¢
setopt hist_no_store

# ƒqƒXƒgƒŠ‚ğŒÄ‚Ño‚µ‚Ä‚©‚çÀs‚·‚éŠÔ‚Éˆê’U•ÒW‚Å‚«‚éó‘Ô‚É‚È‚é
setopt hist_verify

# s“ª‚ªƒXƒy[ƒX‚Ån‚Ü‚éƒRƒ}ƒ“ƒhƒ‰ƒCƒ“‚ÍƒqƒXƒgƒŠ‚É‹L˜^‚µ‚È‚¢
#setopt hist_ignore_spece

# ’¼‘O‚Æ“¯‚¶ƒRƒ}ƒ“ƒhƒ‰ƒCƒ“‚ÍƒqƒXƒgƒŠ‚É’Ç‰Á‚µ‚È‚¢
setopt hist_ignore_dups

# d•¡‚µ‚½ƒqƒXƒgƒŠ‚Í’Ç‰Á‚µ‚È‚¢
setopt hist_ignore_all_dups

# •âŠ®‚·‚é‚©‚Ì¿–â‚Í‰æ–Ê‚ğ’´‚¦‚é‚É‚Ì‚İ‚És‚¤¡
LISTMAX=0

# sudo ‚Å‚à•âŠ®‚Ì‘ÎÛ
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# cd‚Ìƒ^ƒCƒ~ƒ“ƒO‚Å©“®“I‚Épushd
setopt auto_pushd

# check correct command
#setopt correct

# •¡”‚Ì zsh ‚ğ“¯‚Ég‚¤‚È‚Ç history ƒtƒ@ƒCƒ‹‚Éã‘‚«‚¹‚¸’Ç‰Á
setopt append_history

# •âŠ®Œó•â‚ª•¡”‚ ‚é‚ÉAˆê——•\¦
setopt auto_list

# auto_list ‚Ì•âŠ®Œó•âˆê——‚ÅAls -F ‚Ì‚æ‚¤‚Éƒtƒ@ƒCƒ‹‚Ìí•Ê‚ğƒ}[ƒN•\¦‚µ‚È‚¢
setopt no_list_types

# •ÛŠÇŒ‹‰Ê‚ğ‚Å‚«‚é‚¾‚¯‹l‚ß‚é
setopt list_packed

# •âŠ®ƒL[iTab, Ctrl+I) ‚ğ˜A‘Å‚·‚é‚¾‚¯‚Å‡‚É•âŠ®Œó•â‚ğ©“®‚Å•âŠ®
setopt auto_menu

# ƒJƒbƒR‚Ì‘Î‰‚È‚Ç‚ğ©“®“I‚É•âŠ®
setopt auto_param_keys

# ƒfƒBƒŒƒNƒgƒŠ–¼‚Ì•âŠ®‚Å––”ö‚Ì / ‚ğ©“®“I‚É•t‰Á‚µAŸ‚Ì•âŠ®‚É”õ‚¦‚é
setopt auto_param_slash

# ƒr[ƒv‰¹‚ğ–Â‚ç‚³‚È‚¢‚æ‚¤‚É‚·‚é
setopt no_beep

# ƒRƒ}ƒ“ƒhƒ‰ƒCƒ“‚Ìˆø”‚Å --prefix=/usr ‚È‚Ç‚Ì = ˆÈ~‚Å‚à•âŠ®‚Å‚«‚é
setopt magic_equal_subst

# ƒtƒ@ƒCƒ‹–¼‚Ì“WŠJ‚ÅƒfƒBƒŒƒNƒgƒŠ‚Éƒ}ƒbƒ`‚µ‚½ê‡––”ö‚É / ‚ğ•t‰Á‚·‚é
setopt mark_dirs

# 8 ƒrƒbƒg–Ú‚ğ’Ê‚·‚æ‚¤‚É‚È‚èA“ú–{Œê‚Ìƒtƒ@ƒCƒ‹–¼‚ğ•\¦‰Â”\
setopt print_eight_bit

# Ctrl+w‚Å¤’¼‘O‚Ì/‚Ü‚Å‚ğíœ‚·‚é¡
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# ƒfƒBƒŒƒNƒgƒŠ‚ğ…F‚É‚·‚é¡
export LS_COLORS='di=01;36'

# ƒtƒ@ƒCƒ‹ƒŠƒXƒg•âŠ®‚Å‚àls‚Æ“¯—l‚ÉF‚ğ‚Â‚¯‚é¡
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# cd ‚ğ‚µ‚½‚Æ‚«‚Éls‚ğÀs‚·‚é
function chpwd() { ls }

# ƒfƒBƒŒƒNƒgƒŠ–¼‚¾‚¯‚Å¤ƒfƒBƒŒƒNƒgƒŠ‚ÌˆÚ“®‚ğ‚·‚é¡
setopt auto_cd

# C-s, C-q‚ğ–³Œø‚É‚·‚éB
setopt no_flow_control

# C-p C-n ‚ÅƒRƒ}ƒ“ƒh—š—ğŒŸõ
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
