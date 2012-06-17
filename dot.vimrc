"------------------------------------------------------------------------------
set nocompatible    " vimですよ
"------------------------------------------------------------------------------
" 変数定義
let $TODAY = strftime('%Y%m%d')
let $DESKTOP = expand('~/desktop')

if has("win32") || has("win64")
  let $DOTVIM = expand('~/vimfiles')
else
  let $DOTVIM = expand('~/.vim')
endif
"------------------------------------------------------------------------------
" NeoBundle
" Plugin 追加: .vimrc に追加して、:NeoBundleInstall
" Plugin 削除: .vimrc から削除して、:NeoBundleClean
" Plugin 更新: :NeoBundleUpdate
filetype off                   " required!

if has('vim_starting')
  set rtp+=$DOTVIM/bundle/neobundle.vim/
  call neobundle#rc($DOTVIM.'/bundle')
endif
" NeoBundle
NeoBundle 'git://github.com/Shougo/neobundle.vim'
" Color scheme
NeoBundle 'https://github.com/ciaranm/inkpot'
NeoBundle 'https://github.com/tomasr/molokai'
NeoBundle 'https://github.com/jnurmine/Zenburn'
NeoBundle 'https://github.com/altercation/vim-colors-solarized'
NeoBundle 'https://github.com/nanotech/jellybeans.vim'
" Syntax highlight
NeoBundle 'jQuery'
NeoBundle 'https://github.com/hallison/vim-markdown'
NeoBundle 'https://github.com/kchmck/vim-coffee-script'
NeoBundle 'https://github.com/timcharper/textile.vim'
NeoBundle 'https://github.com/othree/html5-syntax.vim'
" Environment
NeoBundle 'https://github.com/Shougo/vimproc'
NeoBundle 'https://github.com/Shougo/vimfiler'
NeoBundle 'https://github.com/Shougo/unite.vim'
NeoBundle 'https://github.com/Sixeight/unite-grep'
NeoBundle 'https://github.com/thinca/vim-qfreplace'
" Code completion
NeoBundle 'https://github.com/Shougo/neocomplcache'
NeoBundle 'https://github.com/Shougo/neocomplcache-snippets-complete'
" Reference
NeoBundle 'https://github.com/thinca/vim-ref'
NeoBundle 'https://github.com/mojako/ref-sources.vim'
" Source reading
NeoBundle 'Source-Explorer-srcexpl.vim'
NeoBundle 'trinity.vim'
NeoBundle 'taglist.vim'
NeoBundle 'https://github.com/scrooloose/nerdtree'
" Lint
NeoBundle 'https://github.com/scrooloose/syntastic'
NeoBundle 'https://github.com/basyura/jslint.vim'
" Other plugins
NeoBundle 'https://github.com/tpope/vim-rails'
NeoBundle 'https://github.com/tpope/vim-surround'
NeoBundle 'https://github.com/thinca/vim-poslist'
NeoBundle 'https://github.com/thinca/vim-quickrun'
NeoBundle 'https://github.com/scrooloose/nerdcommenter'
NeoBundle 'https://github.com/mattn/webapi-vim'
NeoBundle 'https://github.com/mattn/gist-vim'
NeoBundle 'YankRing.vim'
NeoBundle 'matchit.zip'
filetype plugin indent on      " required!
"------------------------------------------------------------------------------
" カラースキーマ
syntax enable
set background=dark
colorscheme solarized

if !has('gui_running')
  set t_Co=256
  let g:solarized_termcolors=256
  let g:solarized_termtrans = 1
  let g:solarized_contrast = 'high'
  let g:solarized_visibility = 'high'
endif

if exists('+colorcolumn')
  set colorcolumn=81
