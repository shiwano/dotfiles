set shiftwidth=4
set softtabstop=4
set tabstop=4

nnoremap ob :wa!<cr>:OmniSharpBuild<cr>
nnoremap od :OmniSharpGotoDefinition<cr>
nnoremap oi :OmniSharpFindImplementations<cr>
nnoremap of :OmniSharpFindUsages<cr>
nnoremap ot :OmniSharpTypeLookup<cr>
"I find contextual code actions so useful that I have it mapped to the spacebar
nnoremap og :OmniSharpGetCodeActions<cr>

" rename with dialog
nnoremap on :OmniSharpRename<cr>
" Force OmniSharp to reload the solution. Useful when switching branches etc.
nnoremap or :OmniSharpReloadSolution<cr>
nnoremap ocf :OmniSharpCodeFormat<cr>
nnoremap oa :OmniSharpAddToProject<cr>
" (Experimental - uses vim-dispatch plugin) - Start the omnisharp server for the current solution
nnoremap os :OmniSharpStartServer<cr>
nnoremap ost :OmniSharpStopServer<cr>

" Fold a C sharp region
let b:match_words = '\s*#\s*region.*$:\s*#\s*endregion'
