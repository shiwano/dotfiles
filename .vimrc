"-------------------------------------------------------------------------------
set nocompatible    " vimですよ
"-------------------------------------------------------------------------------
" 変数定義
let $TODAY = strftime('%Y%m%d')
let $DESKTOP = expand('~/desktop')

if has("win32") || has("win64")
  let $DOTVIM = expand('~/vimfiles')
else
  let $DOTVIM = expand('~/.vim')
endif
"-------------------------------------------------------------------------------
" Vundle
" $ git clone http://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
" インストール: .vimrcに追加して、BundleInstall
" アンインストール: .vimrcから削除して、BundleClean
filetype off                   " required!
set rtp+=$DOTVIM/bundle/vundle/
call vundle#rc('$DOTVIM/bundle/')
" Vundle
Bundle 'gmarik/vundle'
" Syntax highlight
Bundle "jQuery"
Bundle "Markdown"
Bundle "https://github.com/timcharper/textile.vim.git"
Bundle "vim-coffee-script"
" Color scheme
Bundle "inkpot"
" Plugins
Bundle "YankRing.vim"
Bundle "https://github.com/thinca/vim-ref.git"
Bundle "https://github.com/thinca/vim-poslist.git"
Bundle "https://github.com/thinca/vim-quickrun.git"
Bundle 'Shougo/neocomplcache'
Bundle 'matchit.zip'
Bundle 'http://github.com/scrooloose/nerdcommenter.git'
Bundle 'surround.vim'
Bundle 'unite.vim'
Bundle 'rails.vim'
Bundle 'basyura/jslint.vim'
filetype plugin indent on      " required!
"-------------------------------------------------------------------------------
" カラースキーマ
if !has('gui_running')
  set t_Co=256
  colorscheme inkpot
endif
" 80 columns highlight
if exists('+colorcolumn')
  highlight ColorColumn ctermbg=lightgrey guibg=lightgrey
  set colorcolumn=80
endif
"-------------------------------------------------------------------------------
" ステータスライン
set laststatus=2    " 常にステータスラインを表示
set statusline=%<%F\ %r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%4v(ASCII=%03.3b,HEX=%02.2B)\ %l/%L(%P)%m
"-------------------------------------------------------------------------------
" 基本設定
let mapleader = "," " キーマップリーダー
set scrolloff=5     " スクロール時の余白確保
set nobackup        " バックアップ取らない
set autoread        " 他で書き換えられたら自動で読み直す
set noswapfile      " スワップファイル作らない
set hidden          " 編集中でも他のファイルを開けるようにする
set backspace=indent,eol,start  " バックスペースでなんでも消せるように
set formatoptions=lmoq  " テキスト整形オプション，マルチバイト系を追加
set vb t_vb=        " ビープをならさない
set browsedir=buffer    " Exploreの初期ディレクトリ
set whichwrap=b,s,h,l,<,>,[,]   " カーソルを行頭、行末で止まらないようにする
set showcmd         " コマンドをステータス行に表示
set magic           " 正規表現に使われる記号を有効にする
"-------------------------------------------------------------------------------
" 表示
set showcmd         " 入力中のコマンドを表示
set number          " 行番号表示
set numberwidth=8   " 行番号の幅
set ruler           " ルーラーの表示
set list            " 不可視文字表示
set listchars=tab:>.,trail:_,extends:>,precedes:<   " 不可視文字の表示形式
set display=uhex    " 印字不可能文字を16進数で表示
" 全角スペースをハイライト
if has("syntax")
  syntax on
  function! ActivateInvisibleIndicator()
    syntax match InvisibleJISX0208Space "　" display containedin=ALL
    highlight InvisibleJISX0208Space term=underline ctermbg=Cyan guibg=Cyan