endif
"------------------------------------------------------------------------------
" ステータスライン
set laststatus=2    " 常にステータスラインを表示
set statusline=%<%F\ %r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%4v(ASCII=%03.3b,HEX=%02.2B)\ %l/%L(%P)%m
"------------------------------------------------------------------------------
" 基本設定
let mapleader = "," " キーマップリーダー
set notitle         " タイトル変更しない
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
"------------------------------------------------------------------------------
" 表示
set showcmd         " 入力中のコマンドを表示
set number          " 行番号表示
set numberwidth=6   " 行番号の幅
set ruler           " ルーラーの表示
set list            " 不可視文字表示
set listchars=tab:>.,trail:_,extends:>,precedes:<   " 不可視文字の表示形式
set display=uhex    " 印字不可能文字を16進数で表示
" 全角スペースをハイライト
if has("syntax")
  syntax on
  function! ActivateInvisibleIndicator()
    syntax match InvisibleJISX0208Space "　" display containedin=ALL
    highlight InvisibleJISX0208Space term=underline ctermbg=236 guibg=Cyan
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
"------------------------------------------------------------------------------
" インデント
set autoindent
set smartindent
set cindent
" softtabstopはTabキー押し下げ時の挿入される空白の量，
" 0の場合はtabstopと同じ，BSにも影響する
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab " タブをスペースに展開
"------------------------------------------------------------------------------
" 補完・履歴
set wildmenu            " コマンド補完を強化
set wildchar=<tab>      " コマンド補完を開始するキー
set wildmode=list:full  " リスト表示，最長マッチ
set history=1000        " コマンド・検索パターンの履歴数
set complete+=k         " 補完に辞書ファイル追加
"------------------------------------------------------------------------------
" 検索設定
set nowrapscan " 最後まで検索したら先頭へ戻らない
set ignorecase " 大文字小文字無視
set smartcase  " 大文字ではじめたら大文字小文字無視しない
set incsearch  " インクリメンタルサーチ
set hlsearch   " 検索文字をハイライト
set grepprg=grep\ -nH " grep
"選択した文字列を検索
vnoremap <silent> // y/<C-R>=escape(@", '\\/.*$^~[]')<CR><CR>
"選択した文字列を置換
vnoremap /r "xy:%s/<C-R>=escape(@x, '\\/.*$^~[]')<CR>/<C-R>=escape(@x, '\\/.*$^~[]')<CR>/gc<Left><Left><Left>
"選択した文字列を Grep
vnoremap /g y:Unite grep::-iHRn:<C-R>=escape(@", '\\.*$^[]')<CR><CR>
"------------------------------------------------------------------------------
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
  set fileencodings&
  let &fileencodings = &fileencodings.','.s:enc_utf.','.s:enc_jis.',cp932,'.s:enc_euc
  unlet s:enc_euc
  unlet s:enc_jis
endif
if has('win32unix')
  set termencoding=cp932
endif
"------------------------------------------------------------------------------
" キーバインド関係
" 行単位で移動(1行が長い場合に便利)
nnoremap j gj
nnoremap k gk
" 検索などで飛んだらそこを真ん中に
nmap n nzz
nmap N Nzz
nmap * *zz
nmap # #zz
nmap g* g*zz
nmap g# g#zz
nmap G Gzz
" CTRL-hjklでウィンドウ移動
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l
nmap <C-h> <C-w>h
" その他キーバインド
nmap <C-r> <C-r>
imap <C-r> <C-o><C-r>
imap <C-l> <Right>
vmap <C-r> <Esc><C-r>
" qq でレジスタに記憶しないようにする
nmap qq <ESC>
" コマンドモードでの補完
cmap <C-p> <Up>
cmap <C-n> <Down>
" usキーボードで使いやすく
nmap ; :
vmap ; :
" 閉じかっこ補完
inoremap { {}<LEFT>
inoremap [ []<LEFT>
inoremap ( ()<LEFT>
inoremap " ""<LEFT>
inoremap ' ''<LEFT>
augroup MyXML
  autocmd!
  autocmd Filetype xml inoremap <buffer> </ </<C-x><C-o>
  autocmd Filetype html inoremap <buffer> </ </<C-x><C-o>
  autocmd Filetype eruby inoremap <buffer> </ </<C-x><C-o>
augroup END
"------------------------------------------------------------------------------
" ユーザ定義コマンド
command! Cd :cd %:h
" ファイル名変更
command! -nargs=+ -bang -complete=file Rename let pbnr=fnamemodify(bufname('%'), ':p')|exec 'f '.escape(<q-args>, ' ')|w<bang>|call delete(pbnr)
" エンコード指定してファイルを開く
command! -nargs=1 Reload :call s:Reload(<f-args>)
function! s:Reload(enc)
  e ++enc=a:enc
endfunction
" 改行コードをLF、エンコーディングをutf-8の状態にする
command! Normalize :call s:Normalize()
function! s:Normalize()
  set ff=unix
  set fenc=utf-8
  try
    %s///g
  catch
  endtry
endfunction
"------------------------------------------------------------------------------
" ユーティリティ
" ヘルプを翻訳版に変更
helptags $DOTVIM/doc
set helplang=ja,en
" タグファイル設定
set tags=$DOTVIM/mytags

if has("win32") || has("win64")
  set tags+=$DOTVIM/mytags_win
endif

if has('path_extra')
  set tags+=tags;
endif
"入力モード時、ステータスラインのカラーを変更
augroup InsertHook
autocmd!
autocmd InsertEnter * highlight StatusLine guifg=#ccdc90 guibg=#2E4340
autocmd InsertLeave * highlight StatusLine guifg=#2E4340 guibg=#ccdc90
augroup END
" Windowsバックスラッシュ対策 Vundleを使っているのでコメントアウト
"set shellslash
" クリップボードを使用
set clipboard=unnamed
"set clipboard=unnamedplus,unnamed
"------------------------------------------------------------------------------
" matchit.vim
" % で対応するフレーズに移動
let b:match_words="{{t:{{/t}}"
"------------------------------------------------------------------------------
" nerd_commenter.vim
let NERDSpaceDelims = 1
let NERDShutUp = 1
"------------------------------------------------------------------------------
" jslint.vim
function! s:javascript_filetype_settings()
  autocmd BufLeave     <buffer> call jslint#clear()
  autocmd BufWritePost <buffer> call jslint#check()
  autocmd CursorMoved  <buffer> call jslint#message()
endfunction
autocmd FileType javascript call s:javascript_filetype_settings()
"------------------------------------------------------------------------------
" yankring.vim
let g:yankring_history_file = '.yankring_history'
let g:yankring_manual_clipboard_check = 0
"------------------------------------------------------------------------------
" taglist.vim
if has("macunix")
  let Tlist_Ctags_Cmd = '/usr/local/bin/ctags'
endif
"------------------------------------------------------------------------------
" neocomplcache.vim
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_auto_completion_start_length = 2
let g:neocomplcache_min_syntax_length = 2
let g:neocomplcache_min_keyword_length = 2
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_enable_underbar_completion = 1
" スニペットファイルの置き場所
let g:neocomplcache_snippets_dir = $DOTVIM.'/snippets'
" スニペットを展開
imap <expr><TAB> pumvisible() ? "\<C-n>" : neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : "\<TAB>"
imap <expr><CR> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : "\<CR>"
" スニペット編集 引数にfiletype
command! -nargs=* Snippet NeoComplCacheEditSnippets
" 辞書
let g:neocomplcache_dictionary_filetype_lists = {
  \ 'default' : '',
  \ 'c' : $DOTVIM.'/dict/c-eglibc.dict',
  \ 'objc' : $DOTVIM.'/dict/objectivec.dict',
  \ 'ruby' : $DOTVIM.'/dict/ruby.dict',
  \ 'perl' : $DOTVIM.'/dict/perl.dict',
  \ 'css' : $DOTVIM.'/dict/css.dict',
  \ 'javascript' : $DOTVIM.'/dict/javascript.dict',
  \ 'actionscript' : $DOTVIM.'/dict/actionscript.dict',
  \ }

autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd FileType c set omnifunc=ccomplete#Complete
autocmd FileType cpp set omnifunc=cppcomplete#Complete
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType ruby,eruby setlocal omnifunc=rubycomplete#Complete
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
" autocmd FileType ruby,eruby let g:rubycomplete_rails = 1

if !exists('g:neocomplcache_omni_patterns')
  let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
let g:neocomplcache_omni_patterns.c = '\%(\.\|->\)\h\w*'
let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'
let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"------------------------------------------------------------------------------
" unite.vim
let g:unite_enable_start_insert = 1
let g:unite_update_time = 10
" バッファ一覧
nnoremap <silent> ,ub :<C-u>Unite buffer<CR>
" カレントディレクトリ一覧
nnoremap <silent> ,ud :<C-u>UniteWithCurrentDir file<CR>
" バッファのディレクトリ一覧
nnoremap <silent> ,uf :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
" レジスタ一覧
nnoremap <silent> ,ur :<C-u>Unite -buffer-name=register register<CR>
" 最近使用したファイル一覧
nnoremap <silent> ,um :<C-u>Unite file_mru<CR>
" 再帰的ファイル一覧
nnoremap <silent> ,uu :<C-u>Unite file_rec/async<CR>
" grep
nnoremap <silent> ,ug :Unite grep::-iHRn<CR>

autocmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings()
  imap <buffer> qq <Plug>(unite_exit)
  nmap <buffer> qq <Plug>(unite_exit)
  nmap <buffer> q <Plug>(unite_exit)
  imap <buffer> jj <Plug>(unite_insert_leave)
  imap <buffer> <C-w> <Plug>(unite_delete_backward_path)
  nmap <buffer> <C-w> <Plug>(unite_delete_backward_path)
  imap <buffer> <TAB> <Plug>(unite_select_next_line)<ESC>
  imap <buffer> <S-TAB> <Plug>(unite_select_previous_line)<ESC>
  nmap <buffer> <Tab> j
  nmap <buffer> <S-TAB> k
  imap <buffer> <C-n> <Plug>(unite_select_next_line)<ESC>
  imap <buffer> <C-p> <Plug>(unite_select_previous_line)<ESC>
  nmap <buffer> <C-n> j
  nmap <buffer> <C-p> k
  imap <buffer> <C-r> <Plug>(unite_redraw)
  nmap <buffer> <C-r> <Plug>(unite_redraw)
  imap <buffer><expr> <C-e> unite#do_action('vimfiler')
  nmap <buffer><expr> <C-e> unite#do_action('vimfiler')

  nmap <silent><buffer><expr> <C-j> unite#do_action('split')
  imap <silent><buffer><expr> <C-j> unite#do_action('split')
  nmap <silent><buffer><expr> <C-k> unite#do_action('split')
  imap <silent><buffer><expr> <C-k> unite#do_action('split')
  nmap <silent><buffer><expr> <C-l> unite#do_action('vsplit')
  imap <silent><buffer><expr> <C-l> unite#do_action('vsplit')
  nmap <silent><buffer><expr> <C-h> unite#do_action('vsplit')
  imap <silent><buffer><expr> <C-h> unite#do_action('vsplit')
endfunction
"------------------------------------------------------------------------------
" vimfiler
let g:vimfiler_safe_mode_by_default = 0
nnoremap <silent> <C-e> :VimFilerBufferDir -simple<CR>

autocmd! FileType vimfiler call g:vimfiler_my_settings()
function! g:vimfiler_my_settings()
  nmap qq <Plug>(vimfiler_exit)
  nmap q <Plug>(vimfiler_exit)
  nmap <buffer><expr><CR> vimfiler#smart_cursor_map("\<Plug>(vimfiler_expand_tree)", "\<Plug>(vimfiler_edit_file)")
endfunction
"------------------------------------------------------------------------------
" trinity.vim
" Open and close all the three plugins on the same time 
nmap <F8>   :TrinityToggleAll<CR> 
" Open and close the srcexpl.vim separately 
nmap <F9>   :TrinityToggleSourceExplorer<CR> 
" Open and close the taglist.vim separately 
nmap <F10>  :TrinityToggleTagList<CR> 
" Open and close the NERD_tree.vim separately 
nmap <F11>  :TrinityToggleNERDTree<CR> 
"------------------------------------------------------------------------------
" ref.vim
" K でカーソル下のワードを検索
nmap ,rr :<C-u>Ref refe<Space>
nmap ,ra :<C-u>Ref alc<Space>
nmap ,rjq :<C-u>Ref jquery<Space>
nmap ,rj :<C-u>Ref javascript<Space>
nmap ,rw :<C-u>Ref wikipedia<Space>
nmap ,rwe :<C-u>Ref wikipedia_en<Space>
let g:ref_alc_start_linenumber = 39 " 表示する行数
let g:ref_alc2_overwrite_alc = 1 " ref-sources の alc2 を使う
let g:ref_jquery_doc_path = $HOME.'/dotfiles/refs/jqapi'
let g:ref_javascript_doc_path = $HOME.'/dotfiles/refs/jsref/htdocs'
let g:ref_wikipedia_lang = ['ja', 'en']
"------------------------------------------------------------------------------
" Gist.vim
let g:gist_clip_command = 'pbcopy'
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 1
let g:gist_post_private = 1
"------------------------------------------------------------------------------
" syntastic
" :Errors エラー一覧表示
let g:syntastic_mode_map = { 'mode': 'active',
                           \ 'active_filetypes': [],
                           \ 'passive_filetypes': ['html'] }
