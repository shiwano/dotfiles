"------------------------------------------------------------------------------
set nocompatible " Vim!
"------------------------------------------------------------------------------
" Variables
let $TODAY = strftime('%Y%m%d')
let $DESKTOP = expand('~/desktop')

if has("macunix")
  let $LUA_DLL = '/usr/local/Cellar/lua/5.2.3_1/lib/liblua.dylib'

  augroup cpp-path
    autocmd!
    autocmd FileType cpp setlocal path=.,/usr/include,/usr/local/include,/usr/lib/c++/v1
  augroup END

  let s:clang_library_path='/Library/Developer/CommandLineTools/usr/lib'
  if isdirectory(s:clang_library_path)
    let g:clang_library_path = s:clang_library_path.'/libclang.dylib'
  endif
endif

if has("win32") || has("win64")
  let $DOTVIM = expand('~/vimfiles')
else
  let $DOTVIM = expand('~/.vim')
endif
"------------------------------------------------------------------------------
call plug#begin('~/.vim/plugged')
" Color scheme
Plug 'altercation/vim-colors-solarized'
" Syntax highlight
Plug 'vim-scripts/jQuery'
Plug 'jelera/vim-javascript-syntax'
Plug 'mustache/vim-mustache-handlebars'
Plug 'kchmck/vim-coffee-script'
Plug 'othree/html5-syntax.vim'
Plug 'timcharper/textile.vim'
Plug 'groenewege/vim-less'
Plug 'wavded/vim-stylus'
Plug 'hail2u/vim-css3-syntax'
Plug 'digitaltoad/vim-jade'
Plug 'leafgarland/typescript-vim'
Plug 'aklt/plantuml-syntax'
Plug 'gkz/vim-ls'
Plug 'elzr/vim-json'
Plug 'ekalinin/Dockerfile.vim'
Plug 'godlygeek/tabular' " vim-markdown required
Plug 'plasticboy/vim-markdown'
Plug 'vim-scripts/ShaderHighLight'
Plug 'cespare/vim-toml'
Plug 'posva/vim-vue'
Plug 'vim-jp/cpp-vim', { 'for': 'cpp' }
Plug 'dart-lang/dart-vim-plugin'
" Environment
Plug 'Shougo/unite.vim'
Plug 'Shougo/neomru.vim'
Plug 'Sixeight/unite-grep'
Plug 'Shougo/vimfiler'
Plug 'thinca/vim-qfreplace'
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'jmcantrell/vim-virtualenv'
" Code completion
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'mhartington/nvim-typescript', { 'for': ['typescript', 'vue'] }
Plug 'zchee/deoplete-go', { 'do': 'make', 'for': 'go' }
Plug 'kana/vim-smartinput'
Plug 'OmniSharp/omnisharp-vim', { 'for': 'cs', 'build': 'xbuild server/OmniSharp.sln' }
Plug 'fatih/vim-go', { 'for': 'go', 'do': ':GoInstallBinaries' }
Plug 'zchee/deoplete-jedi'
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
" Lint and Format
Plug 'scrooloose/syntastic'
Plug 'rhysd/vim-clang-format', { 'for': ['c', 'cpp', 'objc'] }
Plug 'Vimjas/vim-python-pep8-indent'
" Misc
Plug 'vim-scripts/taglist.vim'
Plug 'jason0x43/vim-js-indent'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-surround'
Plug 'thinca/vim-poslist'
Plug 'thinca/vim-quickrun'
Plug 'scrooloose/nerdcommenter'
Plug 'mattn/webapi-vim'
Plug 'mattn/gist-vim'
Plug 'thinca/vim-splash'
Plug 'vim-scripts/YankRing.vim'
Plug 'vim-scripts/matchit.zip'
Plug 'vim-scripts/Align'
Plug 'thinca/vim-singleton'
Plug 'thinca/vim-localrc'
Plug 'tpope/vim-projectionist'
Plug 'buoto/gotests-vim'
Plug 'soramugi/auto-ctags.vim', { 'for': ['c', 'cpp'] }
call plug#end()
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

nnoremap j gj
nnoremap k gk

nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz
nnoremap G Gzz
nnoremap aa @a

nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

