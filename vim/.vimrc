" ==============================================================================
" 3nricoMarinelli's Vanilla Vim Configuration
" Target: Embedded & Legacy Systems
" ==============================================================================

" 1. Essential Initialization & Compatibility
if &compatible
  set nocompatible
endif

let mapleader = " "
let maplocalleader = " "

" 2. General Editor Options & Performance
set encoding=utf-8
set fileencoding=utf-8
set hidden                        " Allow switching away from unsaved buffers
set backspace=indent,eol,start    " Intuitive backspacing
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smarttab
set incsearch
set hlsearch
set ignorecase
set smartcase
set splitbelow
set splitright
set scrolloff=5
set sidescrolloff=5
set updatetime=300
set timeoutlen=500
set nobackup
set nowritebackup
set noswapfile                    " Prevent flash memory wear on embedded boards
set ruler

if has("wildmenu")
  set wildmenu
  set wildmode=longest:full,full
  set wildignore+=*.o,*.obj,*.bin,*.hex,*.elf,*.git,*.so,*.a,*.pyc,node_modules/*
endif

if has("path")
  set path+=**                    " Recursive search for :find
endif

if has("relativenumber")
  set number
  set relativenumber
elseif has("number")
  set number
endif

" 3. Syntax & Appearance (Dark Zed / OneDark Emulation)
set background=dark
colorscheme habamax
set cursorline
if has("syntax")
  syntax enable
endif

if has("termguicolors") && ($COLORTERM == 'truecolor' || $COLORTERM == '24bit')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

if &t_Co >= 256 || has("termguicolors")
  highlight Normal       ctermbg=235 ctermfg=250 guibg=#1e1e24 guifg=#abb2bf
  highlight LineNr       ctermbg=234 ctermfg=240 guibg=#18181b guifg=#4b5263
  highlight CursorLineNr ctermbg=236 ctermfg=220 guibg=#282c34 guifg=#e5c07b cterm=bold
  highlight StatusLine   ctermbg=237 ctermfg=253 guibg=#2c323c guifg=#abb2bf cterm=none
  highlight StatusLineNC ctermbg=234 ctermfg=242 guibg=#1e1e24 guifg=#5c6370 cterm=none
  highlight VertSplit    ctermbg=234 ctermfg=238 guibg=#1e1e24 guifg=#3e4452 cterm=none
  highlight TabLine      ctermbg=234 ctermfg=242 guibg=#18181b guifg=#5c6370 cterm=none
  highlight TabLineSel   ctermbg=236 ctermfg=255 guibg=#282c34 guifg=#ffffff cterm=bold
  highlight TabLineFill  ctermbg=234 ctermfg=234 guibg=#18181b guifg=#18181b
  highlight Pmenu        ctermbg=236 ctermfg=250 guibg=#282c34 guifg=#abb2bf
  highlight PmenuSel     ctermbg=240 ctermfg=220 guibg=#3e4452 guifg=#e5c07b
  highlight Search       ctermbg=220 ctermfg=235 guibg=#e5c07b guifg=#1e1e24
  highlight IncSearch    ctermbg=208 ctermfg=235 guibg=#ff9e64 guifg=#1e1e24
  highlight Visual       ctermbg=238 ctermfg=NONE guibg=#3e4452 guifg=NONE
  highlight User1        ctermbg=33  ctermfg=255 guibg=#61afef guifg=#1e1e24 cterm=bold " Normal Mode
  highlight User2        ctermbg=142 ctermfg=235 guibg=#98c379 guifg=#1e1e24 cterm=bold " Insert Mode
  highlight User3        ctermbg=167 ctermfg=255 guibg=#e06c75 guifg=#1e1e24 cterm=bold " Visual Mode
  highlight User4        ctermbg=208 ctermfg=235 guibg=#d19a66 guifg=#1e1e24 cterm=bold " Replace Mode
  highlight User5        ctermbg=239 ctermfg=250 guibg=#3e4452 guifg=#abb2bf            " Info Mode
endif

" 4. Dynamic Native Statusline (Lualine Parity)
if has("statusline")
  set laststatus=2

  function! GitBranch()
    if !executable('git') | return '' | endif
    if !exists('b:git_branch') || (exists('b:git_branch_ts') && (localtime() - b:git_branch_ts > 5))
      let l:branch = system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
      let b:git_branch = (empty(l:branch) || l:branch =~# 'fatal') ? '' : '  ' . l:branch . ' '
      let b:git_branch_ts = localtime()
    endif
    return b:git_branch
  endfunction

  function! ModeStatus()
    let l:m = mode()
    if l:m ==# 'n'          | return '%1*  NORMAL  %*'
    elseif l:m ==# 'i'      | return '%2*  INSERT  %*'
    elseif l:m ==# 'v'      | return '%3*  VISUAL  %*'
    elseif l:m ==# 'V'      | return '%3*  V-LINE  %*'
    elseif l:m ==# "\<C-v>" | return '%3*  V-BLOCK %*'
    elseif l:m ==# 'R'      | return '%4*  REPLACE %*'
    elseif l:m ==# 'c'      | return '%5*  COMMAND %*'
    endif
    return '%5*  ' . l:m . '  %*'
  endfunction

  set statusline=
  set statusline+=%{ModeStatus()}
  set statusline+=%5*%{GitBranch()}%*
  set statusline+=\ %f\ %m%r%h%w
  set statusline+=%=
  set statusline+=%5*\ %Y\ \|\ %{&fenc?&fenc:&enc}\ \|\ %{&ff}\ %*
  set statusline+=\ %3p%%\ \ %l:%c\
endif

" 5. Native Tabline (Barbar Parity)
if has("tabline")
  set showtabline=2
  function! NativeTabLine()
    let l:s = ''
    let l:cur = bufnr('%')
    for l:i in range(1, bufnr('$'))
      if buflisted(l:i)
        let l:s .= (l:i == l:cur ? '%#TabLineSel#' : '%#TabLine#')
        let l:name = bufname(l:i)
        let l:fname = (l:name != '' ? fnamemodify(l:name, ':t') : '[No Name]')
        let l:mod = getbufvar(l:i, '&modified') ? ' [+]' : ''
        let l:s .= ' ' . l:i . ':' . l:fname . l:mod . ' '
      endif
    endfor
    let l:s .= '%#TabLineFill#'
    return l:s
  endfunction
  set tabline=%!NativeTabLine()
endif

" 6. Netrw Tree Configuration (Neo-Tree Parity)
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 0
let g:netrw_altv = 1
let g:netrw_winsize = 25

" 7. Integrated Pure Vimscript Tools
function! CreateFilePrompt()
  let l:current_dir = expand('%:p:h')
  if empty(l:current_dir) || l:current_dir ==# '.'
    let l:current_dir = getcwd()
  endif
  call inputsave()
  let l:file = input('New file: ', l:current_dir . '/', 'file')
  call inputrestore()
  if !empty(l:file)
    let l:parent = fnamemodify(l:file, ':h')
    if !isdirectory(l:parent)
      call mkdir(l:parent, 'p')
    endif
    execute 'edit ' . fnameescape(l:file)
    write
  endif
endfunction
command! -nargs=0 CreateFile call CreateFilePrompt()

function! SwitchSourceHeader()
  let l:ext = expand('%:e')
  let l:base = expand('%:p:r')
  let l:targets = []
  if l:ext =~? '^\(c\|cpp\|cxx\|cc\)$'
    let l:targets = [l:base . '.h', l:base . '.hpp', l:base . '.hxx']
  elseif l:ext =~? '^\(h\|hpp\|hxx\)$'
    let l:targets = [l:base . '.cpp', l:base . '.c', l:base . '.cxx', l:base . '.cc']
  endif
  for l:target in l:targets
    if filereadable(l:target)
      execute 'edit ' . fnameescape(l:target)
      return
    endif
  endfor
  echo "No matching header/source found for " . expand('%:t')
endfunction
command! -nargs=0 SwitchSourceHeader call SwitchSourceHeader()

function! s:GetCommentPrefix()
  let l:cs = &commentstring
  if empty(l:cs)
    if &filetype =~? '^\(c\|cpp\|java\|rust\|go\|javascript\|typescript\)$'
      return '//'
    elseif &filetype =~? '^\(vim\)$'
      return '"'
    elseif &filetype =~? '^\(lua\)$'
      return '--'
    else
      return '#'
    endif
  endif
  let l:parts = split(l:cs, '%s')
  return empty(l:parts) ? '#' : substitute(l:parts[0], '\s*$', '', '')
endfunction

function! ToggleCommentLine(line1, line2)
  let l:prefix = s:GetCommentPrefix()
  let l:escaped_pfx = escape(l:prefix, '/*#~')
  let l:all_commented = 1
  for l:lnum in range(a:line1, a:line2)
    let l:line = getline(l:lnum)
    if l:line =~ '^\s*$' | continue | endif
    if l:line !~ '^\s*' . l:escaped_pfx
      let l:all_commented = 0
      break
    endif
  endfor

  for l:lnum in range(a:line1, a:line2)
    let l:line = getline(l:lnum)
    if l:line =~ '^\s*$' | continue | endif
    if l:all_commented
      let l:newline = substitute(l:line, '^\(\s*\)' . l:escaped_pfx . '\s\?', '\1', '')
      call setline(l:lnum, l:newline)
    else
      let l:newline = substitute(l:line, '^\(\s*\)', '\1' . l:prefix . ' ', '')
      call setline(l:lnum, l:newline)
    endif
  endfor
endfunction
command! -range ToggleComment call ToggleCommentLine(<line1>, <line2>)

function! ToggleBlockComment(line1, line2)
  if &filetype =~? '^\(c\|cpp\|java\|rust\|go\|javascript\|typescript\|css\)$'
    let l:start = '/*'
    let l:end = '*/'
  elseif &filetype =~? '^\(html\|xml\|markdown\)$'
    let l:start = '<!--'
    let l:end = '-->'
  elseif &filetype =~? '^\(lua\)$'
    let l:start = '--[['
    let l:end = ']]'
  elseif &filetype =~? '^\(python\)$'
    let l:start = '"""'
    let l:end = '"""'
  else
    call ToggleCommentLine(a:line1, a:line2)
    return
  endif

  let l:first = getline(a:line1)
  let l:last = getline(a:line2)
  if l:first =~ '^\s*' . escape(l:start, '/*') && l:last =~ escape(l:end, '/*') . '\s*$'
    call setline(a:line1, substitute(l:first, '^\(\s*\)' . escape(l:start, '/*') . '\s\?', '\1', ''))
    call setline(a:line2, substitute(l:last, '\s\?' . escape(l:end, '/*') . '\(\s*\)$', '\1', ''))
  else
    call append(a:line1 - 1, l:start)
    call append(a:line2 + 1, l:end)
  endif
