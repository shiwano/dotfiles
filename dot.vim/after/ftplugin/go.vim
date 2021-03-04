setlocal noexpandtab
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal listchars=tab:\ \ ,trail:_,extends:>,precedes:< " 不可視文字の表示形式

nnoremap od :LspDefinition<CR>
nnoremap oh :LspHover<CR>
nnoremap of :LspReferences<CR>
nnoremap oi :LspImplementation<CR>
nnoremap on :LspRename<CR>
nnoremap oe :LspDocumentDiagnostics<CR>
nnoremap os :LspCodeAction<CR>

nnoremap odd :DlvDebug<CR>
nnoremap odt :DlvTest<CR>
nnoremap odc :DlvClearAll<CR>
nnoremap odb :DlvToggleBreakpoint<CR>
" nnoremap odt :DlvToggleTracepoint<CR>
