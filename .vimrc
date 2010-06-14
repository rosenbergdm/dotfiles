" .vimrc
" Terminal / command-line settings for VIM
" David M. Rosenberg
" Tue Feb 16 15:26:33 CST 2010

source $HOME/.vim/macmap.vim

if version >= 600
  set runtimepath+=$VIM
  set runtimepath+=$HOME/.vim
else
  let g:RT_runtimepath = expand("$VIM")
endif


syntax enable
set nofoldenable
set printoptions=paper:letter,portrait:yes
set nocompatible
set nottybuiltin
set ruler
set rulerformat=%15(%c%V\ %p%%%)
set number
set cmdheight=3
set history=1000
set ttymouse=xterm
set background=dark
set autoindent
set smartindent
set textwidth=78
set linebreak
set backup
set backupext=.bak
set backupdir=$HOME/tmp
set dir=$HOME/tmp
set softtabstop=4
set shiftwidth=4
set expandtab
set viminfo='500,<500,s10
" set term=rxvt-unicode-8bit
" set ttytype=rxvt-unicode-8bit
set incsearch

let g:netrw_browse_split=4
let g:netrw_list_hide='.*\.swp$,.*\.pyc$'


map <F2> <Esc>set number!<CR>
map <F3> <Esc>set paste!<CR>
map <F4> <Esc>colorscheme default<CR>set background=light<CR>
map <S-F4> <Esc>colorscheme default<CR>set background=dark<CR> 

map <C-F4> <Esc>set printoptions=paper:letter,portrait:yes<CR>hardcopy<CR>

" {{{ vimtlib
runtime vimtlib/macros/tplugin.vim
TPlugin! vimtlib 02tlib
TPluginScan all

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
  set magic             " Use some magic in search patterns?  Certainly!
  set modeline          " Allow the last line to be a modeline - useful when
                        " the last line in sig gives the preferred textwidth 
                        " for replies.
  set modelines=3
  set mousemodel=popup_setpos  " instead on extend
  set laststatus=2      " show status line?  Yes, always!
                        " Even for only one buffer.
  set showtabline=2
  set nolazyredraw        " [VIM5];  do not update screen while executing macros
  set magic             " Use some magic in search patterns?  Certainly!
                        " the last line in sig gives the preferred textwidth 
                        " for replies.
  set mousemodel=popup  " instead on extend
  set whichwrap=b,s,h,l,<,>,[,]
  set shortmess=atI
  set nostartofline
  set wildchar=<TAB>    " the char used for "expansion" on the command line
                        " default value is "<C-E>" but I prefer the tab key:
  set wildignore=*.bak,*.swp,*.o,*~,*.class,*.exe,*.obj,*.a
  set wildmenu          " Completion on th command line shows a menu
  set winminheight=0	" Minimum height of VIM's windows opened
  set wrapmargin=1    
  set showcmd           " Show current uncompleted command?  Absolutely!
  set suffixes=.bak,.swp,.o,~,.class,.exe,.obj,.a
                        " Suffixes to ignore in file completion, see wildignore
  set switchbuf=useopen,split " test!
			" :cnext, :make uses thefirst open windows that
                        " contains the specified buffer
 
  let g:tex_flavor = 'latex'
" -------------------------------------------------------------------
"  }}}
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
    autocmd BufEnter * :syntax sync fromstart       " Syntax breaks less often

    au BufNewFile,BufRead *[mM]akefile* setf make

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


source $HOME/.vim/macros/let-modeline.vim

" Loads FirstModeLine() {{{
if !exists('*FirstModeLine')
  runtime macros/let-modeline.vim
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

function MapToggle(key, opt)
  let cmd = ':set '.a:opt.'! \| set '.a:opt."?\<CR>"
  exec 'nnoremap '.a:key.' '.cmd
  exec 'inoremap '.a:key." \<C-O>".cmd
endfunction
command -nargs=+ MapToggle call MapToggle(<f-args>)

MapToggle <F10> list
MapToggle <F11> spell
MapToggle <F12> paste

" use ghc functionality for haskell files
au Bufenter *.hs compiler ghc
let g:haddock_browser = "open"
let g:haddock_browser_callformat = "%s %s"
let g:haddock_docdir = "/usr/local/share/doc"     

set mouse=a


function! CopyToPb()
  let text=getreg('z')
  call system('pbcopy', text)
  call system("pbpaste | xsel -i -b")
  return
