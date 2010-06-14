if version >= 600
  set runtimepath+=$VIM
  set runtimepath+=$HOME/.vim
else
  let g:RT_runtimepath = expand("$VIM")
endif


syntax enable
set printoptions=paper:letter,portrait:yes
set nocompatible
set ruler
set number
set cmdheight=3
set history=100
set ttymouse=xterm
set background=dark
set autoindent
set smartindent
set textwidth=300
set softtabstop=4
set shiftwidth=2
set expandtab
map <F2> <Esc>set number!<CR>
map <F3> <Esc>set paste!<CR>
map <F4> <Esc>colorscheme default<CR>set background=light<CR>
map <S-F4> <Esc>colorscheme default<CR>set background=dark<CR> 


map <C-F4> <Esc>set printoptions=paper:letter,portrait:yes<CR>hardcopy<CR>



" function! CleverTab()
"    if strpart( getline('.'), 0, col('.')-1 ) =~ '^\s*$'
"        return "\<Tab>"
"    else
"        return "\<C-N>"
" endfunction     

" inoremap <Tab> <C-R>=CleverTab()<CR>
filetype plugin indent on
" ===================================================================
" Runtime {{{
if version >= 600
  "set runtimepath+=$VIMRUNTIME (<=> $VIM/vim60)
  set runtimepath+=$VIM
  set runtimepath+=$HOME/vimfiles/latexSuite
else
  let g:RT_runtimepath = expand("$VIM")
endif
" }}}
" ===================================================================
" Help {{{
  runtime plugin/help.vim
  if exists("*BuildHelp")
    command! -nargs=1 VimrcHelp :call BuildHelp("vimrc", <q-args>)
     noremap <S-F1> :call ShowHelp('vimrc')<cr>
    inoremap <S-F1> <c-o>:call ShowHelp('vimrc')
    call ClearHelp("vimrc")
  else
    command! -nargs=1 VimrcHelp 
  endif
 
  set bs=2		" allow backspacing over everything in insert mode
  set ai			" always set autoindenting on
  set laststatus=2      " show status line?  Yes, always!
                        " Even for only one buffer.
  set lazyredraw        " [VIM5];  do not update screen while executing macros
  set magic             " Use some magic in search patterns?  Certainly!
  set modeline          " Allow the last line to be a modeline - useful when
                        " the last line in sig gives the preferred textwidth 
                        " for replies.
  set modelines=3
  set mousemodel=popup  " instead on extend
  set laststatus=2      " show status line?  Yes, always!
                        " Even for only one buffer.
  set lazyredraw        " [VIM5];  do not update screen while executing macros
  set magic             " Use some magic in search patterns?  Certainly!
  set modeline          " Allow the last line to be a modeline - useful when
                        " the last line in sig gives the preferred textwidth 
                        " for replies.
  set modelines=3
  set mousemodel=popup  " instead on extend
  set whichwrap=<,>     " 
  set wildchar=<TAB>    " the char used for "expansion" on the command line
                        " default value is "<C-E>" but I prefer the tab key:
  set wildignore=*.bak,*.swp,*.o,*~,*.class,*.exe,*.obj,*.a
  set wildmenu          " Completion on th command line shows a menu
  set winminheight=0	" Minimum height of VIM's windows opened
  set wrapmargin=1    
  set showcmd           " Show current uncompleted command?  Absolutely!
  set showmatch         " Show the matching bracket for the last ')'?
  set showmode          " Show the current mode?  YEEEEEEEEESSSSSSSSSSS!
  set suffixes=.bak,.swp,.o,~,.class,.exe,.obj,.a
                        " Suffixes to ignore in file completion, see wildignore
  set switchbuf=useopen,split " test!
			" :cnext, :make uses thefirst open windows that
                        " contains the specified buffer
 
  let g:tex_flavor = 'latex'
" -------------------------------------------------------------------
" Tags Browsing macros {{{
:VimrcHelp " <M-Left> & <M-Right> works like in internet browers, but for tags [N]
nnoremap <M-Left> <C-T>
nnoremap <M-Right> :tag<cr>
:VimrcHelp " <M-up> show the current tags stack                                [N]
nnoremap <M-Up> :tags<cr>
:VimrcHelp " <M-down> go to the definition of the tag under the cursor         [N]
nnoremap <M-Down> <C-]>

nnoremap <M-C-Up> :ts<cr>
nnoremap <M-C-Right> :tn<cr>
nnoremap <M-C-Left> :tp<cr>
" Tags Browsing }}}
" -------------------------------------------------------------------
" VIM - Editing and updating the vimrc: {{{
" As I often make changes to this file I use these commands
" to start editing it and also update it:
  let vimrc=expand('<sfile>:p')
:VimrcHelp '     ,vu = "update" by reading this file                           [N]
  nnoremap ,vu :source <C-R>=vimrc<CR><CR>
:VimrcHelp "     ,ve = vimrc editing (edit this file)                          [N]
  nnoremap ,ve :call <sid>OpenVimrc()<cr>

function! s:OpenVimrc()
  if (0==strlen(bufname('%'))) && (1==line('$')) && (0==strlen(getline('$')))
    " edit in place
    exe "e ".g:vimrc
  else
    exe "sp ".g:vimrc
  endif
endfunction
" }}}
"
"" Only do this part when compiled with support for autocommands. {{{
if has("autocmd")
  if version >=600
    filetype plugin indent on
  endif

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
    au!

    " In text files, always limit the width of text to 78 characters
    autocmd BufRead *.txt set tw=78

    " This is disabled, because it changes the jumplist.  Can't use CTRL-O to go
    " back to positions in previous files more than once.
    if 0
      " When editing a file, always jump to the last known cursor position.
      " Don't do it when the position is invalid or when inside an event handler
      " (happens when dropping a file on gvim).
      autocmd BufReadPost *
	    \ if line("'\"") > 0 && line("'\"") <= line("$") |
	    \   exe "normal! g`\"" |
	    \ endif
    endif
  augroup END

  ""source $VIMRUNTIME/settings/gz.set
  if version < 600
    source $VIMRUNTIME/mysettingfile.vim
  endif
endif " has("autocmd")
" }}}

if version < 600 " {{{
  source $VIMRUNTIME/macros/matchit.vim
endif

" Plugins
if version < 600
  Runtime! ../plugin/*.vim
" else automatic ...
endif
" }}}

" Loads FirstModeLine() {{{
if !exists('*FirstModeLine')
  runtime plugin/let-modeline.vim
endif
if exists('*FirstModeLine')
  augroup ALL
    au!
    " To not interfer with Templates loaders
    au BufNewFile * :let b:this_is_new_buffer=1
    " Modeline interpretation
    au BufEnter   * :call FirstModeLine()
  augroup END
endif
" }}}


