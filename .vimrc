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
set noautoindent
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

" Jump to definition
nnoremap <silent><C-d> :LspDefinition<CR>

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
  set nocompatible
endif
" Add the dein installation directory into runtimepath
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

if dein#load_state('~/.cache/dein')
  call dein#begin('~/.cache/dein')

  call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')
  call dein#add('Shougo/deoplete.nvim')

  " プラグインリストを収めた TOML ファイル
  " 予め TOML ファイル（後述）を用意しておく
  let s:toml_dir  = $HOME . '/.vim/rc'
  let s:toml      = s:toml_dir . '/dein.toml'
  let s:lazy_toml = s:toml_dir . '/dein_lazy.toml'
 
  " TOML を読み込み、キャッシュしておく
  call dein#load_toml(s:toml,      {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

"End dein Scripts-------------------------

" 全角スペースを可視化
" https://vim-jp.org/vim-users-jp/2009/07/12/Hack-40.html
scriptencoding utf-8
augroup highlightIdegraphicSpace
  autocmd!
  autocmd Colorscheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
  autocmd VimEnter,WinEnter * match IdeographicSpace /　/
augroup END

colorscheme iceberg

set list
set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%

" ref: https://qiita.com/omega999/items/23aec6a7f6d6735d033f
set backspace=indent,eol,start

" Lightline
set laststatus=2

" for look
set dictionary=/usr/share/dict/words

" vim-go
let g:go_fmt_command = "goimports"

" syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" vim-autoformat
au BufWrite *.sh :Autoformat
au BufWrite *.tf :Autoformat
au BufWritePre *.rego :Autoformat

let g:formatdef_rego = '"opa fmt"'
let g:formatters_rego = ['rego']

let g:autoformat_autoindent = 0
let g:autoformat_retab = 0
let g:autoformat_remove_trailing_spaces = 0
