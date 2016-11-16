"------------------------------------------------------------------------------
set nocompatible " Vim!
"------------------------------------------------------------------------------
" Variables
let $TODAY = strftime('%Y%m%d')
let $DESKTOP = expand('~/desktop')

if has("macunix")
  let $LUA_DLL = '/usr/local/Cellar/lua/5.2.3_1/lib/liblua.dylib'
endif

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
filetype off

if has('vim_starting')
  set rtp+=$DOTVIM/bundle/neobundle.vim/
endif

call neobundle#begin($DOTVIM.'/bundle')
" NeoBundle
NeoBundle 'Shougo/neobundle.vim'
" Color scheme
NeoBundle 'ciaranm/inkpot'
NeoBundle 'altercation/vim-colors-solarized'
" Syntax highlight
NeoBundle 'jQuery'
NeoBundle 'jelera/vim-javascript-syntax'
NeoBundle 'mustache/vim-mustache-handlebars'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'othree/html5-syntax.vim'
NeoBundle 'timcharper/textile.vim'
NeoBundle 'groenewege/vim-less'
NeoBundle 'wavded/vim-stylus'
NeoBundle 'hail2u/vim-css3-syntax'
NeoBundle 'digitaltoad/vim-jade'
NeoBundle 'leafgarland/typescript-vim'
NeoBundle 'gkz/vim-ls'
NeoBundle 'elzr/vim-json'
NeoBundle 'honza/Dockerfile.vim'
NeoBundle 'beyondmarc/hlsl.vim'
NeoBundle 'godlygeek/tabular' " vim-markdown required
NeoBundle 'plasticboy/vim-markdown'
" Environment
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/neomru.vim'
NeoBundle 'Sixeight/unite-grep'
NeoBundle 'Shougo/vimfiler'
NeoBundle 'thinca/vim-qfreplace'
NeoBundle 'Shougo/vimproc.vim', {
\ 'build' : {
\     'windows' : 'tools\\update-dll-mingw',
\     'cygwin' : 'make -f make_cygwin.mak',
\     'mac' : 'make -f make_mac.mak',
\     'linux' : 'make',
\     'unix' : 'gmake',
\    },
\ }
" Code completion
NeoBundle 'Shougo/neocomplete.vim'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'kana/vim-smartinput'
NeoBundle 'Quramy/tsuquyomi'
NeoBundle 'marijnh/tern_for_vim', {
\ 'autoload' : { 'filetypes' : 'javascript' },
\   'build': {
\     'windows': 'npm install',
\     'mac': 'npm install',
\     'unix': 'npm install',
\   },
\ }
NeoBundleLazy 'nosami/Omnisharp', {
\   'autoload': {'filetypes': ['cs']},
\   'build': {
\     'windows': 'MSBuild.exe server/OmniSharp.sln /p:Platform="Any CPU"',
\     'mac': 'xbuild server/OmniSharp.sln',
\     'unix': 'xbuild server/OmniSharp.sln',
\   },
\ }
NeoBundle 'tokorom/clang_complete'
NeoBundle 'tokorom/clang_complete-getopts-ios'
NeoBundle 'fatih/vim-go'
" Lint
NeoBundle 'scrooloose/syntastic'
" Misc
NeoBundle 'taglist.vim'
NeoBundle 'jason0x43/vim-js-indent'
NeoBundle 'tpope/vim-rails'
NeoBundle 'tpope/vim-surround'
NeoBundle 'thinca/vim-poslist'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'scrooloose/nerdcommenter'
NeoBundle 'mattn/webapi-vim'
NeoBundle 'mattn/gist-vim'
NeoBundle 'thinca/vim-splash'
NeoBundle 'YankRing.vim'
NeoBundle 'matchit.zip'
NeoBundle 'Align'
NeoBundle 'thinca/vim-threes'
NeoBundle 'thinca/vim-singleton'
NeoBundle 'mattn/flappyvird-vim'
NeoBundle 'thinca/vim-localrc'
NeoBundle 'tpope/vim-projectionist'

