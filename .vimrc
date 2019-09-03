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

"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=/Users/chaspy/.cache/dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state('/Users/chaspy/.cache/dein')
  call dein#begin('/Users/chaspy/.cache/dein')

  " Let dein manage dein
  " Required:
  call dein#add('/Users/chaspy/.cache/dein/repos/github.com/Shougo/dein.vim')

 " プラグインリストを収めた TOML ファイル
 " 予め TOML ファイル（後述）を用意しておく
 let s:toml_dir  = $HOME . '/.vim/rc' 
 let s:toml      = s:toml_dir . '/dein.toml'
 let s:lazy_toml = s:toml_dir . '/dein_lazy.toml'

 " TOML を読み込み、キャッシュしておく
 call dein#load_toml(s:toml,      {'lazy': 0})
 call dein#load_toml(s:lazy_toml, {'lazy': 1})

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

"End dein Scripts-------------------------
