set fenc=utf-8
set nobackup
set noswapfile
set autoread
set hidden
set showcmd

set number relativenumber
set cursorline
set cursorcolumn
set virtualedit=onemore
set smartindent
set visualbell
set showmatch
set laststatus=2
set wildmode=list:longest
nnoremap j gj
nnoremap k gk

set expandtab
" 行頭以外のTab文字の表示幅（スペースいくつ分）
set tabstop=2
" 行頭でのTab文字の表示幅
set shiftwidth=2

set ignorecase
set smartcase
set incsearch
set wrapscan
set hlsearch
nmap <Esc><Esc> :nohlsearch<CR><Esc>
set hls is
set paste

" Add color
syntax on

" Decimal number to increase or decrease [C-a] or [C-x]
set nrformats =
set history=200

" dein
" https://github.com/Shougo/dein.vim
if &compatible
  set nocompatible
endif
" Add the dein installation directory into runtimepath
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

if dein#load_state('~/.cache/dein')
  call dein#begin('~/.cache/dein')

  call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')
  call dein#add('Shougo/deoplete.nvim')
  if !has('nvim')
    call dein#add('roxma/nvim-yarp')
    call dein#add('roxma/vim-hug-neovim-rpc')
  endif

  call dein#add('tyru/open-browser.vim')
  call dein#add('tyru/open-browser-github.vim')

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable

" Ctrl + e opens NERDtree 
nnoremap <silent><C-e> :NERDTreeToggle<CR>

" nanka iikanji ni idou
nnoremap H 15h
nnoremap J 8j
nnoremap K 8k
nnoremap L 15l

" Add permission to file has shebang
autocmd BufWritePost * :call AddExecmod()
function AddExecmod()
    let line = getline(1)
    if strpart(line, 0, 2) == "#!"
        call system("chmod +x ". expand("%"))
    endif
endfunction
