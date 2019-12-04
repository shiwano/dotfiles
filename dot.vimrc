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

  if isdirectory('/Library/Developer/CommandLineTools/usr/lib')
    let g:clang_library_path = '/Library/Developer/CommandLineTools/usr/lib/libclang.dylib'
  elseif isdirectory('/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib')
    let g:clang_library_path = '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang.dylib'
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
Plug 'chriskempson/base16-vim'
" Syntax highlight
Plug 'vim-scripts/jQuery'
Plug 'pangloss/vim-javascript'
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
Plug 'keith/swift.vim'
Plug 'hashivim/vim-terraform'
Plug 'shiwano/vim-hcl'
Plug 'chr4/nginx.vim'
Plug 'google/vim-maktaba'
Plug 'bazelbuild/vim-bazel'
Plug 'bfontaine/Brewfile.vim'
" Environment
Plug 'Shougo/unite.vim'
Plug 'Shougo/neomru.vim'
Plug 'Sixeight/unite-grep'
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'jmcantrell/vim-virtualenv'
" Code completion, debug
Plug 'kana/vim-smartinput'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'sebdah/vim-delve'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-file.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
" Lint and Format
Plug 'w0rp/ale'
Plug 'rhysd/vim-clang-format', { 'for': ['c', 'cpp', 'objc'] }
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'ruby-formatter/rufo-vim'
Plug 'fatih/vim-hclfmt'
" Misc
Plug 'ruanyl/vim-gh-line'
Plug 'vim-scripts/taglist.vim'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-surround'
Plug 'thinca/vim-poslist'
Plug 'thinca/vim-quickrun'
Plug 'scrooloose/nerdcommenter'
Plug 'mattn/webapi-vim'
Plug 'mattn/gist-vim'
Plug 'thinca/vim-splash'
Plug 'LeafCage/yankround.vim'
Plug 'vim-scripts/matchit.zip'
Plug 'vim-scripts/Align'
Plug 'thinca/vim-singleton'
Plug 'thinca/vim-localrc'
Plug 'tpope/vim-projectionist'
Plug 'buoto/gotests-vim'
Plug 'kburdett/vim-nuuid'
Plug 'soramugi/auto-ctags.vim', { 'for': ['c', 'cpp'] }
call plug#end()
"------------------------------------------------------------------------------
" Color scheme
syntax enable
colorscheme base16-default-dark

if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
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

" wrap long lines in quickfix
augroup quickfix
  autocmd!
  autocmd FileType qf setlocal wrap
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
" Command completion and history
set wildmenu           " コマンド補完を強化
set wildchar=<tab>     " コマンド補完を開始するキー
set wildmode=list:full " リスト表示，最長マッチ
set history=1000       " コマンド・検索パターンの履歴数
set complete+=k        " 補完に辞書ファイル追加
"------------------------------------------------------------------------------
" Search
set nowrapscan " 最後まで検索したら先頭へ戻らない
set ignorecase " 大文字小文字無視
set smartcase  " 大文字ではじめたら大文字小文字無視しない
set incsearch  " インクリメンタルサーチ
set hlsearch   " 検索文字をハイライト

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
au BufRead,BufNewFile *.prefab set filetype=yaml
au BufRead,BufNewFile *.shader set filetype=hlsl
au BufRead,BufNewFile Guardfile set filetype=ruby
au BufRead,BufNewFile Fastfile set filetype=ruby
au BufRead,BufNewFile .envrc* set filetype=sh
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

command! SaveMarkdownToDropbox :call s:SaveMarkdownToDropbox()
function! s:SaveMarkdownToDropbox()
  try
    w $HOME/Dropbox/Memo/$TODAY-$RANDOM.md
  catch
  endtry
endfunction

" Insert separator string.
command! Sep :call s:Sep()
function! s:Sep()
  execute ":normal i# =============================================================================="
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
set tags=$DOTVIM/mytags

if has('path_extra')
  set tags+=tags;
endif

