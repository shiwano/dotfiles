setlocal noexpandtab
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal listchars=tab:\ \ ,trail:_,extends:>,precedes:< " 不可視文字の表示形式

nnoremap odd :DlvDebug<CR>
nnoremap odt :DlvTest<CR>
nnoremap odc :DlvClearAll<CR>
nnoremap odb :DlvToggleBreakpoint<CR>
nnoremap odr :DlvToggleTracepoint<CR>
