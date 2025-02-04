"------------------------------------------------------------------------------
set nocompatible " Vim!
scriptencoding utf-8

if has("win32") || has("win64")
  let $DOTVIM = expand('~/vimfiles')
else
  let $DOTVIM = expand('~/.vim')
endif

if has("macunix")
  augroup cpp_path
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
lua <<EOF
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

require("lazy").setup({
  spec = {
    -- Colorscheme
    { "RRethy/nvim-base16" },

    -- Syntax highlighting
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "mechatroner/rainbow_csv" },
    { "brenoprata10/nvim-highlight-colors" },

    -- Finder
    { "kevinhwang91/nvim-bqf" },
    { "junegunn/fzf" },
    { "junegunn/fzf.vim" },

    -- Code completion and LSP
    { "neoclide/coc.nvim", branch = "release" },
    { "github/copilot.vim" },

    -- Coding utilities
    { "kana/vim-smartinput" },
    { "buoto/gotests-vim" },
    { "kburdett/vim-nuuid" },
    { "LeafCage/yankround.vim" },
    { "vim-scripts/Align" },
    { "folke/ts-comments.nvim" },
    { "machakann/vim-sandwich" },
    { "danro/rename.vim" },
    { "thinca/vim-qfreplace" },
    { "arthurxavierx/vim-caser" },

    -- Debugging
    { "sebdah/vim-delve" },
    { "thinca/vim-quickrun" },

    -- Linting
    { "w0rp/ale" },

    -- Code formatter
    { "rhysd/vim-clang-format", ft = { "c", "cpp", "objc" } },
    { "mattn/vim-goimports" },
    { "prettier/vim-prettier", build = "yarn install" },
    { "dart-lang/dart-vim-plugin" },
    { "moorereason/vim-markdownfmt" },

    -- Documentation and Image
    { "3rd/image.nvim" },
    { "3rd/diagram.nvim", dependencies = { "3rd/image.nvim" } },
    { "iamcco/markdown-preview.nvim", build = "cd app && yarn install" },
    { "MeanderingProgrammer/render-markdown.nvim" },

    -- Misc
    { "ruanyl/vim-gh-line" },
    { "tpope/vim-rails" },
    { "thinca/vim-localrc" },
    { "tpope/vim-projectionist" },
  },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = false },
})
EOF
"------------------------------------------------------------------------------
" Color scheme
if !has('gui_running') && &term =~ '^\%(screen\|tmux\)'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

syntax enable

if (has("termguicolors"))
  set termguicolors
  set t_Co=256
endif

if !exists('g:colors_name') || g:colors_name != 'base16-tomorrow-night'
  colorscheme base16-tomorrow-night
endif

augroup highlight_idegraphic_space
  autocmd!
  autocmd Colorscheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  autocmd VimEnter,WinEnter * match IdeographicSpace /　/
augroup END

if exists('+colorcolumn')
  augroup colorcolumn
    autocmd!
    autocmd Filetype * set colorcolumn=81
    autocmd Filetype Scratch set colorcolumn=''
  augroup END
endif

syntax on
"------------------------------------------------------------------------------
" Status line
set laststatus=2 " always show status line
set statusline=%<%F\ %r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%4v(ASCII=%03.3b,HEX=%02.2B)\ %l/%L(%P)%m

" Change the color of the status line in input mode
augroup insert_hook
  autocmd!
  autocmd InsertEnter * highlight StatusLine ctermfg=White ctermbg=DarkGrey
  autocmd InsertLeave * highlight StatusLine ctermfg=20 ctermbg=19
