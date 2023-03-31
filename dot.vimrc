"------------------------------------------------------------------------------
set nocompatible " Vim!
scriptencoding utf-8

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
Plug 'RRethy/nvim-base16'

" Syntax highlight
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'mustache/vim-mustache-handlebars'
Plug 'aklt/plantuml-syntax'
Plug 'ekalinin/Dockerfile.vim'
Plug 'godlygeek/tabular' " required by vim-markdown
Plug 'plasticboy/vim-markdown'
Plug 'vim-scripts/ShaderHighLight'
Plug 'cespare/vim-toml'
Plug 'posva/vim-vue'
Plug 'hashivim/vim-terraform'
Plug 'shiwano/vim-hcl'
Plug 'chr4/nginx.vim'
Plug 'google/vim-maktaba' " required by vim-bazel
Plug 'bazelbuild/vim-bazel'
Plug 'bfontaine/Brewfile.vim'
Plug 'mechatroner/rainbow_csv'
Plug 'cespare/vim-go-templates'
Plug 'mattn/vim-gomod'
Plug 'aklt/plantuml-syntax'

" Finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Code completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

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
Plug 'Shougo/vimproc.vim', {'do' : 'make'}

" Lint
Plug 'w0rp/ale'

" Format
Plug 'rhysd/vim-clang-format', { 'for': ['c', 'cpp', 'objc'] }
Plug 'fatih/vim-hclfmt'
Plug 'mattn/vim-goimports'
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }

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
Plug 'arthurxavierx/vim-caser'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
Plug 'moorereason/vim-markdownfmt'
Plug 'github/copilot.vim'

call plug#end()
"------------------------------------------------------------------------------
" Color scheme
if !has('gui_running') && &term =~ '^\%(screen\|tmux\)'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

syntax enable

if (has("termguicolors"))
 set termguicolors
endif

if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif

augroup highlightIdegraphicSpace
  autocmd!
  autocmd Colorscheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  autocmd VimEnter,WinEnter * match IdeographicSpace /　/
augroup END

colorscheme base16-tomorrow-night

if exists('+colorcolumn')
  autocmd Filetype * set colorcolumn=81
  autocmd Filetype Scratch set colorcolumn=''
endif

syntax on
"------------------------------------------------------------------------------
" Status line
set laststatus=2 " always show status line
set statusline=%<%F\ %r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%4v(ASCII=%03.3b,HEX=%02.2B)\ %l/%L(%P)%m

" Change the color of the status line in input mode
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
set shortmess+=c               " Don't pass messages to |ins-completion-menu|.
set updatetime=300             " Avaid delays and poor user experienve (default is 4000 ms).
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

" Draw a line on the current line.
augroup cch
  autocmd! cch
  autocmd WinLeave * set nocursorline
  autocmd WinEnter,BufRead * set cursorline
augroup END

" Nowrap long lines in quickfix
augroup quickfix
  autocmd!
  autocmd FileType qf setlocal nowrap
augroup END

" Move to last cursor position
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
nnoremap : q:
vnoremap : q:

" Disable recording q macro.
nnoremap qq <ESC>

" Search for the selected string.
vnoremap <silent> // y/<C-R>=escape(@", '\\/.*$^~[]')<CR><CR>

