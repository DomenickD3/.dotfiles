if empty(glob('~/.vim/autoload/plug.vim'))
  if !executable('curl')
    echoerr 'curl is required to install vim-plug'
    finish
  endif

  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  if v:shell_error
    echoerr 'Failed to download vim-plug'
    finish
  endif

  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins
call plug#begin('~/.vim/plugged')
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'qpkorr/vim-bufkill'
Plug 'tomtom/tcomment_vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Plug 'OmniSharp/omnisharp-vim'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'dense-analysis/ale'
call plug#end()

let g:go_gopls_enabled = 1
let g:go_gopls_settings = {
\ 'staticcheck': v:true,
\ 'analyses': {
\   'modernize': v:false,
\ },
\}

let g:airline_theme = 'simple'

" ALE
let g:ale_lint_on_text_changed = 'always'
let g:ale_lint_delay = 300
let g:ale_linters = {
\ 'gdscript': ['gdlint'],
\}
let g:ale_fixers = {
\ 'gdscript': ['gdformat'],
\}

filetype plugin indent on
syntax enable

" Core
set nocompatible
set autoindent
set hidden
set modeline
set modelines=1
set autoread

" Display
set t_Co=256
colorscheme lizard256
set cursorline
set scrolloff=20
set number
set splitright
set listchars=tab:>-,extends:>
set wrap
set visualbell
set t_vb=

" Indentation
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

" Search
set ignorecase
set smartcase
set incsearch
set hlsearch

" Completion and tags
set wildmenu
set tags=./tags,tags;$HOME

" Mappings
let mapleader = ","
let @/ = ""

nnoremap <leader>, <C-W><
nnoremap <leader>. <C-W>>

inoremap jk <esc>

nnoremap <leader>ev :e $MYVIMRC<CR>
nnoremap <leader>sv :so $MYVIMRC<CR>
nnoremap <leader>r :checktime<CR>
nnoremap <silent> <leader><space> :nohlsearch<CR>

nnoremap <silent> <leader><C-J> :bn<CR>
nnoremap <silent> <leader><C-K> :bp<CR>

noremap <leader>n ^
noremap <leader>m $
noremap <leader>b <esc>:set nu!<CR>

nnoremap <C-H> <C-W><C-H>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>

" Highlight overrides
hi SpellBad ctermfg=040 ctermbg=088
hi ErrorMsg ctermfg=040 ctermbg=088
hi SpellCap ctermfg=230 ctermbg=202
