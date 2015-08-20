setlocal noexpandtab
setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4

nnoremap od :GoDef<cr>
nnoremap of :GoReferrers<cr>
nnoremap on :GoRename<cr>
nnoremap oc :GoCallees<cr>
nnoremap op :GoImplements<cr>
nnoremap oi :GoImport<cr>
nnoremap ob :GoBuild<cr>