endfunction
" vnoremap <special> <C-c> my"zy<C-u>:call CopyToPb()<CR>`y

function! PasteFromPb()
  return system('pbpaste')
endfunction

" inoremap <C-v> <C-R>=PasteFromPb()<CR>
" set encoding=latin1

" set encoding=utf8

" Important keymappings:
" <A-xxx> - Left Meta key (middle of three keys)
" <M-xxx> - Mode_switch + Left Meta key (Mode switch is second right from spacebar)
"
 

" nnoremap <special> <D-]> :tabnext<CR>
" inoremap <special> <D-a> hello
" noremap <special> <M-a> ihello
" noremap <special> <A-a> ihello

set <Up>=OA
set <Down>=OB
set <Left>=OD
set <Right>=OC
set <PageUp>=[5~
set <PageDown>=[6~
set <Home>=[28~
set <End>=[3~
set <BackSpace>=
set <Delete>=[3~

let g:vimrplugin_underscore = 1
let g:sh_maxlines = 1500
" set encoding=utf-8


function! GetFileEncoding()
    let lines = system("enca -L none ". bufname('.') . "| grep UTF-8")
    if empty(lines)
        execute ":set encoding=latin1"
    else
        execute ":set encoding=utf-8"
        " echo 'UTF-8 encoding set, Meta-maps will not function properly!'
    endif
endfunction



if has("autocmd")
    " au BufReadPost *    call GetFileEncoding()
    au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$") | exe("norm '\"")|else|exe "norm $"|endif|endif

    au BufWritePost *.sh    !chmod +x %
    au BufWritePost *.pl    !chmod +x %
    au BufWritePost *.zsh   !chmod +x %
    au BufNewFile *.hs      call HaskellHeader()
    au BufNewFile *.R       call InsertSkeleton()
    au BufReadPost *.hs     set omnifunc=haskellcomplete#CompleteHaskell
    au BufReadPost *.hs     imap <S-Tab> <C-x><C-o>
    au BufReadPost *.hs     inoremap <Tab> <C-n>
    au BufReadPost *.hs     let g:SuperTabDefaultCompletionType = "<C-n>"
    au BufReadPost *.lhs    set omnifunc=haskellcomplete#CompleteHaskell
    au BufReadPost *.lhs    imap <S-Tab> <C-x><C-o>
    au BufNewFile *.zsh     call InsertSkeleton()
    au BufNewFile *.sql     call InsertSkeleton()
    au! Bufread,BufNewFile *.pdc    set ft=pdc
    au BufNewFile *.c       call InsertSkeleton()
    au BufNewFile *.c       perldo s/_ (\w*) _ (\w*) _/_$1_$2_/g
    au BufNewFile,BufRead *.rb      inoremap <S-Tab> <Tab>
    au BufNewFile,BufRead *.rb      inoremap <Tab> <C-n>
    au BufNewFile,BufRead *.rb      setf ruby
    au BufNewFile,BufRead *.rb      set shiftwidth=2 softtabstop=2
    

endif


function! HaskellHeader()
    let modname = substitute( expand("%:t"), ".hs", "", "")
    let createdate = substitute( system("date +%D"), "\n", "", "")
    set paste
    let headerStringList = ['-----------------------------------------------------------------------------',
                \ '-- Module      : ' . modname ,
                \ '-- Copyright   : (c) 2010 David M. Rosenberg',
                \ '-- License     : BSD3',
                \ '-- ',
                \ '-- Maintainer  : David Rosenberg <rosenbergdm@uchicago.edu>',
                \ '-- Stability   : experimental',
                \ '-- Portability : portable',
                \ '-- Created     : ' . createdate,
                \ '-- ',
                \ '-- Description :',
                \ '--    DESCRIPTION HERE.',
                \ '-----------------------------------------------------------------------------' ]
    let headerString = join(headerStringList, "\n") . "\n\n"
    execute "normal! i" . headerString
    set nopaste
endfunction

function! RHeader()
    set paste
    let headerStringList = ['#!/usr/bin/env R',
                \ '#===============================================================================',
                \ '#',
                \ '#         FILE:  ' . expand("%"),
                \ '#',
                \ '#        USAGE:  ---',
                \ '#',
                \ '#  DESCRIPTION:  ---',
                \ '#',
                \ '#      OPTIONS:  ---',
                \ '# REQUIREMENTS:  ---',
                \ '#         BUGS:  ---',
                \ '#        NOTES:  ---',
                \ '#       AUTHOR:  David M. Rosenberg <rosenbergdm@uchicago.edu>',
                \ '#      COMPANY:  University of Chicago',
                \ '#      VERSION:  1.0',
                \ '#      CREATED:  ' . strftime("%D"),
                \ '#     REVISION:  ---',
                \ '#===============================================================================' ]
    let headerString = join(headerStringList, "\n") . "\n\n"
    execute "normal! i" . headerString
    set nopaste
endfunction

function! InsertSkeleton()
    let skelType = expand("%:e")
    if filereadable($HOME . '/.vim/skeleton/' . skelType . '-skeleton')
        let rawtext = join(readfile($HOME . '/.vim/skeleton/' . skelType . '-skeleton'), "\n")
        while matchstr(rawtext, '__\(.\{-\}\)__') != ""
            let rawExpr = matchstr(rawtext, '__\(.\{-\}\)__')
            if rawExpr == ""
                break
            endif
            let parsedExpr = substitute(rawExpr, '__', '', 'g')
            let newExpr = eval(parsedExpr)
            let rawtext = substitute(rawtext, rawExpr, newExpr, '')
        endwhile
        let oldpaste=&paste
        set paste
        execute "normal! i" . rawtext
        if oldpaste == 0
            set paste
        endif
    endif
endfunction

set autoread
set so=7
let mapleader=","
let g:mapleader=","
set magic
set cmdheight=2
set hlsearch
map <F5> :set hlsearch!<CR>


vnoremap <silent> * :call VisualSearch('f')<CR>
vnoremap <silent> # :call VisualSearch('b')<CR>
vnoremap <silent> gv :call VisualSearch('gv')<CR>
map <leader>g :vimgrep // ***/*.<left><left><left><left><left><left><left>

function! CmdLine(str)
    exe "menu Foo.Bar :" . a:str
    emenu Foo.Bar
    unmenu Foo
endfunction

function! VisualSearch(direction) range
    let l:saved_reg = @"
    execute "normal! vgvy"
    
    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == "b"
        execute "normal ?" . l:pattern . "^M"
    elseif a:direction == "gv"
        call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.')
    elseif a:direction == 'f'
        execute "normal /" . l:pattern . "^M"
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

map <leader>tN  :tabnew<cr>
map <leader>tp  :MBEbp<cr>
map <leader>tn  :MBEbn<cr>


" Smart pairings {{{ 
function! SmartQuotation(qtype)
    let nchar = getline('.')[col('.')]
    execute ":inoremap <F20> " . a:qtype
    if l:nchar == a:qtype
        execute "normal l"
    else
        execute "normal a\<F20>\<F20>\<Esc>h"
    endif
endfunction

function! SmartParenthesis(ptype)
    let nchar = getline('.')[col('.')]
    let pardict = {"(" : ")", "[": "]", "{": "}"}
    execute ":inoremap <F20> " . a:ptype

    if has_key(pardict, a:ptype)
        execute ":inoremap <F21> " . pardict[a:ptype]
        execute "normal a\<F20>\<F21>\<Esc>h"
    elseif l:nchar == a:ptype
        execute "normal l"
    else
        execute "normal a\<F20>\<Esc>h"
    endif
endfunction

" inoremap <silent> ( <esc>:call SmartParenthesis("(")<cr>a
" inoremap <silent> ) <esc>:call SmartParenthesis(")")<cr>a
" inoremap <silent> [ <esc>:call SmartParenthesis("[")<cr>a
" inoremap <silent> ] <esc>:call SmartParenthesis("]")<cr>a
" inoremap <silent> { <esc>:call SmartParenthesis("{")<cr>a
" inoremap <silent> } <esc>:call SmartParenthesis("}")<cr>a
" 
" inoremap <silent> " <esc>:call SmartQuotation("\"")<cr>a
" inoremap <silent> ' <esc>:call SmartQuotation("\'")<cr>a

" }}}

" Taglist Settings {{{
let Tlist_Auto_Open = 1
let Tlist_Compact_Format = 1
let Tlist_Enable_Fold_Column = 0
let Tlist_Ctags_Cmd = "/usr/local/bin/ctags"
let Tlist_Exit_OnlyWindow = 1
let Tlist_File_Fold_Auto_Close = 0
let Tlist_Sort_Type = "name" 
let Tlist_Use_Right_Window = 40
" }}}


inoremap <F12> x<BS><Esc>:call paste#Paste()<CR>gi
vmap <F11> "+y


function! BoxedComment(textList, commentChar)
    let newList = []
    let topBotBorder = repeat(a:commentChar, 78)
    call add(newList, topBotBorder)
    for lin in a:textList
        if len(lin) < 72
            let ll = len(lin)
            let outLine = repeat(a:commentChar, 2) . ' ' . lin . repeat(' ', 73 - ll) . repeat(a:commentChar, 2)
            call add(newList, outLine)
        else
            let splitString = split(lin, " ")
            let stringOne = remove(splitString, 0)
            while len(stringOne . splitString[0]) < 65 
                stringOne = stringOne . " " . remove(splitString, 0)
            endwhile
            let stringTwo = join(splitString, " ")
            let ll = len(stringOne)
            let outLine = repeat(a:commentChar, 2) . ' ' . stringOne . repeat(' ', 73 - ll) . repeat(a:commentChar, 2)
            call add(newList, outLine)
            let ll = len(stringTwo)
            let outLine = repeat(a:commentChar, 2) . ' ' . stringTwo . repeat(' ', 73 - ll) . repeat(a:commentChar, 2)
            call add(newList, outLine)
        endif
    endfor
    call add(newList, topBotBorder)
    call add(newList, "")
    call add(newList, "")
    return join(newList, "\n")
endfunction


" {{{ Folding control
set foldenable
set foldmethod=marker   " Automatically fold stuff
set foldopen=hor,mark,search,block,tag,undo     " Automatically unfold on these events
set foldclose=all       " Automatically close folds when moving out of them    
" }}}

" Add python path to gf will work on import module
"python << EOF
"import os
"import sys
"import vim
"for p in sys.path:
"    # Add each directory in sys.path, if it exists.
"    if os.path.isdir(p):
"        # Command 'set' needs backslash before each space.
"        vim.command(r"set path+=%s" % (p.replace(" ", r"\ ")))
"EOF

" Use antiword to read word files
autocmd BufReadPre *.doc set ro
autocmd BufReadPre *.doc set hlsearch!
autocmd BufReadPost *.doc %!antiword "%"
autocmd VimEnter *       call SetViewSettings()


" Easy / Better pasting
function! SmartPasteSelection(insertMode)
  let s:old_col = col(".")
  let s:old_lnum = line(".")
  " Correct the cursor position
  if a:insertMode
    if s:old_col == 1
      exec "normal iX\<Esc>"
    else
      exec "normal aX\<Esc>"
    endif
  endif
  exec 'normal "+gP'
  if a:insertMode
    exec 'normal x'
  endif
  let s:after_col = col(".")
  let s:after_col_end=col("$")
  let s:after_col_offset=s:after_col_end-s:after_col
  let s:after_lnum = line(".")
  let s:cmd_str='normal V'
  if s:old_lnum < s:after_lnum
    let s:cmd_str=s:cmd_str . (s:after_lnum - s:old_lnum) . "k"
  elseif s:old_lnum> s:after_lnum
    let s:cmd_str=s:cmd_str . (s:old_lnum - s:after_lnum) . "j"
  endif
  let s:cmd_str=s:cmd_str . "="
  exec s:cmd_str
  let s:new_col_end=col("$")
  call cursor(s:after_lnum, s:new_col_end-s:after_col_offset)
  if a:insertMode
    if s:after_col_offset <=1
      exec 'startinsert!'
    else
      exec 'startinsert'
    endif
  endif
endfunction
nmap <C-V> :call SmartPasteSelection(0)<CR>
imap <C-V> <Esc>:call SmartPasteSelection(1)<CR>


function! HTMLEncode()
perl << EOF
 use HTML::Entities;
 @pos = $curwin->Cursor();
 $line = $curbuf->Get($pos[0]);
 $encvalue = encode_entities($line);
 $curbuf->Set($pos[0],$encvalue)
EOF
endfunction

function! HTMLDecode()
perl << EOF
 use HTML::Entities;
 @pos = $curwin->Cursor();
 $line = $curbuf->Get($pos[0]);
 $encvalue = decode_entities($line);
 $curbuf->Set($pos[0],$encvalue)
EOF
endfunction


let g:persistentBehaviour = 0
cmap q qall

set nofoldenable
set nohlsearch

command -nargs=0 Tmake !pdflatex -interaction=nonstopmode %
command -nargs=0 Tview !xpdf %:s?tex?pdf?:p


function! SetViewSettings()
    if $DISPLAY =~ 'tmp'
        let g:term_type = "Apple Terminal"
    else
        let g:term_type = "X11 Terminal"
        autocmd VimEnter * NERDTree
        autocmd VimEnter * normal "<C-W> h" 
    endif
endfunction

function! SetPrintingPdfType()
    set printexpr=system('open -a Preview '.v:fname_in) + v:shell_error
endfunction




" vim: tw=78 ft=vim encoding=utf-8 foldenable