augroup END
"------------------------------------------------------------------------------
" General settings
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
set backupcopy=yes             " Make a copy of the file and overwrite the original one.
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
augroup last_cursor
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
nnoremap qa qa<ESC>
nnoremap gf gF

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
vnoremap /g y:Rg <C-R>=escape(@", '\\.*$+?^[]\\(\\)\\{\\}\\|')<CR><CR>

" Toggle comment out.
vmap <Leader>cs gc
nmap <Leader>cs gcc
vmap <Leader>c<Space> gc
nmap <Leader>c<Space> gcc
"------------------------------------------------------------------------------
" Filetype detection
au BufRead,BufNewFile *.prefab set filetype=yaml
au BufRead,BufNewFile *.shader set filetype=hlsl
au BufRead,BufNewFile Guardfile set filetype=ruby
au BufRead,BufNewFile Fastfile set filetype=ruby
au BufRead,BufNewFile Appfile set filetype=ruby
au BufRead,BufNewFile .envrc* set filetype=sh
au BufRead,BufNewFile dot.zshrc set filetype=zsh
au BufRead,BufNewFile dot.tmux.* set filetype=tmux
au BufRead,BufNewFile dot.gitconfig set filetype=gitconfig
au BufRead,BufNewFile *.jb set filetype=ruby
"------------------------------------------------------------------------------
" Custom commands

" 現在開いているディレクトリに移動
command! Cd :cd %:h

" エンコード指定してファイルを開く
command! -nargs=1 Enc :e ++enc=<f-args>

" 末尾スペース削除
command! Rstrip :%s/\s\+$//e

" 差分確認
command! -nargs=1 -complete=file D vertical diffsplit <args>

" 改行コードをLF、エンコーディングをutf-8の状態にする
command! Normalize :call <SID>normalize()
function! s:normalize()
  set ff=unix
  set fenc=utf-8
  try
    %s///g
  catch
  endtry
endfunction

" Toggle expandtab
command! TabToggle :call <SID>tab_toggle()
function! s:tab_toggle()
  if &expandtab
    set noexpandtab
  else
    set expandtab
  endif
endfunction

command! Reload :source ~/.vimrc

command! RandomNumber :call <SID>insert_random_number()
function! s:insert_random_number()
  let input_digit = input('Number of digits (default=10):')
  if input_digit == ''
    let digit = 10
  else
    let digit = str2nr(input_digit)
  endif
  if digit < 1
    echoerr 'invalid number'
    return
  endif
  let max_num = str2nr('9' . repeat('0', digit - 1))
  let rand_num = rand() % max_num
  let insert_text = string(rand_num)
  let current_line = getline('.')
  let col_idx = col('.') - 1
  let new_line = strpart(current_line, 0, col_idx) . insert_text . strpart(current_line, col_idx)
  call setline('.', new_line)
  call cursor(line('.'), col_idx + len(insert_text) + 1)
endfunction

command! JSONFormat :call <SID>json_format()
function! s:json_format()
  %!jq .
endfunction
"------------------------------------------------------------------------------
" Memo
command! SaveMemo :call <SID>save_memo()
function! s:save_memo()
  let today = strftime('%Y%m%d')
  let rnd = rand()
  let filename = expand('$HOME') . '/Dropbox/Memo/' . today . '-' . rnd . '.md'
  try
    execute 'w ' . filename
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
  command! T :call <SID>t()
  function! s:t()
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

  augroup terminal_settings
    autocmd!
    " autocmd TermOpen term://*/bin/zsh* tnoremap <buffer> <silent> <C-j> <C-\><C-n><C-w>j
    " autocmd TermOpen term://*/bin/zsh* tnoremap <buffer> <silent> <C-k> <C-\><C-n><C-w>k
    " autocmd TermOpen term://*/bin/zsh* tnoremap <buffer> <silent> <C-h> <C-\><C-n><C-w>h
    " autocmd TermOpen term://*/bin/zsh* tnoremap <buffer> <silent> <C-l> <C-\><C-n><C-w>l
    autocmd TermOpen term://*/bin/zsh* tnoremap <buffer> <silent> <C-z> <C-\><C-n>:edit #<CR>
    autocmd TermOpen term://*/bin/zsh* tnoremap <buffer> <silent> exit<CR> <C-\><C-n>:edit #<CR>
    autocmd TermOpen term://*/bin/zsh* tnoremap <buffer> <silent> fg<CR> <C-\><C-n>:edit #<CR>
    autocmd TermOpen term://*/bin/zsh* setlocal scrollback=1000
    autocmd BufEnter,BufWinEnter,WinEnter term://* startinsert
  augroup END
endif
"------------------------------------------------------------------------------
" splash
" ref: https://github.com/thinca/vim-splash
lua <<EOF
local function splash()
  if vim.fn.argc() ~= 0 or vim.fn.bufnr('$') ~= 1 then return end
  local foldenable = vim.wo.foldenable
  local orig_bufnr = vim.api.nvim_get_current_buf()

  vim.cmd("hide enew")
  vim.bo.buftype   = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.wo.wrap      = false
  vim.wo.list      = false
  vim.wo.number    = false
  vim.wo.foldenable= false

  local content = {
    "                         ﾒ __-─-,-- _",
    "                       ,ｲ >:::::::::::< ヽ〟",
    "                 ヽ─イ /,::::,::::::::＼  ＞─r",
    "                   ヾ〟//:!:::ﾊ::::::|:!:ヽ ,丿",
    "                     ソ r:ﾘﾔ ハ::::::ﾊ:ﾊ::|rﾍ〟",
    "                     Ⅲ:|:| V―ﾍ::::/-ﾙﾞ|/ ﾊﾘ＼     Happy",
    "                     !|:ﾊ:|,-=〟ヽ／,-=.ｿﾊﾘ H        Vimming♡",
    "                     !ヽriｿﾞUｿｿﾞ   \"ﾊUｿﾉﾞhNﾉｿ",
    "                     |!ﾊヾヾ｀      ｀´ﾉlﾘ´",
    "                     ﾉ:ﾉﾊ ﾊ      丶     ｸﾊ        ____",
    "      _＿_______(ヽ/(ヾ/ﾊ,:ヽ    冖   ∠||ヽ _-==|リリ!)",
    "  ,-´￢￢─-─／＼＼ ＼ﾉ:ﾊ＼ゝ =- ハvﾉリ:ヾ丿::(⊃´ ｲ==-──´",
    " ((-====Ξ二二::-´＼ヾ ＼-ヾ::``丶^ )／|:!)!:::<(___/卜-'ヾ=-―´",
    "／ｿ  ／ﾊ／ ∠/ --===(  ) ⊂)ヽへ:::)==Η!ηv 》:!>====|≡≡)",
    "! ｀ !/ﾘ  ﾘ/:-==\"ヽ:ヽ'\"   |,   -ﾘﾘﾉ  |!＼乂  ヾ:ﾙ | ﾙ=-\"ヾヽ",
    "     | | ハヽ-=/:ﾘヽ::(>___|) -=='\" =-v-\"===ヽ》|| ﾊ ||ヾ)ﾊ",
    "     ﾊ ! !!ヾ !:/ﾘ/ヽ:ヽ   |/    ‖   /＼ Vim ヽ》 ! ||   ﾘ",
    "_＿／ｿ    V   //／'|ヽ:ﾊ) |Ｙ   ‖   /:::＼ !  }‖  !||   /",
    "             ‖  | |/ヽ!ﾘ | |   |   / |:::|＼ヽＶ   |||  (",
    "                 ＼＼ハ|| | |   |   ! |:::| ＼(!＼   ﾘ|   `",
    "                   ＼＼!| | | | |   / |:::|  ＼＼＼__!ﾉ",
    "                       )! | ヾ! /  /  ^::::^   ﾍ ヾ",
    "                      <,/ |  \" /  / __!--==-!__ ﾊ ヽ=-- __",
    "                  __====>ヾ／／ ／三二＝＝＝二三!＼＼--    =-- __",
    "               (-== イ    ／    ‖/ / /   | | ＼＼ ＼   ＼ ＼_=-|",
    "               ＼    ＼,∠     ‖/ / /    | |   ＼＼＼＼  ｀/  /",
    "                 ＼ ／ ＼      ﾙ ／      仝    !  ＼＼＼,／ ＼/",
    "                 (       >   ////    i   ||  |  i|  ＼＼＼    )",
    "                  ヽ ／_      //     |   ||  |   |   ヽヽ ゞ\"",
    "                    ヽヽ/￢/- <\" - _ |   Ｙ  |   ||   ヽヽ＜",
    "                      ^\"  /\"  '  ||  》 /  __|  _||    >  >",
    "                       > > |     || <_____=--_=--->_=->_=ﾞ",
    "                        ヾ_|    /::ヽ_   /    //   !   > >",
    "                            |／\":::::ヽ=/,   //    /<=-´",
    "                            |:::::|:::| |===//-===/´",
    "                            ヽ::::|:::|/:::::::::/",
    "                             |::::|:::ﾘ:::::/:::/",
    "                             |::::|::::ﾘ:::/:::/",
  }

  local new_bufnr = vim.api.nvim_get_current_buf()
  local restore_command = (orig_bufnr == new_bufnr and "enew" or orig_bufnr .. " buffer")
    .. " | let &l:foldenable = " .. (foldenable and 1 or 0)

  local sw, sh = vim.api.nvim_win_get_width(0), vim.api.nvim_win_get_height(0)
  local top_pad = math.floor((sh - #content) / 2)
  local max_width = 0
  for _, line in ipairs(content) do
    local w = vim.fn.strdisplaywidth(line)
    if w > max_width then max_width = w end
  end
  local left_pad = string.rep(" ", math.floor((sw - max_width) / 2))

  local lines = {}
  for _ = 1, top_pad do
    lines[#lines+1] = ""
  end
  for _, line in ipairs(content) do
    lines[#lines+1] = left_pad .. line
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.cmd("redraw")
  local raw = vim.fn.getchar()
  local ch = type(raw) == "number" and vim.fn.nr2char(raw) or raw
  if ch == ";" then
    ch = ":"
  end
  vim.cmd("silent! " .. restore_command)
  vim.api.nvim_feedkeys(ch, "n", false)
end

local group = vim.api.nvim_create_augroup("splash", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", { group = group, callback = splash })
vim.api.nvim_create_autocmd("StdinReadPre", {
  group = group,
  callback = function()
    vim.api.nvim_clear_autocmds({ group = group, event = "VimEnter" })
  end,
})
EOF
"------------------------------------------------------------------------------
" matchit.vim
let b:match_words="{{t:{{/t}}" " % で対応するフレーズに移動
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
" QuickRun
let g:quickrun_config = get(g:, 'quickrun_config', {})
let g:quickrun_config._ = {
      \ 'runner'    : 'system',
      \ 'outputter/buffer/split'  : ':rightbelow 16sp',
      \ 'outputter/buffer/close_on_empty' : 1,
      \ }
nnoremap tt :QuickRun<CR>
nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"
"------------------------------------------------------------------------------
" vim-qfreplace
nnoremap qf :Qfreplace<CR>
"------------------------------------------------------------------------------
" dart-vim-plugin
" let g:dart_style_guide = 2
let g:dart_format_on_save = 1
"------------------------------------------------------------------------------
" nuuid.vim
let g:nuuid_no_mappings = 1
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
nnoremap <silent> ol :ALEDetail<CR>

nnoremap <silent> ok :call <SID>show_documentation()<CR>
function! s:show_documentation()
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
command! -nargs=0 OR :call CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
"------------------------------------------------------------------------------
" vim-prettier
let g:prettier#autoformat = 0
let g:prettier#quickfix_enabled = 0
let g:prettier#exec_cmd_async = 1

augroup prettier_auto_group
  autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.graphql,*.vue PrettierAsync
augroup END

command! DisablePrettier :call <SID>disable_prettier()
function! s:disable_prettier()
  augroup prettier_auto_group
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

au BufRead,BufNewFile */.github/*/*.y{,a}ml
      \ let b:ale_linters = {'yaml': ['actionlint']}
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
    let escaped_text = escape(text, '\\.*$+?^[]\\(\\)\\{\\}\\|')
    exec 'Rg ' . escaped_text
  endif
endfunction

function! s:fzf_files_from_buffer_dir()
  let git_root = split(system('git rev-parse --show-toplevel'), '\n')[0]
  let is_git_repo = v:shell_error == 0
  let cwd = is_git_repo ? git_root : getcwd()
  let root = is_git_repo ? git_root : expand('%:p:h')
  let buffer_dir = substitute(expand('%:p:h'), root.'/\?', '', 'g')

  if buffer_dir =~ '^/'
    call fzf#vim#files(expand('%:p:h'), {}, 0)
  elseif len(buffer_dir) > 0
    call fzf#vim#files(cwd, fzf#vim#with_preview({'options': ['--prompt=> ',  '--query=^' . buffer_dir . '/ ']}), 0)
  else
    call fzf#vim#files(cwd, fzf#vim#with_preview({'options': ['--prompt=> ']}), 0)
  endif
endfunction

function! s:fzf_all_files_from_buffer_dir()
  let old_fzf_default_command = $FZF_DEFAULT_COMMAND
  let $FZF_DEFAULT_COMMAND=$FZF_COMMAND_NO_IGNORE
  call s:fzf_files_from_buffer_dir()
  let $FZF_DEFAULT_COMMAND=old_fzf_default_command
endfunction

nnoremap <silent> <Leader>uf :call <SID>fzf_files_from_buffer_dir()<CR>
nnoremap <silent> <Leader>uu :GFiles <C-R>=getcwd()<CR><CR>
nnoremap <silent> <Leader>us :GFiles?<CR>
nnoremap <silent> <Leader>ub :Buffers<CR>
nnoremap <silent> <Leader>ud :call <SID>fzf_all_files_from_buffer_dir()<CR>
nnoremap <silent> <Leader>um :History<CR>
nnoremap <silent> <Leader>ug :call <SID>fzf_search()<CR>
"------------------------------------------------------------------------------
" netrw
nnoremap <silent> <Leader>ue :Hexplore!<CR>
let g:netrw_liststyle=1
let g:netrw_banner=0
let g:netrw_sizestyle="H"
let g:netrw_timefmt="%Y/%m/%d(%a) %H:%M:%S"
let g:netrw_preview=0
let g:netrw_maxfilenamelen=80

augroup netrw
  au!
  autocmd FileType netrw :call <SID>setup_netrw()
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
  ignore_install = { },
}
EOF
"------------------------------------------------------------------------------
" vim-markdownfmt
let g:markdownfmt_command = 'markdownfmt'
let g:markdownfmt_options = ''
let g:markdownfmt_autosave=1
"------------------------------------------------------------------------------
" copilot.vim
inoremap <silent><script><expr> <C-l> exists('b:_copilot.suggestions') ? copilot#Accept("\<CR>") : copilot#Suggest()
inoremap <silent><script><expr> <C-j> copilot#Next()
inoremap <silent><script><expr> <C-k> copilot#Previous()
inoremap <silent><script><expr> <C-h> copilot#Dismiss()

let g:copilot_no_maps = v:true
let g:copilot_filetypes = {
  \ 'gitcommit': v:true,
  \ 'markdown': v:true,
  \ }
"------------------------------------------------------------------------------
" nvim-highlight-colors
lua <<EOF
require("nvim-highlight-colors").setup {
  enable_named_colors = false,
  enable_tailwind = false
}
EOF
"------------------------------------------------------------------------------
" neovide
if exists('g:neovide')
  nnoremap <D-=> :let g:neovide_scale_factor = g:neovide_scale_factor + 0.1<CR>
  vnoremap <D-=> :let g:neovide_scale_factor = g:neovide_scale_factor + 0.1<CR>

  nnoremap <D--> :let g:neovide_scale_factor = g:neovide_scale_factor - 0.1<CR>
  vnoremap <D--> :let g:neovide_scale_factor = g:neovide_scale_factor - 0.1<CR>

  nnoremap <D-0> :let g:neovide_scale_factor = 1<CR>
  vnoremap <D-0> :let g:neovide_scale_factor = 1<CR>

  let g:coc_node_path = trim(system('asdf which node'))
endif
"------------------------------------------------------------------------------
" image.nvim
lua <<EOF
require("image").setup({
  backend = "kitty",
  processor = "magick_rock",
  integrations = {
    markdown = {
      enabled = true,
      clear_in_insert_mode = true,
      download_remote_images = true,
      only_render_image_at_cursor = false,
      floating_windows = true, -- if true, images will be rendered in floating markdown windows
      filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
    },
    neorg = {
      enabled = true,
      filetypes = { "norg" },
    },
    typst = {
      enabled = true,
      filetypes = { "typst" },
    },
    html = {
      enabled = false,
    },
    css = {
      enabled = false,
    },
  },
  max_width = nil,
  max_height = nil,
  max_width_window_percentage = nil,
  max_height_window_percentage = 50,
  window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
  window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
  editor_only_render_when_focused = true, -- auto show/hide images when the editor gains/looses focus
  tmux_show_only_in_active_window = true, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
  hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif", "*.svg" }, -- render image files as images when opened
})
EOF
"------------------------------------------------------------------------------
" diagram.nvim
lua <<EOF
require("diagram").setup({
  integrations = {
    require("diagram.integrations.markdown"),
    require("diagram.integrations.neorg"),
  },
  renderer_options = {
    mermaid = {
      theme = "forest",
    },
    plantuml = {
      charset = "utf-8",
    },
    d2 = {
      theme_id = 1,
    },
    gnuplot = {
      theme = "dark",
      size = "800,600",
    },
  },
})
EOF
"------------------------------------------------------------------------------
" render-markdown.nvim
lua <<EOF
require('render-markdown').setup({
  pipe_table = {
    -- Turn on / off pipe table rendering
    enabled = true,
    -- Additional modes to render pipe tables
    render_modes = true,
    -- Pre configured settings largely for setting table border easier
    --  heavy:  use thicker border characters
    --  double: use double line border characters
    --  round:  use round border corners
    --  none:   does nothing
    preset = 'none',
    -- Determines how the table as a whole is rendered:
    --  none:   disables all rendering
    --  normal: applies the 'cell' style rendering to each row of the table
    --  full:   normal + a top & bottom line that fill out the table when lengths match
    style = 'full',
    -- Determines how individual cells of a table are rendered:
    --  overlay: writes completely over the table, removing conceal behavior and highlights
    --  raw:     replaces only the '|' characters in each row, leaving the cells unmodified
    --  padded:  raw + cells are padded to maximum visual width for each column
    --  trimmed: padded except empty space is subtracted from visual width calculation
    cell = 'trimmed',
    -- Amount of space to put between cell contents and border
    padding = 1,
    -- Minimum column width to use for padded or trimmed cell
    min_width = 0,
    -- Characters used to replace table border
    -- Correspond to top(3), delimiter(3), bottom(3), vertical, & horizontal
    -- stylua: ignore
    border = {
      '┌', '┬', '┐',
      '├', '┼', '┤',
      '└', '┴', '┘',
      '│', '─',
    },
    -- Gets placed in delimiter row for each column, position is based on alignment
    alignment_indicator = '━',
    -- Highlight for table heading, delimiter, and the line above
    head = 'RenderMarkdownTableHead',
    -- Highlight for everything else, main table rows and the line below
    row = 'RenderMarkdownTableRow',
    -- Highlight for inline padding used to add back concealed space
    filler = 'RenderMarkdownTableFill',
  },
})
EOF
