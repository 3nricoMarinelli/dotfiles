" 3nricoMarinelli's .vimrc
" Copyright(C) 2026 Enrico Marinelli

" ViIMproved & General settings
set nocompatible
filetype off
set hidden
set nobackup
set noswapfile
set t_Co=256
set incsearch
set relativenumber
let g:rehash256 = 1
syntax enable

" Search down into subfolders
" Provides tab-completion for all file-related tasks
set path+=**

" Display all matching files when we tab complete
set wildmenu
set wildmode=longest:full,full
set completeopt+=longest

" - Hit tab to :find by partial match
" - Use * to make it fuzzy
" - :b lets you autocomplete any open buffer

" Tweaks for browsing
let g:netrw_banner=0        " disable annoying banner
let g:netrw_browse_split=4  " open in prior window
let g:netrw_altv=1          " open splits to the right
let g:netrw_liststyle=3     " tree view

" - :edit a folder to open a file browser
" - <CR>/v/t to open in an h-split/v-split/tab
" - check |netrw-browse-maps| for more mappings

" Split and tabs "
set splitbelow splitright

" Remap splits navigation to just CTRL + hjkl
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Make adjusing split sizes a bit more friendly
noremap <silent> <C-Left> :vertical resize +3<CR>
noremap <silent> <C-Right> :vertical resize -3<CR>
noremap <silent> <C-Up> :resize +3<CR>
noremap <silent> <C-Down> :resize -3<CR>

" Change 2 split windows from vert to horiz or horiz to vert
map <Leader>th <C-w>t<C-w>H
map <Leader>tk <C-w>t<C-w>K

" Removes pipes | that act as seperators on splits
set fillchars+=vert:\


" Color and theming "
highlight LineNr           ctermfg=8    ctermbg=none    cterm=none
highlight CursorLineNr     ctermfg=7    ctermbg=8       cterm=none
highlight VertSplit        ctermfg=0    ctermbg=8       cterm=none
highlight Statement        ctermfg=2    ctermbg=none    cterm=none
highlight Directory        ctermfg=4    ctermbg=none    cterm=none
highlight StatusLine       ctermfg=7    ctermbg=8       cterm=none
highlight StatusLineNC     ctermfg=7    ctermbg=8       cterm=none
highlight Comment          ctermfg=4    ctermbg=none    cterm=italic
highlight Constant         ctermfg=12   ctermbg=none    cterm=none
highlight Special          ctermfg=4    ctermbg=none    cterm=none
highlight Identifier       ctermfg=6    ctermbg=none    cterm=none
highlight PreProc          ctermfg=5    ctermbg=none    cterm=none
highlight String           ctermfg=12   ctermbg=none    cterm=none
highlight Number           ctermfg=1    ctermbg=none    cterm=none
highlight Function         ctermfg=1    ctermbg=none    cterm=none
highlight WildMenu         ctermfg=1    ctermbg=8       cterm=none
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

map Q lxh

" antirez's .vimrc
" Copyright(C) 2001 Salvatore Sanfilippo

" Enable the syntax highlight mode if available
syntax sync fromstart
if has("syntax")
	syntax sync fromstart
	syntax on
        set background=dark
	let php_sync_method="0"
        highlight SpellBad ctermfg=red ctermbg=black term=Underline
endif

" Put the current date in insert mode
imap <C-d> <ESC>:r! date<CR>kJ$a
imap <C-k> <ESC>:r ~/SVC/HEADER<CR>
imap <C-o> <ESC>:bn<CR>
imap <C-k> <ESC>:bp<CR>
imap <C-x> <ESC>:syntax sync fromstart<CR>
map <C-x> :syntax sync fromstart<CR>
map <C-o> :bn<CR>
map <C-k> :bp<CR>
map 4 $
vmap q <gv
vmap <TAB> >gv

set softtabstop=4
set shiftwidth=4
set expandtab

" highlight matches with last search pattern
" set hls

set incsearch		" incremental search
set ignorecase		" ignore the case
set smartcase		" don't ignore the case if the pattern is uppercase
"set laststatus=2	" show the status bar even with one buffer
set ruler		" show cursor position
set showmode		" show the current mode
"set showmatch		" show the matching ( for the last )
set viminfo=%,'50,\"100,:100,n~/.viminfo	"info to save accross sessions
set autoindent
set backspace=2
normal mz

" abbreviations
iab pallang X-MAILGW-Newsgroups:
iab CHDR <ESC>1G:r ~/SVC/HEADER<CR>1Gdd
iab tclfile #/bin/sh \<CR># the next line restarts using tclsh \<CR>exec tclsh "$0" "$@"<CR><CR><CR># vim: set filetype=tcl softtabstop=4 shiftwidth=4<CR>

" change filetypes for common files
augroup filetypedetect
au BufNewFile,BufRead *.tcl     set filetype=tcl softtabstop=4 shiftwidth=4
au BufNewFile,BufRead *.tk     set filetype=tcl softtabstop=4 shiftwidth=4
au BufNewFile,BufRead *.md     set filetype=markdown softtabstop=4 shiftwidth=4
augroup END

" When open a new file remember the cursor position of the last editing
if has("autocmd")
        " When editing a file, always jump to the last cursor position
        autocmd BufReadPost * if line("'\"") | exe "'\"" | endif
endif

" Colors
" :hi Comment term=bold ctermfg=Cyan ctermfg=#80a0ff

" Macro
nmap ;; :w! /tmp/tcltmp100.tcl<CR>:!tclsh /tmp/tcltmp100.tcl<CR>

" Vim 7.0 stuff
let loaded_matchparen = 1   " Avoid the loading of match paren plugin
filetype plugin on
" :source /usr/share/vim/vim72/macros/matchit.vim

" highlight OverLength ctermbg=red ctermfg=white ctermbg=#592929
" match OverLength /\%81v.*/

" Status Line
set laststatus=2

hi User1 ctermfg=green ctermbg=black
hi User2 ctermfg=yellow ctermbg=black
hi User3 ctermfg=red ctermbg=black
hi User4 ctermfg=blue ctermbg=black
hi User5 ctermfg=white ctermbg=black

set statusline=
set statusline +=%1*\ %n\ %*            "buffer number
set statusline +=%5*%{&ff}%*            "file format
set statusline +=%3*%y%*                "file type
set statusline +=%4*\ %<%F%*            "full path
set statusline +=%2*%m%*                "modified flag
set statusline +=%1*%=%5l%*             "current line
set statusline +=%2*/%L%*               "total lines
set statusline +=%1*%4v\ %*             "virtual column number
set statusline +=%2*0x%04B\ %*          "character under cursor
