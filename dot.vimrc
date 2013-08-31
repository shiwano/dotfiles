"------------------------------------------------------------------------------
set nocompatible " Vim!
"------------------------------------------------------------------------------
" Variables
let $TODAY = strftime('%Y%m%d')
let $DESKTOP = expand('~/desktop')

if has("macunix")
  let $LUA_DLL = '/usr/local/Cellar/lua/5.1.5/lib/liblua.dylib'
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
  call neobundle#rc($DOTVIM.'/bundle')
endif

" NeoBundle
NeoBundle 'git://github.com/Shougo/neobundle.vim'
" Color scheme
NeoBundle 'ciaranm/inkpot'
NeoBundle 'altercation/vim-colors-solarized'
" Syntax highlight
NeoBundle 'jQuery'
NeoBundle 'jelera/vim-javascript-syntax'
NeoBundle 'nono/vim-handlebars'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'othree/html5-syntax.vim'
NeoBundle 'hallison/vim-markdown'
NeoBundle 'timcharper/textile.vim'
NeoBundle 'groenewege/vim-less'
NeoBundle 'wavded/vim-stylus'
NeoBundle 'hail2u/vim-css3-syntax'
NeoBundle 'digitaltoad/vim-jade'
NeoBundle 'leafgarland/typescript-vim'
" Environment
NeoBundle 'Shougo/unite.vim.git'
NeoBundle 'Sixeight/unite-grep'
NeoBundle 'Shougo/vimfiler'
NeoBundle 'thinca/vim-qfreplace'
NeoBundle 'Shougo/vimproc', {
\ 'build' : {
\     'windows' : 'make -f make_mingw32.mak',
\     'cygwin' : 'make -f make_cygwin.mak',
\     'mac' : 'make -f make_mac.mak',
\     'unix' : 'make -f make_unix.mak',
\    },
\ }
" Code completion
NeoBundle 'Shougo/neocomplete.vim'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'marijnh/tern_for_vim', {
\   'build': {
\     'windows': 'npm install',
\     'mac': 'npm install',
\     'unix': 'npm install',
\   }
\ }
NeoBundleLazy 'nosami/Omnisharp', {
\   'autoload': {'filetypes': ['cs']},
\   'build': {
\     'windows': 'MSBuild.exe server/OmniSharp.sln /p:Platform="Any CPU"',
\     'mac': 'xbuild server/OmniSharp.sln',
\     'unix': 'xbuild server/OmniSharp.sln',
\   }
\ }
" Reference
NeoBundle 'thinca/vim-ref'
NeoBundle 'mojako/ref-sources.vim'
" Source reading
NeoBundle 'wesleyche/SrcExpl'
NeoBundle 'wesleyche/Trinity'
NeoBundle 'taglist.vim'
NeoBundle 'scrooloose/nerdtree'
" Lint
NeoBundle 'scrooloose/syntastic'
" Misc
" NeoBundle 'fholgado/minibufexpl.vim'
NeoBundle 'jiangmiao/simple-javascript-indenter'
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

filetype plugin indent on
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
  let g:solarized_visibility = 'high'
endif

if exists('+colorcolumn')
  autocmd Filetype * set colorcolumn=81
  autocmd Filetype Scratch set colorcolumn=''
endif
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
set nobackup                   " バックアップ取らない。バックアップファイルを作っても削除。
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
" set autochdir                  " バッファを開いた時にカレントディレクトリを変更
"------------------------------------------------------------------------------
" View
set showcmd                                       " 入力中のコマンドを表示
set number                                        " 行番号表示
set numberwidth=6                                 " 行番号の幅
set ruler                                         " ルーラーの表示
set list                                          " 不可視文字表示
set listchars=tab:>.,trail:_,extends:>,precedes:< " 不可視文字の表示形式
set display=uhex                                  " 印字不可能文字を16進数で表示

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
set grepprg=grep\ -nHRn " grep

" 選択した文字列を検索
vnoremap <silent> // y/<C-R>=escape(@", '\\/.*$^~[]')<CR><CR>

" 選択した文字列を置換
vnoremap /r "xy:%s/<C-R>=escape(@x, '\\/.*$^~[]')<CR>/<C-R>=escape(@x, '\\/.*$^~[]')<CR>/gc<Left><Left><Left>

" 選択した文字列を Grep
vnoremap /g y:Unite -no-quit grep::-iHRn:<C-R>=escape(@", '\\.*$^[]')<CR><CR><BS>**/*
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

" CTRL-HJKLでバッファ移動
nmap <S-J> :bn<CR>
nmap <S-K> :bp<CR>
nmap <S-L> :bn<CR>
nmap <S-H> :bp<CR>

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
set clipboard=unnamed
" set clipboard=unnamedplus,unnamed
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
let g:neocomplete#enable_auto_close_preview = 0
let g:neocomplete#enable_camel_case_completion = 1
let g:neocomplete#enable_underbar_completion = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 2
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
  \ 'coffee' : $DOTVIM.'/dict/javascript.dict',
  \ 'actionscript' : $DOTVIM.'/dict/actionscript.dict'
  \ }
"  \ 'javascript' : $DOTVIM.'/dict/javascript.dict',

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
  return neocomplete#smart_close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
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
autocmd FileType ruby,eruby setlocal omnifunc=rubycomplete#Complete
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
let g:neocomplete#sources#omni#input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
let g:neocomplete#sources#omni#input_patterns.cs = '.*'
let g:neocomplete#sources#omni#input_patterns.typescript = '.*'
let g:neocomplete#sources#omni#input_patterns.javascript = '[^. *\t]\.\w*\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'"
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
nnoremap ,ug :Unite -no-quit grep::-iHRn<CR><BS>**/*

autocmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings()
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
" poslist
nmap <C-f> <Plug>(poslist-next-pos)
imap <C-f> <C-o><Plug>(poslist-next-pos)
nmap <C-b> <Plug>(poslist-prev-pos)
imap <C-b> <C-o><Plug>(poslist-prev-pos)
"------------------------------------------------------------------------------
" syntastic
" :Errors エラー一覧表示
" let g:syntastic_auto_loc_list = 1
let g:syntastic_mode_map = { 'mode': 'active',
  \ 'active_filetypes': [],
  \ 'passive_filetypes': ['html'] }
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_coffee_coffeelint_args = '-f ~/.vim/coffeelint.json'
let g:loaded_syntastic_typescript_tsc_checker = 1 " disable typescript linter
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
set completeopt=longest,menuone,preview

"Don't ask to save when changing buffers (i.e. when jumping to a type definition)
set hidden