call neobundle#end()
filetype plugin indent on
NeoBundleCheck
"------------------------------------------------------------------------------
" Color scheme
syntax enable
set background=dark
colorscheme solarized

if !has('gui_running')
  set t_Co=256
  let g:solarized_termcolors=256
  let g:solarized_termtrans = 1
  let g:solarized_contrast = 'high'
  let g:solarized_visibility = 'low'
endif

augroup highlightIdegraphicSpace
  autocmd!
  autocmd Colorscheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  autocmd VimEnter,WinEnter * match IdeographicSpace /　/
augroup END

if exists('+colorcolumn')
  autocmd Filetype * set colorcolumn=81
  autocmd Filetype Scratch set colorcolumn=''
endif

syntax on
"------------------------------------------------------------------------------
" Status line
set laststatus=2    " 常にステータスラインを表示
set statusline=%<%F\ %r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%4v(ASCII=%03.3b,HEX=%02.2B)\ %l/%L(%P)%m

" 入力モード時、ステータスラインのカラーを変更
augroup InsertHook
  autocmd!
  autocmd InsertEnter * highlight StatusLine guifg=#ccdc90 guibg=#2E4340
  autocmd InsertLeave * highlight StatusLine guifg=#2E4340 guibg=#ccdc90
augroup END
"------------------------------------------------------------------------------
" General settings
let mapleader = ","            " キーマップリーダー
set notitle                    " タイトル変更しない
set scrolloff=5                " スクロール時の余白確保
set nowritebackup              " バックアップファイルを作らない
set nobackup                   " バックアップ取らない。バックアップファイルを作っても削除
set noswapfile                 " スワップファイル作らない
set autoread                   " 他で書き換えられたら自動で読み直す
set hidden                     " 編集中でも他のファイルを開けるようにする
set backspace=indent,eol,start " バックスペースでなんでも消せるように
set formatoptions=lmoq         " テキスト整形オプション，マルチバイト系を追加
set vb t_vb=                   " ビープをならさない
set browsedir=buffer           " Exploreの初期ディレクトリ
set whichwrap=b,s,h,l,<,>,[,]  " カーソルを行頭、行末で止まらないようにする
set showcmd                    " コマンドをステータス行に表示
set magic                      " 正規表現に使われる記号を有効にする
set nofoldenable               " 折り畳み無効
set noundofile                 " アンドゥファイルを生成しない
set nomodeline                 " ファイルごとにオプション指定する機能をオフ
set breakindent                " インデントのある長い行の折り返しの見た目を整える
"------------------------------------------------------------------------------
" View
set showcmd                                       " 入力中のコマンドを表示
set number                                        " 行番号表示
set numberwidth=6                                 " 行番号の幅
set ruler                                         " ルーラーの表示
set list                                          " 不可視文字表示
set listchars=tab:>.,trail:_,extends:>,precedes:< " 不可視文字の表示形式
set display=uhex                                  " 印字不可能文字を16進数で表示

" 現在行にラインを引く
augroup cch
  autocmd! cch
  autocmd WinLeave * set nocursorline
  autocmd WinEnter,BufRead * set cursorline
augroup END
"------------------------------------------------------------------------------
" Indent
set autoindent
set smartindent
set cindent
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab " タブをスペースに展開
"------------------------------------------------------------------------------
" Command complement and history
set wildmenu            " コマンド補完を強化
set wildchar=<tab>      " コマンド補完を開始するキー
set wildmode=list:full  " リスト表示，最長マッチ
set history=1000        " コマンド・検索パターンの履歴数
set complete+=k         " 補完に辞書ファイル追加
"------------------------------------------------------------------------------
" Search settings
set nowrapscan          " 最後まで検索したら先頭へ戻らない
set ignorecase          " 大文字小文字無視
set smartcase           " 大文字ではじめたら大文字小文字無視しない
set incsearch           " インクリメンタルサーチ
set hlsearch            " 検索文字をハイライト