endfunction

function! InsertLicenseHeader()
  let l:author = ''
  let l:email = ''
  if executable('git')
    let l:author = system("git config user.name 2>/dev/null | tr -d '\n'")
    let l:email  = system("git config user.email 2>/dev/null | tr -d '\n'")
  endif
  if empty(l:author) | let l:author = $USER | endif
  if empty(l:email)  | let l:email = $USER . '@localhost' | endif
  let l:proj = fnamemodify(getcwd(), ':t')
  let l:date = strftime('%Y-%m-%d')
  let l:c = s:GetCommentPrefix()

  let l:header = [
        \ l:c . ' ============================================================================',
        \ l:c . ' Project: ' . l:proj,
        \ l:c . ' Author:  ' . l:author . ' <' . l:email . '>',
        \ l:c . ' Date:    ' . l:date,
        \ l:c . ' Notice:  Human-authored source file.',
        \ l:c . ' ============================================================================',
        \ '' ]
  call append(0, l:header)
endfunction
command! -nargs=0 LicenseHeader call InsertLicenseHeader()

function! InsertCppSkeleton()
  let l:filename = expand('%:t')
  let l:guard = toupper(substitute(l:filename, '[^A-Za-z0-9]', '_', 'g')) . '_'
  let l:classname = expand('%:t:r')
  let l:skel = [
        \ '#ifndef ' . l:guard,
        \ '#define ' . l:guard,
        \ '',
        \ 'class ' . l:classname . ' {',
        \ 'public:',
        \ '    ' . l:classname . '() = default;',
        \ '    virtual ~' . l:classname . '() = default;',
        \ '',
        \ '    ' . l:classname . '(const ' . l:classname . '&) = default;',
        \ '    ' . l:classname . '& operator=(const ' . l:classname . '&) = default;',
        \ '    ' . l:classname . '(' . l:classname . '&&) noexcept = default;',
        \ '    ' . l:classname . '& operator=(' . l:classname . '&&) noexcept = default;',
        \ '',
        \ 'private:',
        \ '};',
        \ '',
        \ '#endif // ' . l:guard
        \ ]
  call append(line('$'), l:skel)
