" Author: local
" Description: gdlint from gdtoolkit for GDScript files

call ale#Set('gdscript_gdlint_executable', 'gdlint')
call ale#Set('gdscript_gdlint_options', '')

function! ale_linters#gdscript#gdlint#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'gdscript_gdlint_executable')
endfunction

function! ale_linters#gdscript#gdlint#GetCommand(buffer) abort
    return ale#Escape(ale_linters#gdscript#gdlint#GetExecutable(a:buffer))
    \   . ale#Pad(ale#Var(a:buffer, 'gdscript_gdlint_options'))
    \   . ' %t'
endfunction

function! ale_linters#gdscript#gdlint#Handle(buffer, lines) abort
    let l:output = []
    let l:pattern = '\v^(.+):(\d+): ([^:]+): (.+)$'

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': str2nr(l:match[2]),
        \   'type': l:match[3] is# 'Error' ? 'E' : 'W',
        \   'text': l:match[4],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('gdscript', {
\   'name': 'gdlint',
\   'executable': function('ale_linters#gdscript#gdlint#GetExecutable'),
\   'command': function('ale_linters#gdscript#gdlint#GetCommand'),
\   'callback': 'ale_linters#gdscript#gdlint#Handle',
\   'output_stream': 'stderr',
\})