" Count the number of times the selected string appears.
vnoremap <silent> /n y:%s/<C-R>=escape(@", '\\/.*$^~[]')<CR>/&/gn<CR>

" Replace the selected string.
vnoremap /r "xy:%s/<C-R>=escape(@x, '\\/.*$^~[]')<CR>/<C-R>=escape(@x, '\\/.*$^~[]')<CR>/gc<Left><Left><Left>

" Grep the selected string with fzf.
vnoremap /g y:Rg <C-R>=escape(@", '\\.*$^[]')<CR><CR>
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

command! Reload :source ~/.vimrc

command! -nargs=1 RandomNumber call s:insertRandomNumber(<args>)
function! s:insertRandomNumber(digit)
  let max_num = str2nr('9' . repeat('0', a:digit - 1))
  let rand_num = rand() % max_num
  call append(line("."), rand_num)
endfunction

command! JSONFormat :call s:JSONFormat()
function! s:JSONFormat()
  %!jq .
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
      call s:open_buf(s:term_buf_name)
    else
      terminal
      let s:term_buf_name = bufname('%')
    endif
    normal i
  endfunction

  function! s:open_buf(name)
    let bufcount = bufnr("$")
    let currbufnr = 1
    while currbufnr <= bufcount
      if(bufexists(currbufnr))
        let currbufname = bufname(currbufnr)
        if(currbufname == a:name)
          echo currbufnr . ": ". bufname(currbufnr)
          execute ":buffer " . currbufnr
          return
        endif
      endif
      let currbufnr = currbufnr + 1
    endwhile
    echo "No matching buffers"
  endfunction

  nnoremap <silent> <C-z> :T<CR>
  tnoremap <silent> <ESC> <C-\><C-n>

  " autocmd TermOpen term://*/bin/zsh* tnoremap <buffer> <silent> <C-j> <C-\><C-n><C-w>j
  " autocmd TermOpen term://*/bin/zsh* tnoremap <buffer> <silent> <C-k> <C-\><C-n><C-w>k
  " autocmd TermOpen term://*/bin/zsh* tnoremap <buffer> <silent> <C-h> <C-\><C-n><C-w>h
  " autocmd TermOpen term://*/bin/zsh* tnoremap <buffer> <silent> <C-l> <C-\><C-n><C-w>l
  autocmd TermOpen term://*/bin/zsh* tnoremap <buffer> <silent> <C-z> <C-\><C-n>:edit #<CR>
  autocmd TermOpen term://*/bin/zsh* tnoremap <buffer> <silent> exit<CR> <C-\><C-n>:edit #<CR>
  autocmd TermOpen term://*/bin/zsh* tnoremap <buffer> <silent> fg<CR> <C-\><C-n>:edit #<CR>
  autocmd TermOpen term://*/bin/zsh* setlocal scrollback=1000

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
nnoremap tt :QuickRun<CR>
nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"
"------------------------------------------------------------------------------
" vim-qfreplace
nnoremap qf :Qfreplace<CR>
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
" coc.nvim

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  " return !col || getline('.')[col - 1]  =~# '\s'
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

nmap <silent> od <Plug>(coc-definition)
nmap <silent> ot <Plug>(coc-type-definition)
nmap <silent> oi <Plug>(coc-implementation)
nmap <silent> of <Plug>(coc-references)
nmap <silent> on <Plug>(coc-rename)
nmap <silent> os <Plug>(coc-codeaction-selected)<down>
vmap <silent> os <Plug>(coc-codeaction-selected)<down>

nnoremap <silent> or :call CocAction('runCommand', 'editor.action.organizeImport')<CR>
nnoremap <silent> ok :call ShowDocumentation()<CR>
nnoremap <silent> ol :ALEDetail<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
" autocmd CursorHold * silent call CocActionAsync('highlight')

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
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

augroup PrettierAutoGroup
  autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.graphql,*.vue PrettierAsync
augroup END

command! DisablePrettier :call s:disable_prettier()
function! s:disable_prettier()
  augroup PrettierAutoGroup
    autocmd!
  augroup END
endfunction
"------------------------------------------------------------------------------
" ale
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
    call fzf#vim#files(cwd, fzf#vim#with_preview({'options': ['--prompt=> ',  '--query=^' . buffer_dir . '/ ']}), 0)
  else
    call fzf#vim#files(cwd, fzf#vim#with_preview({'options': ['--prompt=> ']}), 0)
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
let g:netrw_maxfilenamelen=80

augroup Netrw
  au!
  autocmd FileType netrw :call s:setup_netrw()
augroup END

function! s:setup_netrw()
  nnoremap <buffer> qq :q<CR>
endfunction
"------------------------------------------------------------------------------
" nvim-treesitter
lua <<EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    disable = {},
  },
  ensure_installed = 'all',
  ignore_install = { 'haskell', 'typescript', 'elixir', 'wgsl', 'wgsl_bevy', 'sql', 'gleam', 'markdown_inline' },
}
EOF
autocmd BufEnter,BufWinEnter,WinEnter *ts,*.tsx TSBufDisable highlight
"------------------------------------------------------------------------------
" vim-markdownfmt
let g:markdownfmt_command = 'markdownfmt'
let g:markdownfmt_options = ''
let g:markdownfmt_autosave=1
"------------------------------------------------------------------------------
" copilot.vim
inoremap <silent><script><expr> <CR> exists('b:_copilot.suggestions') ? copilot#Accept("\<CR>") : "\<CR>"
inoremap <silent><script><expr> <C-l> exists('b:_copilot.suggestions') ? copilot#Accept("\<CR>") : copilot#Suggest()
inoremap <silent><script><expr> <C-j> copilot#Next()
inoremap <silent><script><expr> <C-k> copilot#Previous()
inoremap <silent><script><expr> <C-h> copilot#Dismiss()

let g:copilot_no_maps = v:true
let g:copilot_filetypes = {
  \ '*': v:false,
  \ '.md': v:true,
  \ }
