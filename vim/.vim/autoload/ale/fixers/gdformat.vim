" Author: local
" Description: gdformat from gdtoolkit for GDScript files

call ale#Set('gdscript_gdformat_executable', 'gdformat')
call ale#Set('gdscript_gdformat_options', '')

function! ale#fixers#gdformat#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'gdscript_gdformat_executable')
    let l:options = ale#Var(a:buffer, 'gdscript_gdformat_options')

    return {
    \   'command': ale#Escape(l:executable)
    \       . ale#Pad(l:options)
    \       . ' -',
    \}
endfunction
