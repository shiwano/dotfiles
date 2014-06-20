"------------------------------------------------------------------------------
" フォント設定:
if has("win32") || has("win64")
  set guifont=VL_Gothic:h13
elseif has("macunix")
  set guifont=Osaka−等幅:h16
else
  set guifont=VL\ ゴシック\ 12
endif

"------------------------------------------------------------------------------
" カラースキーマ
syntax enable
set background=dark
colorscheme solarized

"------------------------------------------------------------------------------
" ウインドウの幅
set columns=128

" ウインドウの高さ
set lines=64

"------------------------------------------------------------------------------
" vim-singleton
let g:singleton#opener = 'new'
call singleton#enable()