if executable('ag')
  set grepprg=ag\ --nogroup\ -is
  set grepformat=%f:%l:%m
elseif executable('ack')
  set grepprg=ack\ --nogroup
  set grepformat=%f:%l:%m
else
  set grepprg=grep\ -Hnd\ skip\ -r
  set grepformat=%f:%l:%m,%f:%l%m,%f\ \ %l%m
endif

" 選択した文字列を検索
vnoremap <silent> // y/<C-R>=escape(@", '\\/.*$^~[]')<CR><CR>

" 選択した文字列の出現回数をカウント
vnoremap <silent> /n y:%s/<C-R>=escape(@", '\\/.*$^~[]')<CR>/&/gn<CR>

" 選択した文字列を置換
vnoremap /r "xy:%s/<C-R>=escape(@x, '\\/.*$^~[]')<CR>/<C-R>=escape(@x, '\\/.*$^~[]')<CR>/gc<Left><Left><Left>

" 選択した文字列を Grep
vnoremap /g y:Unite -no-quit grep:.::<C-R>=escape(@", '\\.*$^[]')<CR><CR>
"------------------------------------------------------------------------------
" Encodings
set ffs=unix,dos,mac    " 改行
let $LANG='ja_JP.UTF-8' " Default
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
" Key mappings

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
nmap <silent> L :nohl<CR>

" qq でレジスタに記憶しないようにする
nmap qq <ESC>

" コマンドモードでの補完
cmap <C-p> <Up>
cmap <C-n> <Down>

" usキーボードで使いやすく
nmap ; :
vmap ; :

" HTML 閉じタグ補完
augroup MyXML
  autocmd!
  autocmd Filetype xml inoremap <buffer> </ </<C-x><C-o>
  autocmd Filetype html inoremap <buffer> </ </<C-x><C-o>
  autocmd Filetype eruby inoremap <buffer> </ </<C-x><C-o>
augroup END
"------------------------------------------------------------------------------
" Filetype detection
au BufRead,BufNewFile *.cson set filetype=coffee
au BufRead,BufNewFile *.jsenv set filetype=javascript
au BufRead,BufNewFile *.coffeeenv set filetype=coffee
au BufRead,BufNewFile *.jmk set filetype=javascript
au BufRead,BufNewFile *.prefab set filetype=yaml
au BufRead,BufNewFile *.json set filetype=json
au BufRead,BufNewFile *.contract set filetype=ruby
au BufRead,BufNewFile *.shader set filetype=hlsl
au BufRead,BufNewFile Guardfile set filetype=ruby
"------------------------------------------------------------------------------
" Custom commands

" 現在開いているディレクトリをルートディレクトリに
command! Cd :cd %:h

" ファイル名変更
command! -nargs=+ -bang -complete=file Rename let pbnr=fnamemodify(bufname('%'), ':p')|exec 'f '.escape(<q-args>, ' ')|w<bang>|call delete(pbnr)

" エンコード指定してファイルを開く
command! -nargs=1 Reload :e ++enc=<f-args>

" 末尾スペース削除
command! Rstrip :%s/\s\+$//e

" 差分確認
command! -nargs=1 -complete=file D vertical diffsplit <args>

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
" Utilities

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

" Windowsバックスラッシュ対策 Vundleを使っているのでコメントアウト
"set shellslash

" クリップボードを使用
set clipboard+=unnamed
"------------------------------------------------------------------------------
" matchit.vim
let b:match_words="{{t:{{/t}}" " % で対応するフレーズに移動
"------------------------------------------------------------------------------
" nerd_commenter.vim
let NERDSpaceDelims = 1
let NERDShutUp = 1
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
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_camel_case_completion = 1
let g:neocomplete#enable_underbar_completion = 1
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
  \ 'default' : '',
  \ 'vimshell' : $HOME.'/.vimshell_hist',
  \ 'scheme' : $HOME.'/.gosh_completions',
  \ 'c' : $DOTVIM.'/dict/c-eglibc.dict',
  \ 'objc' : $DOTVIM.'/dict/objectivec.dict',
  \ 'ruby' : $DOTVIM.'/dict/ruby.dict',
  \ 'perl' : $DOTVIM.'/dict/perl.dict',
  \ 'css' : $DOTVIM.'/dict/css.dict',
  \ 'javascript' : $DOTVIM.'/dict/javascript.dict',
  \ 'coffee' : $DOTVIM.'/dict/javascript.dict',
  \ 'actionscript' : $DOTVIM.'/dict/actionscript.dict'
  \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
  let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g> neocomplete#undo_completion()
inoremap <expr><C-l> neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  " For no inserting <CR> key.
  return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ neocomplete#start_manual_complete()
function! s:check_back_space() "{{{
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction"}}}
" dot: completion.
" inoremap <expr> . pumvisible() ? neocomplete#smart_close_popup().".\<C-X>\<C-O>\<C-P>" : ".\<C-X>\<C-O>\<C-P>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><C-y> neocomplete#close_popup()
inoremap <expr><C-e> neocomplete#cancel_popup()
" Close popup by <Space>.
inoremap <expr><Space> pumvisible() ? neocomplete#close_popup()."\<Space>" : "\<Space>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd FileType c set omnifunc=ccomplete#Complete
autocmd FileType cpp set omnifunc=cppcomplete#Complete
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType typescript setlocal omnifunc=tsuquyomi#complete
autocmd FileType cs setlocal omnifunc=OmniSharp#Complete
" autocmd FileType ruby,eruby setlocal omnifunc=rubycomplete#Complete
" autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
" autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
" autocmd FileType ruby,eruby let g:rubycomplete_rails = 1

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
" let g:neocomplete#sources#omni#input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
let g:neocomplete#sources#omni#input_patterns.cs = '[^. \t]\.\%(\h\w*\)\?'
let g:neocomplete#sources#omni#input_patterns.javascript = '[^. *\t]\.\w*\|\h\w*::'
let g:neocomplete#sources#omni#input_patterns.objc = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplete#sources#omni#input_patterns.objcpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'"
let g:neocomplete#sources#omni#input_patterns.go = '[^. *\t]\.\w*'
if !exists('g:neocomplete#force_omni_input_patterns')
  let g:neocomplete#force_omni_input_patterns = {}
endif
let g:neocomplete#force_omni_input_patterns.typescript = '[^. \t]\.\%(\h\w*\)\?'

" For clang_complete
if !exists('g:neocomplete#force_omni_input_patterns')
  let g:neocomplete#force_omni_input_patterns = {}
endif
let g:neocomplete#force_overwrite_completefunc = 1
let g:neocomplete#force_omni_input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)\w*'
let g:neocomplete#force_omni_input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'
let g:neocomplete#force_omni_input_patterns.objc = '[^.[:digit:] *\t]\%(\.\|->\)\w*'
let g:neocomplete#force_omni_input_patterns.objcpp = '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'
let g:clang_complete_auto = 0
let g:clang_auto_select = 0
"let g:clang_use_library = 1
"------------------------------------------------------------------------------
" neosnippet
" Enable snipMate compatibility feature.
let g:neosnippet#enable_snipmate_compatibility = 1

" Tell Neosnippet about the other snippets
let g:neosnippet#snippets_directory=$DOTVIM.'/snippets'

" Plugin key-mappings.
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)

imap <expr><CR> neosnippet#expandable_or_jumpable() ?
  \ "\<Plug>(neosnippet_expand_or_jump)"
  \: "\<CR>"
smap <expr><CR> neosnippet#expandable_or_jumpable() ?
  \ "\<Plug>(neosnippet_expand_or_jump)"
  \: "\<CR>"
"------------------------------------------------------------------------------
" unite.vim
let g:unite_enable_start_insert = 1
let g:unite_update_time = 10
let g:unite_source_file_mru_limit = 10000
call unite#custom_source('file_rec/git', 'ignore_pattern', '\.log$')
call unite#custom_source('grep', 'ignore_pattern', '\.log$')

" 大文字小文字を区別しない
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1

if executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column --smart-case -U'
  let g:unite_source_grep_recursive_opt = ''
endif

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
nnoremap <silent> ,uu :<C-u>Unite file_rec/git<CR>

" grep
nnoremap <silent> ,ug :<C-u>Unite -no-quit grep:. -buffer-name=search-buffer<CR><BS>

autocmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings()
  nmap <buffer> i <Plug>(unite_insert_enter)
  imap <buffer> qq <Plug>(unite_exit)
  nmap <buffer> qq <Plug>(unite_exit)
  nmap <buffer> q <Plug>(unite_exit)
  imap <buffer> jj <Plug>(unite_insert_leave)
  imap <buffer> kk <Plug>(unite_insert_leave)
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
endfunction
"------------------------------------------------------------------------------
" vimfiler
let g:vimfiler_safe_mode_by_default = 0
nnoremap <silent> <C-e> :VimFilerBufferDir -simple<CR>

autocmd! FileType vimfiler call s:vimfiler_my_settings()
function! s:vimfiler_my_settings()
  nmap qq <Plug>(vimfiler_exit)
  nmap q <Plug>(vimfiler_exit)
  nmap <buffer><expr><CR> vimfiler#smart_cursor_map("\<Plug>(vimfiler_expand_tree)", "\<Plug>(vimfiler_edit_file)")
endfunction
"------------------------------------------------------------------------------
" Gist.vim
let g:gist_clip_command = 'pbcopy'
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 1
let g:gist_post_private = 1
"------------------------------------------------------------------------------
" poslist
nmap <C-f> <Plug>(poslist-next-pos)
imap <C-f> <C-o><Plug>(poslist-next-pos)
nmap <C-b> <Plug>(poslist-prev-pos)
imap <C-b> <C-o><Plug>(poslist-prev-pos)
"------------------------------------------------------------------------------
" syntastic
" :Errors エラー一覧表示
let g:syntastic_auto_loc_list = 1
let g:syntastic_mode_map = { 'mode': 'active',
  \ 'active_filetypes': [],
  \ 'passive_filetypes': ['html'] }
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_coffee_coffeelint_args = '-f ~/.vim/coffeelint.json'
" for objective-c
let g:syntastic_objc_check_header = 1
let g:syntastic_objc_auto_refresh_includes = 1
" for TypeScript
let g:syntastic_typescript_checkers = ['tslint']
" for Go
let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': ['go'] }
" let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck', 'go']
let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']
"------------------------------------------------------------------------------
" QuickRun
command! Q :QuickRun
let g:quickrun_config = {
\   "_" : {
\       "runner" : "vimproc",
\       "runner/vimproc/updatetime" : 60
\   },
\}
" quickrun.vim が実行していない場合には <C-c> を呼び出す
nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"
"------------------------------------------------------------------------------
" OmniSharp
let g:OmniSharp_host = "http://localhost:2000"
let g:OmniSharp_typeLookupInPreview = 1

"Showmatch significantly slows down omnicomplete
"when the first match contains parentheses.
set noshowmatch

"don't autoselect first item in omnicomplete, show if only one item (for preview)
set completeopt=longest,menuone
"------------------------------------------------------------------------------
" clang complete
let g:clang_complete_auto = 0
let g:clang_auto_select = 0

let g:clang_complete_getopts_ios_default_options = '-fblocks -fobjc-arc -D __IPHONE_OS_VERSION_MIN_REQUIRED=40300'
let g:clang_complete_getopts_ios_sdk_directory = '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator6.1.sdk'
let g:clang_complete_getopts_ios_ignore_directories = ["^\.git", "\.xcodeproj"]
"------------------------------------------------------------------------------
" vim-json
let g:vim_json_syntax_conceal = 0
"------------------------------------------------------------------------------
" vim-go
let g:go_fmt_command = "goimports"
let g:go_list_type = "quickfix"
