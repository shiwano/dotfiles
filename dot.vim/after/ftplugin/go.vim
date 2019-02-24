setlocal noexpandtab
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2

nnoremap od :LspDefinition<CR>
nnoremap oh :LspHover<CR>
nnoremap of :LspReferences<CR>
nnoremap op :LspImplementation<CR>
nnoremap on :LspRename<cr>

nnoremap oi :GoImport<cr>
nnoremap ob :GoBuild<cr>
nnoremap ot :GoTest!<cr>
nnoremap ott :GoTestFunc!<cr>
nnoremap otb :GoTestCompile<cr>
nnoremap os :GoFillStruct<cr>
nnoremap or :GoRun<cr>

nnoremap odd :DlvTest<cr>
nnoremap odc :DlvClearAll<cr>
nnoremap odb :DlvToggleBreakpoint<cr>
nnoremap odt :DlvToggleTracepoint<cr>