endfunction
command! -nargs=0 Skel call InsertCppSkeleton()

function! InsertDocstring()
  let l:c = s:GetCommentPrefix()
  if &filetype =~? '^\(c\|cpp\|java\|javascript\|typescript\)$'
    let l:doc = [
          \ '/**',
          \ ' * @brief ',
          \ ' * ',
          \ ' * @param ',
          \ ' * @return ',
          \ ' */' ]
  elseif &filetype =~? '^\(python\)$'
    let l:doc = [
          \ '"""',
          \ 'Brief description of function/class.',
          \ '',
          \ 'Args:',
          \ '    param1: Description.',
          \ '',
          \ 'Returns:',
          \ '    Description of return value.',
          \ '"""' ]
  else
    let l:doc = [
          \ l:c . ' @brief Description',
          \ l:c . ' @param Parameters' ]
  endif
  call append(line('.') - 1, l:doc)
endfunction
command! -nargs=0 Docstring call InsertDocstring()

function! ScratchTerminal()
  if has('terminal')
    for l:buf in tabpagebuflist()
      if getbufvar(l:buf, '&buftype') ==# 'terminal'
        execute bufwinnr(l:buf) . 'wincmd w'
        return
      endif
    endfor
    botright 12split | terminal
  else
    suspend
  endif
