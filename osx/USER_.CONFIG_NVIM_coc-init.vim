" Modeline and Notes {
" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker spell:
" }

if &compatible
  set nocompatible
endif

nnoremap ; :


let g:python2_host_prog = '/usr/bin/python2'
let g:python3_host_prog = '/usr/local/bin/python3.7'


" Add the dein installation directory into runtimepath
set runtimepath+=~/.config/dein/repos/github.com/Shougo/dein.vim

if dein#load_state('~/.cache/dein')
  call dein#begin('~/.cache/dein')

  call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')
  call dein#add('Shougo/deoplete.nvim')
  call dein#add('Vimjas/vim-python-pep8-indent')
  call dein#add('junegunn/fzf.vim')
  call dein#add('dense-analysis/ale')
  call dein#add('wsdjeg/dein-ui.vim')
  
  call dein#add('tpope/vim-repeat')
  call dein#add('tpope/vim-surround')
  call dein#add('tpope/vim-commentary')

  call dein#add('morhetz/gruvbox')
  call dein#add('numirias/semshi')
  call dein#add('scrooloose/nerdtree')
  call dein#add('neoclide/coc.nvim', {'merged':0, 'rev': 'release'})            
  
  if !has('nvim')
    call dein#add('roxma/nvim-yarp')
    call dein#add('roxma/vim-hug-neovim-rpc')
  endif

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable


" if dein#check_install()
"   call dein#install()
" endif

set nofoldenable
set termguicolors
colorscheme gruvbox


set hlsearch
set showmatch
set smartcase
set wildmode=longest,list
set wildignore+=*/.idea/*
set wildignore+=*/.git/*
set wildignore+=*/.svn/*
set wildignore+=*/vendor/*
set wildignore+=*/node_modules/*
set diffopt+=iwhite
set expandtab
set foldlevelstart=20
set foldmethod=syntax
set hidden
set linebreak
set listchars=tab:——,trail:_
set modelines=1
set mouse=a
set autoindent
set backspace=indent,eol,start
set path+=**
set scrolloff=5
set shiftwidth=2
set shortmess+=c
set sidescrolloff=5
set smartindent
set splitbelow
set splitright
set synmaxcol=500
set tabstop=2
set textwidth=0
set timeoutlen=300
set updatetime=300
set wrapmargin=0


inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
vnoremap < <gv
vnoremap > >gv


inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

let g:markdown_fenced_languages = [ 'vim', 'help' ]