set clipboard+=unnamed
"------------------------------------------------------------------------------
" Terminal
if has('nvim')
  nnoremap <silent> <C-z> :T<CR>
  tnoremap <silent> <ESC><ESC> <C-\><C-n>
  tnoremap <silent> <C-j> <C-\><C-n><C-w>j
  tnoremap <silent> <C-k> <C-\><C-n><C-w>k
  tnoremap <silent> <C-l> <C-\><C-n><C-w>l
  tnoremap <silent> <C-h> <C-\><C-n><C-w>h
  tnoremap <silent> fg<CR> <C-\><C-n>:bd!<CR>

  autocmd TermOpen * setlocal scrollback=100000
  autocmd BufEnter,BufWinEnter,WinEnter term://* startinsert

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
" yankround.vim
nmap p <Plug>(yankround-p)
xmap p <Plug>(yankround-p)
nmap P <Plug>(yankround-P)
nmap gp <Plug>(yankround-gp)
xmap gp <Plug>(yankround-gp)
nmap gP <Plug>(yankround-gP)
nmap <C-p> <Plug>(yankround-prev)
nmap <C-n> <Plug>(yankround-next)
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
" dart-vim-plugin
let g:dart_style_guide = 2
let g:dart_format_on_save = 1
"------------------------------------------------------------------------------
" nuuid.vim
let g:nuuid_no_mappings = 1
"------------------------------------------------------------------------------
" vim-terraform
let g:terraform_fmt_on_save = 1
"------------------------------------------------------------------------------
" asynccomplete
let g:asyncomplete_smart_completion = 1
let g:asyncomplete_auto_popup = 1
set completeopt=menuone

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<cr>"
imap <c-space> <Plug>(asyncomplete_force_refresh)
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif
autocmd InsertLeave * if pumvisible() == 0 | pclose | endif

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <TAB>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ asyncomplete#force_refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" go-lsp
let g:lsp_async_completion = 1
let g:lsp_signs_enabled = 0
let g:lsp_diagnostics_echo_cursor = 0
" let g:lsp_log_verbose = 1
" let g:lsp_log_file = expand('~/vim-lsp.log')
" let g:asyncomplete_log_file = expand('~/asyncomplete.log')

if executable('bingo')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'bingo',
        \ 'cmd': {server_info->['bingo', '-mode', 'stdio']},
        \ 'whitelist': ['go'],
        \ })
    autocmd FileType go setlocal omnifunc=lsp#complete
endif

if executable('dart_language_server')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'dart_language_server',
        \ 'cmd': {server_info->['dart_language_server']},
        \ 'whitelist': ['dart'],
        \ })
    autocmd FileType dart setlocal omnifunc=lsp#complete
endif

if executable('typescript-language-server')
  au User lsp_setup call lsp#register_server({
    \ 'name': 'typescript-language-server',
    \ 'cmd': { server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
    \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tsconfig.json'))},
    \ 'whitelist': ['typescript', 'javascript', 'javascript.jsx']
    \ })
  autocmd FileType typescript,javascript,javascript.jsx setlocal omnifunc=lsp#complete
endif

if executable('vls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'vls',
        \ 'cmd': { server_info->[&shell, &shellcmdflag, 'vls --stdio']},
        \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tsconfig.json'))},
        \ 'whitelist': ['vue'],
        \ })
    autocmd FileType vue setlocal omnifunc=lsp#complete
endif
"------------------------------------------------------------------------------
" asyncomplete-buffer.vim
call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
    \ 'name': 'buffer',
    \ 'whitelist': ['*'],
    \ 'blacklist': ['go', 'typescript', 'javascript', 'javascript.jsx', 'vue'],
    \ 'completor': function('asyncomplete#sources#buffer#completor'),
    \ }))
"------------------------------------------------------------------------------
" asyncomplete-file.vim
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
    \ 'name': 'file',
    \ 'whitelist': ['*'],
    \ 'priority': 10,
    \ 'completor': function('asyncomplete#sources#file#completor')
    \ }))
"------------------------------------------------------------------------------
" vim-hclfmt
let g:hcl_fmt_autosave = 1
let g:tf_fmt_autosave = 0
let g:nomad_fmt_autosave = 0
"------------------------------------------------------------------------------
" rufo-vim
let g:rufo_auto_formatting = 1
"------------------------------------------------------------------------------
" vim-javascript
let g:javascript_plugin_jsdoc = 1
