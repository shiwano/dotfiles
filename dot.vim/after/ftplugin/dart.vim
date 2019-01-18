nnoremap <silent> oi :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> od :call LanguageClient_textDocument_definition()<CR>
nnoremap <silent> of :call LanguageClient_textDocument_references()<CR>
nnoremap <silent> on :call LanguageClient_textDocument_rename()<CR>
nnoremap <silent> or :LanguageClientStop<CR>:LanguageClientStart<CR>
