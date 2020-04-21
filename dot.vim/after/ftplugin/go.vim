setlocal noexpandtab
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal listchars=tab:\ \ ,trail:_,extends:>,precedes:< " 不可視文字の表示形式

nnoremap od :LspDefinition<CR>
nnoremap oh :LspHover<CR>
nnoremap of :LspReferences<CR>
nnoremap op :LspImplementation<CR>
nnoremap on :LspRename<cr>
nnoremap oe :LspDocumentDiagnostics<cr>

nnoremap odd :DlvTest<cr>
nnoremap odc :DlvClearAll<cr>
nnoremap odb :DlvToggleBreakpoint<cr>
nnoremap odt :DlvToggleTracepoint<cr>
