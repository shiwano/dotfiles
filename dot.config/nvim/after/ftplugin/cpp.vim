set shiftwidth=2
set softtabstop=2
set tabstop=2

let g:clang_jumpto_declaration_key = 'od'
nnoremap of :ts <C-R><C-W><CR>
autocmd BufWrite *.cc,*.cpp :ClangFormat