"    syntax match InvisibleTrailedSpace "[ \t]\+$" display containedin=ALL
"    highlight InvisibleTrailedSpace term=underline ctermbg=Red guibg=Red
"    syntax match InvisibleTab "\t" display containedin=ALL
"    highlight InvisibleTab term=underline ctermbg=DarkCyan guibg=DarkCyan
  endf
  augroup invisible
    autocmd! invisible
    autocmd BufNew,BufRead * call ActivateInvisibleIndicator()
  augroup END
endif
" カレントウィンドウにのみ罫線を引く
augroup cch
  autocmd! cch
  autocmd WinLeave * set nocursorline
  autocmd WinEnter,BufRead * set cursorline
augroup END
"-------------------------------------------------------------------------------
" インデント
set autoindent
set smartindent
set cindent
" softtabstopはTabキー押し下げ時の挿入される空白の量，
" 0の場合はtabstopと同じ，BSにも影響する
set shiftwidth=2
set softtabstop=2
set expandtab " タブをスペースに展開
"-------------------------------------------------------------------------------
" 補完・履歴
set wildmenu            " コマンド補完を強化
set wildchar=<tab>      " コマンド補完を開始するキー
set wildmode=list:full  " リスト表示，最長マッチ
set history=1000        " コマンド・検索パターンの履歴数
set complete+=k         " 補完に辞書ファイル追加
"-------------------------------------------------------------------------------
" 検索設定
set nowrapscan " 最後まで検索したら先頭へ戻らない
set ignorecase " 大文字小文字無視
set smartcase  " 大文字ではじめたら大文字小文字無視しない
set incsearch  " インクリメンタルサーチ
set hlsearch   " 検索文字をハイライト
"選択した文字列を検索
vnoremap <silent> // y/<C-R>=escape(@", '\\/.*$^~[]')<CR><CR>
"選択した文字列を置換
vnoremap /r "xy:%s/<C-R>=escape(@x, '\\/.*$^~[]')<CR>/<C-R>=escape(@x, '\\/.*$^~[]')<CR>/gc<Left><Left><Left>
"-------------------------------------------------------------------------------
" エンコーディング関連
" 改行文字
set ffs=unix,dos,mac
" デフォルトエンコーディング
let $LANG='ja_JP.UTF-8'
set encoding=utf-8
set fileencoding=utf-8
if has('win32') && has('kaoriya')
  set ambiwidth=auto
else
  set ambiwidth=double
endif
if has('iconv')
  let s:enc_utf = 'utf-8'
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  if iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213,euc-jp'
    let s:enc_jis = 'iso-2022-jp-3'
  endif
  set   fileencodings&
  let &fileencodings = &fileencodings.','.s:enc_utf.','.s:enc_jis.',cp932,'.s:enc_euc
  unlet s:enc_euc
  unlet s:enc_jis
endif
if has('win32unix')
  set termencoding=cp932
endif
"-------------------------------------------------------------------------------
" キーバインド関係
" 行単位で移動(1行が長い場合に便利)
nnoremap j gj
nnoremap k gk
" バッファ周り
nmap <silent> <C-Right> :bnext<CR>
nmap <silent> <C-Left> :bprevious<CR>
nmap <silent> <C-c> :bw<CR>
nmap <silent> <C-b> :b#<CR>
"nmap <silent> <C-l> :ls<CR>
" 検索などで飛んだらそこを真ん中に
nmap n nzz
nmap N Nzz
nmap * *zz
nmap # #zz
nmap g* g*zz
nmap g# g#zz
nmap G Gzz
" その他キーバインド
nmap <C-r> <C-r>
imap <C-r> <C-o><C-r>
vmap <C-r> <Esc><C-r>
"usキーボードで使いやすく
nmap ; :
" Explore
"nmap <silent> <C-e> :Explore<CR>
"-------------------------------------------------------------------------------
" ユーザ定義コマンド
command! Vsp :set columns=176|vsp
command! RW :set columns=88
command! ResetWidth :set columns=88
command! Cd :cd %:h
" エンコード指定してファイルを開く
command! -nargs=1 Reload :call s:Reload(<f-args>)
function! s:Reload(enc)
  e ++enc=a:enc