endfunction
command! -nargs=0 ScratchTerminal call ScratchTerminal()

function! BufferCloseClean()
  let l:current = bufnr('%')
  let l:alternate = bufnr('#')
  if buflisted(l:alternate) && l:alternate != l:current
    execute 'buffer ' . l:alternate
  else
    bprevious
  endif
  if bufnr('%') != l:current
    execute 'bdelete ' . l:current
  else
    bdelete
  endif
endfunction
command! -nargs=0 BufferClose call BufferCloseClean()

command! Wnf noautocmd write
command! -nargs=* WNF noautocmd write <args>

" 8. Universal Keybindings (Neovim / Zed Parity)
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprev<CR>
nnoremap <S-l> :bnext<CR>
nnoremap <S-h> :bprev<CR>
nnoremap <C-Tab> :bnext<CR>
nnoremap <C-S-Tab> :bprev<CR>
nnoremap <Esc> :nohlsearch<CR>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

noremap <silent> <C-Left> :vertical resize +3<CR>
noremap <silent> <C-Right> :vertical resize -3<CR>
noremap <silent> <C-Up> :resize +3<CR>
noremap <silent> <C-Down> :resize -3<CR>

vnoremap < <gv
vnoremap > >gv

nnoremap [d :cprev<CR>
nnoremap ]d :cnext<CR>

" Leader Mappings
nnoremap <leader>f :find *
nnoremap <leader>F :vimgrep // **/* <Bar> copen<CR>
nnoremap <silent> <leader>e :Lexplore<CR>
nnoremap <silent> <C-n>     :Lexplore<CR>
nnoremap <silent> <leader>cf :call CreateFilePrompt()<CR>
nnoremap <silent> <leader>cl :call InsertLicenseHeader()<CR>
nnoremap <silent> <leader>z  :call ScratchTerminal()<CR>
nnoremap <silent> <leader>x  :call BufferCloseClean()<CR>
nnoremap <silent> <leader>X  <C-w>c
nnoremap <silent> <leader>/  :call ToggleCommentLine(line('.'), line('.'))<CR>
vnoremap <silent> <leader>/  :<C-u>call ToggleCommentLine(line("'<"), line("'>"))<CR>
nnoremap <silent> <leader>?  :call ToggleBlockComment(line('.'), line('.'))<CR>
vnoremap <silent> <leader>?  :<C-u>call ToggleBlockComment(line("'<"), line("'>"))<CR>
nnoremap <silent> <leader>d  :call InsertDocstring()<CR>
nnoremap <leader>R :%s/\<<C-r><C-w>\>/<C-r><C-w>/g<Left><Left>
vnoremap <leader>r ve"_dP
nnoremap <silent> <leader>n :set number! relativenumber!<CR>
nnoremap <silent> <leader>W :set wrap!<CR>

" Git (Vanilla CLI Integration)
nnoremap <silent> <leader>gs :!git status<CR>
nnoremap <silent> <leader>ga :!git add %<CR>
nnoremap <silent> <leader>gu :!git reset HEAD %<CR>
nnoremap <silent> <leader>gv :!git diff %<CR>
nnoremap <silent> <leader>gb :execute '!git blame -L ' . line('.') . ',' . line('.') . ' %'<CR>
nnoremap <silent> <leader>gr :!git checkout -- %<CR>

" Navigation & C/C++ (Tags, Cscope, Quickfix)
nnoremap <silent> <leader>ld <C-]>
nnoremap <silent> <leader>lt :tselect <cword><CR>
nnoremap <silent> <leader>lk :ptag <cword><CR>
nnoremap <silent> <leader>lx :copen<CR>
nnoremap <silent> <leader>lh :pclose<CR>
nnoremap <silent> <leader>ch :call SwitchSourceHeader()<CR>
nnoremap <silent> <leader>cs :call InsertCppSkeleton()<CR>
nnoremap <silent> <leader>cc :make<CR>
nnoremap <silent> <leader>cC :make clean all<CR>
nnoremap <silent> <leader>ct :make test<CR>

" 9. Autocommands
if has("autocmd")
  augroup vimrc_autocmds
    autocmd!
    " Remember cursor position across restarts
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
    " Auto-open quickfix on compiler errors
    autocmd QuickFixCmdPost [^l]* nested cwindow
  augroup END
endif
