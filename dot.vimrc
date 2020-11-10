"------------------------------------------------------------------------------
set nocompatible " Vim!

let $TODAY = strftime('%Y%m%d')

if has("win32") || has("win64")
  let $DOTVIM = expand('~/vimfiles')
else
  let $DOTVIM = expand('~/.vim')
endif

if has("macunix")
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
"------------------------------------------------------------------------------
" Plugins
call plug#begin('~/.vim/plugged')

" Color scheme
Plug 'chriskempson/base16-vim'

" Syntax highlight
Plug 'pangloss/vim-javascript'
Plug 'mustache/vim-mustache-handlebars'
Plug 'othree/html5-syntax.vim'
Plug 'groenewege/vim-less'
Plug 'hail2u/vim-css3-syntax'
Plug 'aklt/plantuml-syntax'
Plug 'elzr/vim-json'
Plug 'ekalinin/Dockerfile.vim'
Plug 'godlygeek/tabular' " required by vim-markdown
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
Plug 'google/vim-maktaba' " required by vim-bazel
Plug 'bazelbuild/vim-bazel'
Plug 'bfontaine/Brewfile.vim'
Plug 'jparise/vim-graphql'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'mechatroner/rainbow_csv'

" Finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Code completion
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-file.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'mattn/vim-lsp-settings'

" Input support
Plug 'kana/vim-smartinput'
Plug 'buoto/gotests-vim'
Plug 'kburdett/vim-nuuid'
Plug 'LeafCage/yankround.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'vim-scripts/Align'

" Debug
Plug 'sebdah/vim-delve'
Plug 'thinca/vim-quickrun'

" Lint
Plug 'w0rp/ale'

" Format
Plug 'rhysd/vim-clang-format', { 'for': ['c', 'cpp', 'objc'] }
Plug 'fatih/vim-hclfmt'
Plug 'mattn/vim-goimports'
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'branch': 'release/1.x',
  \ 'for': [
    \ 'javascript', 'typescript', 'css', 'less', 'scss', 'json',
    \ 'graphql', 'markdown', 'vue', 'lua', 'php', 'python', 'ruby',
    \ 'html', 'swift' ] }

" Misc
Plug 'jmcantrell/vim-virtualenv'
Plug 'ruanyl/vim-gh-line'
Plug 'vim-scripts/taglist.vim'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-surround'
Plug 'thinca/vim-poslist'
Plug 'thinca/vim-splash'
Plug 'vim-scripts/matchit.zip'
Plug 'thinca/vim-singleton'
Plug 'thinca/vim-localrc'
Plug 'tpope/vim-projectionist'
Plug 'soramugi/auto-ctags.vim', { 'for': ['c', 'cpp'] }
Plug 'danro/rename.vim'
Plug 'thinca/vim-qfreplace'

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
set laststatus=2 " always show status line
set statusline=%<%F\ %r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%4v(ASCII=%03.3b,HEX=%02.2B)\ %l/%L(%P)%m

" 入力モード時、ステータスラインのカラーを変更
augroup InsertHook
  autocmd!
  autocmd InsertEnter * highlight StatusLine ctermfg=White ctermbg=DarkGrey
  autocmd InsertLeave * highlight StatusLine ctermfg=20 ctermbg=19
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
set nomodeline                 " ファイルごとにオプション指定する機能をオフ
set breakindent                " インデントのある長い行の折り返しの見た目を整える
set undofile                   " アンドゥファイルを作成する
set undodir=$DOTVIM/undo       " アンドゥファイルの出力先
set clipboard+=unnamed         " クリップボードとの連携を有効にする
"------------------------------------------------------------------------------
" View
set showcmd                                       " 入力中のコマンドを表示
set number                                        " 行番号表示
set numberwidth=6                                 " 行番号の幅
set ruler                                         " ルーラーの表示
set list                                          " 不可視文字表示
set listchars=tab:>.,trail:_,extends:>,precedes:< " 不可視文字の表示形式
set display=uhex                                  " 印字不可能文字を16進数で表示
set viminfo='5000                                 " file history length

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

" move to last cursor position
augroup lastCursor
  au BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
  \ exe "normal g`\"" | endif
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
" Current buffer search
set nowrapscan " 最後まで検索したら先頭へ戻らない
set ignorecase " 大文字小文字無視
set smartcase  " 大文字ではじめたら大文字小文字無視しない
set incsearch  " インクリメンタルサーチ
set hlsearch   " 検索文字をハイライト

" 選択した文字列を検索
vnoremap <silent> // y/<C-R>=escape(@", '\\/.*$^~[]')<CR><CR>

