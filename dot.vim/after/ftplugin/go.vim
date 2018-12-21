setlocal noexpandtab
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2

nnoremap od :GoDef<cr>
nnoremap of :GoReferrers<cr>
nnoremap on :GoRename<cr>
nnoremap oc :GoCallees<cr>
nnoremap op :GoImplements<cr>
nnoremap oi :GoImport<cr>
nnoremap ob :GoBuild<cr>
nnoremap ot :GoTest!<cr>
nnoremap ott :GoTestFunc!<cr>
nnoremap otb :GoTestCompile<cr>
nnoremap os :GoFillStruct<cr>

nnoremap odd :DlvTest<cr>
nnoremap odc :DlvClearAll<cr>
nnoremap odb :DlvToggleBreakpoint<cr>
nnoremap odt :DlvToggleTracepoint<cr>
