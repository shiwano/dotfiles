setlocal noexpandtab
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal listchars=tab:\ \ ,trail:_,extends:>,precedes:< " 不可視文字の表示形式

nnoremap od :LspDefinition<CR>
nnoremap oh :LspHover<CR>
nnoremap or :LspReferences<CR>
nnoremap oi :LspImplementation<CR>
nnoremap on :LspRename<cr>
nnoremap oe :LspDocumentDiagnostics<cr>

nnoremap odd :DlvTest<cr>
nnoremap odc :DlvClearAll<cr>
nnoremap odb :DlvToggleBreakpoint<cr>
nnoremap odt :DlvToggleTracepoint<cr>

" Returns the byte offset for the cursor
function! OffsetCursor() abort
  let line = line('.')
  let col = col('.')
  if &encoding != 'utf-8'
    let sep = "\r"
    let buf = l:line == 1 ? '' : (join(getline(1, l:line-1), sep) . sep)
    let buf .= l:col == 1 ? '' : getline('.')[:l:col-2]
    return len(iconv(buf, &encoding, 'utf-8'))
  endif
  return line2byte(l:line) + (l:col-2)
endfunction

function! FillStruct()
    let l:cmd = ['fillstruct',
      \ '-file', bufname(''),
      \ '-offset', OffsetCursor(),
      \ '-line', line('.')]
  " Read from stdin if modified.
  let out = system(l:cmd)
  let l:json = json_decode(l:out)
  let l:pos = getpos('.')
  for l:struct in l:json
    let l:code = split(l:struct['code'], "\n")
    " Add any code before/after the struct.
    exe l:struct['start'] . 'go'
    let l:code[0] = getline('.')[:col('.')-1] . l:code[0]
    exe l:struct['end'] . 'go'
    let l:code[len(l:code)-1] .= getline('.')[col('.'):]
    " Indent every line except the first one; makes it look nice.
    let l:indent = repeat("\t", indent('.') / &tabstop)
    for l:i in range(1, len(l:code)-1)
      let l:code[l:i] = l:indent . l:code[l:i]
    endfor
    " Out with the old ...
    exe 'normal! ' . l:struct['start'] . 'gov' . l:struct['end'] . 'gox'
    " ... in with the new.
    call setline('.', l:code[0])
    call append('.', l:code[1:])
  endfor
endfunction

nnoremap of :call FillStruct()<cr>
