if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
 
" PLUGINS --
call plug#begin('~/.vim/plugged')
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'qpkorr/vim-bufkill'
Plug 'tomtom/tcomment_vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Plug 'OmniSharp/omnisharp-vim' " IDE features + Roslyn Server
" Plug 'neoclide/coc.nvim', {'branch': 'release'} " gives autocomplete - Use release branch (recommend)
Plug 'dense-analysis/ale' "linter
call plug#end()

let g:airline_theme = 'simple'


filetype plugin indent on
syntax enable

set autoindent
set nocompatible        " disable vi compatibility

set t_Co=256            " tell vim to use 256 colors
colorscheme lizard256
set nowrap

set tabstop=2           " number of spaces a tab is made up of
set shiftwidth=2        " number of spaces to indent
set softtabstop=2       " number of spaces pressing tab is equal to
set expandtab           " convert tabs to spaces

set cursorline          " highlight current line
set scrolloff=20        " 20 lines above and below cursor when scrolling
set number              " turn line numbers on

set ignorecase          " ignore case for searching
set smartcase           " search with capital letters
set incsearch           " search as characters are entered
set hlsearch            " highlight matches

set hidden              " allow buffers to be hidden w/o saving
set wildmenu            " visual command autocomple

set visualbell          " set vim to use visualbell instead of beeping
set t_vb =              " set visuabell to do nothing

set modeline            " allow modelines
set modelines=1         " only allow one modeline

set splitright

set listchars=tab:>-,extends:>

set ai

let mapleader = ","
let @/ = ""             " clear most recent search

set tags=./tags,tags;$HOME " necessary for ctags to find the correct directory

map <c-n> <c-w><
map <c-m> <c-w>>

inoremap jk <esc> 

nnoremap <leader>ev :e $MYVIMRC<CR>
nnoremap <leader>sv :so $MYVIMRC<CR>

nnoremap <silent> <leader><space> :nohlsearch<CR>

nnoremap <silent> <leader><C-J> :bn<CR>
nnoremap <silent> <leader><C-K> :bp<CR>

noremap <leader>n ^
noremap <leader>m $
noremap <leader>b <esc>:set nu!<CR>

" pane navigation
nnoremap <C-H> <C-W><C-H>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>

hi SpellBad ctermfg=040 ctermbg=088
hi ErrorMsg ctermfg=040 ctermbg=088
hi SpellCap ctermfg=230 ctermbg=202

" " remove white space with confirmation
" noremap <F9> :%s/\s\+$//egc<CR>
"
" " always remove trailing white spaces
" autocmd BufWritePre * %s/\s\+$//e
" if (&term =~ '^xterm' && &t_Co == 256)
"   set t_ut= | set ttyscroll=1
" endif
"
" let g:go_fmt_autosave = 0
" let g:OmniSharp_server_stdio = 0
" let g:omnicomplete_fetch_full_documentation = 1
" let g:OmniSharp_timeout = 5
" let g:OmniSharp_highlighting = 0
" let g:OmniSharp_translate_cygwin_wsl = 1
" let g:OmniSharp_server_stdio = 1 
" let g:ale_disable_lsp = 1
" let g:ale_linters = {
"       \ 'cs': ['OmniSharp']
"       \ }
"let g:OmniSharp_server_use_mono = 1
" autocmd FileType cs setlocal omnifunc=OmniSharp#Complete
" Write this in your vimrc file
" let g:ale_lint_on_text_changed = 'never'
" let g:ale_lint_on_insert_leave = 0
" let g:ale_fix_on_save = 1
" let g:ale_cs_mcsc_assemblies=[ '/home/ddonofrio/Projects/TurnBased/obj/Debug/', '/mnt/c/Program Files/Unity/Hub/Editor/2019.4.0f1/Editor/Data/Managed/UnityEngine.dll' ]
" let g:ale_cs_mcsc_assemblies=[ '/home/ddonofrio/Projects/TurnBased/obj/Debug/Assembly-CSharp.csprojAssemblyReference.cache', '/mnt/c/Program Files/Unity/Hub/Editor/2019.4.0f1/Editor/Data/Managed/UnityEngine.dll' ]
" Rename with dialog
" nnoremap <Leader>x :OmniSharpRename<CR>
" nnoremap <F2> :OmniSharpRename<CR>
" set completeopt=longest,menuone,preview,popuphidden
" set completepopup=highlight:Pmenu,border:off
" set previewheight=5