endfunction
" 改行コードをLF、エンコーディングをutf-8の状態にする
command! SD :call s:SetDefault()
command! SetDefault :call s:SetDefault()
function! s:SetDefault()
  set ff=unix
  set fenc=utf-8
  try
    %s///g
  catch
  endtry
endfunction
" ソース編集中に開いているファイルを実行する
function! s:Exec()
  exe "!" . &ft . " %"
:endfunction
command! Exec call <SID>Exec()
map <silent> <C-F9> :call <SID>Exec()<CR>
" Python実行
if has('python')
  python import vim
  command Py python exec('\n'.join(vim.current.buffer))
endif
"-------------------------------------------------------------------------------
" matchit.vim
" % で対応するフレーズに移動
let b:match_words="{{t:{{/t}}"
"-------------------------------------------------------------------------------
" nerd_commenter.vim
let NERDSpaceDelims = 1
let NERDShutUp = 1
"-------------------------------------------------------------------------------
" jslint.vim
function! s:javascript_filetype_settings()
  autocmd BufLeave     <buffer> call jslint#clear()
  autocmd BufWritePost <buffer> call jslint#check()
  autocmd CursorMoved  <buffer> call jslint#message()
endfunction
autocmd FileType javascript call s:javascript_filetype_settings()
"-------------------------------------------------------------------------------
" yankring.vim
let g:yankring_history_file = '.yankring_history'
"-------------------------------------------------------------------------------
" neocomplcache.vim
let g:neocomplcache_enable_at_startup = 1
" スニペットファイルの置き場所
let g:NeoComplCache_SnippetsDir = '$DOTVIM/snippets'
" TABでスニペットを展開
imap <expr> <TAB> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : pumvisible() ? "\<C-n>" : "\<Tab>"
" スニペット編集 引数にfiletype
command! -nargs=* Snip NeoComplCacheEditSnippets
"-------------------------------------------------------------------------------
" ユーティリティ
" 現在開いているファイルのある場所に常にcdする
" au BufEnter * exec ":lcd " . expand("%:p:h")
" 開いたファイル先を自動的にカレントディレクトリに設定
" set autochdir
" ヘルプを翻訳版に変更
helptags $DOTVIM/doc
set helplang=ja,en
" タグファイル設定
if has("win32") || has("win64")
  set tags=$DOTVIM/mytags_win
else
  set tags=$DOTVIM/mytags
endif
"入力モード時、ステータスラインのカラーを変更
augroup InsertHook
autocmd!
autocmd InsertEnter * highlight StatusLine guifg=#ccdc90 guibg=#2E4340
autocmd InsertLeave * highlight StatusLine guifg=#2E4340 guibg=#ccdc90
augroup END
" Windowsバックスラッシュ対策 Vundleを使っているのでコメントアウト
"set shellslash
" Windowsクリップボードを使用
set clipboard=unnamedplus,unnamed
"-------------------------------------------------------------------------------
" unite.vim
" 入力モードで開始する
" let g:unite_enable_start_insert=1
" バッファ一覧
nnoremap <silent> ,ub :<C-u>Unite buffer<CR>
" ファイル一覧
nnoremap <silent> ,uf :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
" レジスタ一覧
nnoremap <silent> ,ur :<C-u>Unite -buffer-name=register register<CR>
" 最近使用したファイル一覧
nnoremap <silent> ,um :<C-u>Unite file_mru<CR>
" 常用セット
nnoremap <silent> ,uu :<C-u>Unite buffer file_mru<CR>
" 全部乗せ
nnoremap <silent> ,ua :<C-u>UniteWithBufferDir -buffer-name=files buffer file_mru bookmark file<CR>

" ウィンドウを分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
au FileType unite inoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
" ウィンドウを縦に分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
au FileType unite inoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
" ESCキーを2回押すと終了する
au FileType unite nnoremap <silent> <buffer> <ESC><ESC> q
au FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>q