nnoremap <silent> L :nohl<CR>
nnoremap qq <ESC>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
nnoremap ; :
vnoremap ; :
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
au BufRead,BufNewFile *.vue setlocal filetype=vue
au BufRead,BufNewFile Guardfile set filetype=ruby
au BufRead,BufNewFile Fastfile set filetype=ruby
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

" Toggle expandtab
command! TabToggle :call s:TabToggle()
function! s:TabToggle()
  if &expandtab
    set noexpandtab
  else
    set expandtab
  endif
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

" クリップボードを使用
set clipboard+=unnamed
"------------------------------------------------------------------------------
" terminal
if has('nvim')
  tnoremap <silent> <ESC> <C-\><C-n>
  tnoremap <silent> <C-j> <C-\><C-n><C-w>j
  tnoremap <silent> <C-k> <C-\><C-n><C-w>k
  tnoremap <silent> <C-l> <C-\><C-n><C-w>l
  tnoremap <silent> <C-h> <C-\><C-n><C-w>h

  autocmd TermOpen * setlocal scrollback=1

  command! T :call s:T()
  function! s:T()
    vsplit
    wincmd l
    vertical resize 100
    terminal
    normal i
  endfunction
endif
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
  \ 'passive_filetypes': ['html'] }
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_coffee_coffeelint_args = '-f ~/.vim/coffeelint.json'
" for objective-c
let g:syntastic_objc_check_header = 1
let g:syntastic_objc_auto_refresh_includes = 1
" for TypeScript
let g:syntastic_typescript_checkers = ['tslint']
" for Go
" let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck', 'go']
let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']
" for C++
" let g:syntastic_debug = 1
let g:syntastic_cpp_cpplint_exec = 'cpplint.py'
let g:syntastic_cpp_checkers = ['cpplint']
let g:syntastic_cpp_check_header = 1
"------------------------------------------------------------------------------
" QuickRun
let g:quickrun_config = get(g:, 'quickrun_config', {})
let g:quickrun_config._ = {
      \ 'runner'    : 'vimproc',
      \ 'runner/vimproc/updatetime' : 60,
      \ 'outputter/buffer/split'  : ':rightbelow 16sp',
      \ 'outputter/buffer/close_on_empty' : 1,
      \ }
nnoremap t :QuickRun<CR>
nnoremap tt :Q<CR>
nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"
"------------------------------------------------------------------------------
" OmniSharp
let g:OmniSharp_host = "http://localhost:2000"
let g:OmniSharp_typeLookupInPreview = 1
"------------------------------------------------------------------------------
" clang complete
let g:clang_user_options = '-std=c++11'

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
"------------------------------------------------------------------------------
" auto-tags
let g:auto_ctags = 1
let g:auto_ctags_tags_args = '--tag-relative --recurse --sort=yes'
"------------------------------------------------------------------------------
" vim-vue
autocmd FileType vue syntax sync fromstart
let g:ft = ''
function! NERDCommenter_before()
  if &ft == 'vue'
    let g:ft = 'vue'
    let stack = synstack(line('.'), col('.'))
    if len(stack) > 0
      let syn = synIDattr((stack)[0], 'name')
      if len(syn) > 0
        exe 'setf ' . substitute(tolower(syn), '^vue_', '', '')
      endif
    endif
  endif
endfunction
function! NERDCommenter_after()
  if g:ft == 'vue'
    setf vue
    let g:ft = ''
  endif
endfunction
"------------------------------------------------------------------------------
" deoplete
set completeopt=menuone
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_smart_case = 1

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ deoplete#mappings#manual_complete()
function! s:check_back_space() abort "{{{
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction"}}}

inoremap <expr><C-h> deoplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> deoplete#smart_close_popup()."\<C-h>"

inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function() abort
  return deoplete#close_popup() . "\<CR>"
endfunction

autocmd InsertLeave * if pumvisible() == 0 | pclose | endif

let g:nvim_typescript#vue_support = 1

let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']

if has("macunix")
  let g:deoplete#sources#go#cgo#libclang_path = g:clang_library_path
endif
"------------------------------------------------------------------------------
" LanguageClient-neovim
let g:LanguageClient_serverCommands = {
    \ 'dart': ['dart_language_server'],
    \ }
let g:LanguageClient_diagnosticsEnable = 0