" 選択した文字列の出現回数をカウント
vnoremap <silent> /n y:%s/<C-R>=escape(@", '\\/.*$^~[]')<CR>/&/gn<CR>

" 選択した文字列を置換
vnoremap /r "xy:%s/<C-R>=escape(@x, '\\/.*$^~[]')<CR>/<C-R>=escape(@x, '\\/.*$^~[]')<CR>/gc<Left><Left><Left>

" 選択した文字列を fzf で Grep
vnoremap /g y:Rg <C-R>=escape(@", '\\.*$^[]')<CR><CR>
"------------------------------------------------------------------------------
" Encodings
set ffs=unix,dos,mac
set encoding=utf-8
set fileencoding=utf-8

if !has('nvim')
  if has('win32') && has('kaoriya')
    set ambiwidth=auto
  else
    set ambiwidth=double
  endif
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
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
nnoremap ; :
vnoremap ; :

" disable recording q macro
nnoremap qq <ESC>
"------------------------------------------------------------------------------
" Filetype detection
au BufRead,BufNewFile *.prefab set filetype=yaml
au BufRead,BufNewFile *.shader set filetype=hlsl
au BufRead,BufNewFile Guardfile set filetype=ruby
au BufRead,BufNewFile Fastfile set filetype=ruby
au BufRead,BufNewFile .envrc* set filetype=sh
au BufRead,BufNewFile dot.zshrc set filetype=zsh
au BufRead,BufNewFile dot.tmux.conf set filetype=tmux
au BufRead,BufNewFile dot.gitconfig set filetype=gitconfig
au BufRead,BufNewFile *.jb set filetype=ruby
"------------------------------------------------------------------------------
" Custom commands

" 現在開いているディレクトリをルートディレクトリに
command! Cd :cd %:h

" エンコード指定してファイルを開く
command! -nargs=1 Enc :e ++enc=<f-args>

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
    %s///g
  catch
  endtry
endfunction

" Toggle expandtab
command! TabToggle :call s:tabToggle()
function! s:tabToggle()
  if &expandtab
    set noexpandtab
  else
    set expandtab
  endif
endfunction

" Reload .vimrc
command! Reload :source ~/.vimrc

" Open the specific buffer
command! -nargs=1 BufSel :call s:bufSel("<args>")
function! s:bufSel(pattern)
  let bufcount = bufnr("$")
  let currbufnr = 1
  let nummatches = 0
  let firstmatchingbufnr = 0
  while currbufnr <= bufcount
    if(bufexists(currbufnr))
      let currbufname = bufname(currbufnr)
      if(match(currbufname, a:pattern) > -1)
        echo currbufnr . ": ". bufname(currbufnr)
        let nummatches += 1
        let firstmatchingbufnr = currbufnr
      endif
    endif
    let currbufnr = currbufnr + 1
  endwhile
  if(nummatches == 1)
    execute ":buffer " . firstmatchingbufnr
  elseif(nummatches > 1)
    let desiredbufnr = input("Enter buffer number: ")
    if(strlen(desiredbufnr) != 0)
      execute ":buffer ". desiredbufnr
    endif
  else
    echo "No matching buffers"
  endif
endfunction
"------------------------------------------------------------------------------
" Memo
command! SaveMemo :call s:saveMemo()
function! s:saveMemo()
  try
    w $HOME/Dropbox/Memo/$TODAY-$RANDOM.md
  catch
  endtry
endfunction

command! -bang -nargs=* SearchMemo
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>).' ~/Dropbox/Memo', 1,
  \   fzf#vim#with_preview(), <bang>0)
"------------------------------------------------------------------------------
" Tags
set tags=$DOTVIM/mytags

if has('path_extra')
  set tags+=tags;
endif
"------------------------------------------------------------------------------
" Terminal
if has('nvim')
  command! T :call s:T()
  function! s:T()
    if exists('s:term_buf_name') && !empty(s:term_buf_name)
      call s:bufSel(s:term_buf_name)
    else
      terminal
      let s:term_buf_name = bufname('%')
    endif
    normal i
  endfunction

  function! s:close_terminal()
    if exists('s:term_buf_name') && !empty(s:term_buf_name) && bufname('%') == s:term_buf_name
      execute "normal \<C-O>"
      return
    endif
    bd!
  endfunction

  nnoremap <silent> <C-z> :T<CR>
  tnoremap <silent> <ESC> <C-\><C-n>

  tnoremap <silent> qq <C-\><C-n>:call <SID>close_terminal()<CR>
  tnoremap <silent> fg<CR> <C-\><C-n>:call <SID>close_terminal()<CR>
  tnoremap <silent> exit<CR> <C-\><C-n>:call <SID>close_terminal()<CR>
  tnoremap <silent> <C-z> <C-\><C-n>:call <SID>close_terminal()<CR>
  tnoremap <silent> <C-o> <C-\><C-n>:call <SID>close_terminal()<CR>

  autocmd TermOpen * setlocal scrollback=1000
  autocmd BufEnter,BufWinEnter,WinEnter term://* startinsert
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

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<cr>"
imap <c-space> <Plug>(asyncomplete_force_refresh)

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <TAB>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ asyncomplete#force_refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
"------------------------------------------------------------------------------
" vim-lsp
let g:lsp_async_completion = 1
let g:lsp_signs_enabled = 0
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_highlights_enabled = 0
let g:lsp_diagnostics_enabled = 0

" function! s:change_lsp_settings()
  " let g:lsp_diagnostics_enabled = 0
" endfun

" augroup VimLsp
  " autocmd!
  " autocmd FileType go call s:change_lsp_settings()
" augroup END
"------------------------------------------------------------------------------
" vim-lsp-settings
let g:lsp_settings_filetype_go = ['gopls']
let g:lsp_settings = {}
let g:lsp_settings['gopls'] = {
  \  'workspace_config': {
  \    'usePlaceholders': v:true,
  \    'analyses': {
  \      'fillstruct': v:true,
  \    },
  \  },
  \  'initialization_options': {
  \    'usePlaceholders': v:true,
  \    'analyses': {
  \      'fillstruct': v:true,
  \    },
  \  },
  \}
"------------------------------------------------------------------------------
" asyncomplete-buffer.vim
call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
    \ 'name': 'buffer',
    \ 'whitelist': ['*'],
    \ 'blacklist': ['go', 'typescript', 'typescript.tsx', 'javascript', 'javascript.jsx', 'vue'],
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
" vim-javascript
let g:javascript_plugin_jsdoc = 1
"------------------------------------------------------------------------------
" vim-prettier
let g:prettier#autoformat = 0
let g:prettier#quickfix_enabled = 0
let g:prettier#exec_cmd_async = 1
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.vue,*.html PrettierAsync
"------------------------------------------------------------------------------
" ale
highlight ALEWarning ctermbg=darkgray
let g:ale_linters = {
      \ 'go': ['gobuild', 'golangci-lint'],
      \ }
let g:ale_go_golangci_lint_options = ''
let g:ale_go_golangci_lint_package = 1
"------------------------------------------------------------------------------
" vim-gh-line
let g:gh_line_map_default = 0
let g:gh_line_blame_map_default = 0
let g:gh_line_map = 'og'
let g:gh_line_blame_map = 'ob'
let g:gh_use_canonical = 0
"------------------------------------------------------------------------------
" fzf
let g:fzf_layout = {
      \ 'up': '~40%' }

let g:fzf_action = {
      \ 'ctrl-q': 'topleft copen',
      \ 'ctrl-t': 'tab split',
      \ 'ctrl-x': 'split',
      \ 'ctrl-v': 'vsplit' }

function! s:fzf_search()
  let text = input('Search: ')
  if len(text) > 0
    exec 'Rg ' . text
  endif
endfunction

function! s:fzf_gitfile_buffer_dir_recursive()
  let git_root = split(system('git rev-parse --show-toplevel'), '\n')[0]
  let root = v:shell_error ? '' : git_root
  let buffer_dir = substitute(expand('%:p:h'), root.'/\?', '', 'g')
  let cwd = root == '' ? getcwd() : git_root

  if buffer_dir =~ '^/'
    call fzf#vim#files(expand('%:p:h'), {}, 0)
  elseif len(buffer_dir) > 0
    call fzf#vim#files(cwd, {'options': ['--prompt=> ',  '--query=^' . buffer_dir . '/ ']}, 0)
  else
    call fzf#vim#files(cwd, {'options': ['--prompt=> ']}, 0)
  endif
endfunction

nnoremap <silent> ,uf :call <SID>fzf_gitfile_buffer_dir_recursive()<CR>
nnoremap <silent> ,uu :GFiles <C-R>=getcwd()<CR><CR>
nnoremap <silent> ,us :GFiles?<CR>
nnoremap <silent> ,ub :Buffers<CR>
nnoremap <silent> ,um :History<CR>
nnoremap <silent> ,ua :Files <C-R>=getcwd()<CR><CR>
nnoremap <silent> ,ug :call <SID>fzf_search()<CR>
"------------------------------------------------------------------------------
" netrw
nnoremap <silent> ,ud :Hexplore!<CR>
let g:netrw_liststyle=1
let g:netrw_banner=0
let g:netrw_sizestyle="H"
let g:netrw_timefmt="%Y/%m/%d(%a) %H:%M:%S"
let g:netrw_preview=0

augroup Netrw
  au!
  autocmd FileType netrw :call s:setup_netrw()
augroup END

function! s:setup_netrw()
  nnoremap <buffer> qq :q<CR>
endfunction
