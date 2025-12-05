set cindent
set smartindent
set autoindent
set nowrap
set ff=unix
set ruler
set nu
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab
set expandtab
set hls is
set ignorecase
set smartcase
set modeline
set incsearch
set hidden

" plugins

" Auto-install vim-plug for both Vim and Neovim

if has('nvim')
  " Neovim uses XDG_DATA_HOME or ~/.local/share/nvim/site/autoload/plug.vim
  let s:data = empty($XDG_DATA_HOME) ? expand("$HOME/.local/share") : $XDG_DATA_HOME
  let s:plug_path = s:data . "/nvim/site/autoload/plug.vim"
  let s:install_cmd = '!sh -c ''curl -fLo "' . s:plug_path . '" --create-dirs ' .
        \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'''
else
  " Vim uses ~/.vim/autoload/plug.vim
  let s:plug_path = expand('~/.vim/autoload/plug.vim')
  let s:install_cmd = '!curl -fLo ' . shellescape(s:plug_path) .
        \ ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif

" Install plug.vim when missing
if empty(glob(s:plug_path))
  silent execute s:install_cmd

  augroup plug_bootstrap
    autocmd!
    autocmd VimEnter * ++once PlugInstall --sync | source $MYVIMRC
  augroup END
endif

call plug#begin()

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'ojroques/vim-oscyank', {'branch': 'main'}

call plug#end()

let mapleader = " "

"set colorcolumn=120
highlight ColorColumn ctermbg=gray

" mouse drag on
set mouse=a

" solarized color scheme
syntax enable
set background=dark
colorscheme solarized

" language specific settings
autocmd Filetype haskell setlocal ts=2 sw=2 expandtab
autocmd Filetype rust setlocal ts=4 sw=4 expandtab
autocmd Filetype c,cpp setlocal ts=2 sw=2 expandtab
autocmd Filetype S,asm setlocal ts=4 sw=4 expandtab
autocmd Filetype javascript setlocal ts=2 sw=2 expandtab
autocmd Filetype html setlocal ts=2 sw=2 expandtab
autocmd Filetype python setlocal ts=4 sw=4 expandtab
autocmd Filetype cs setlocal ts=4 sw=4 expandtab
autocmd Filetype sh setlocal ts=4 sw=4 expandtab
autocmd Filetype vim setlocal ts=4 sw=4 expandtab
autocmd Filetype markdown setlocal ts=4 sw=4 expandtab

" syntax highlight
syntax on
autocmd BufRead,BufNewFile *.rs set filetype=rust
autocmd BufRead,BufNewFile *.ll set filetype=llvm
autocmd BufRead,BufNewFile *.coffee set filetype=coffee
autocmd BufRead,BufNewFile *.as set filetype=actionscript
autocmd BufRead,BufNewFile *.swift set filetype=swift
autocmd BufRead,BufNewFile *.cpp set syntax=cpp11
autocmd BufRead,BufNewFile *.inc set syntax=cpp
autocmd BufRead,BufNewFile *.fbs set syntax=fbs

" remove trailing space
autocmd BufWritePre *.vim,*.h,*.c,*.cc,*.cpp,*.js :%s/\s\+$//e

" search selection
vnoremap // y/<C-R>"<CR>

" key maps for folding
map ,f v]}zf
map ,u zo

" key maps for file buffers
map ,1 :b!1<CR>
map ,2 :b!2<CR>
map ,3 :b!3<CR>
map ,4 :b!4<CR>
map ,5 :b!5<CR>
map ,6 :b!6<CR>
map ,7 :b!7<CR>
map ,8 :b!8<CR>
map ,9 :b!9<CR>
map ,0 :b!10<CR>
map ,x :bn!<CR>
map ,z :bp!<CR>
map ,w :bw<CR>
map ,c :bd<CR>

" key maps for buffers
nnoremap <C-h> :bfirst<CR>
nnoremap <C-j> :bn<CR>
nnoremap <C-k> :bp<CR>
nnoremap <C-l> :blast<CR>
nnoremap <C-n> :tabedit %:p:h<CR>
nnoremap <C-c> :tabclose<CR>

" key map for opposite of J command
map ,j i<CR><Esc>

set exrc
set secure
set hidden

command! E Explore

" vim-airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='bubblegum'
let g:airline_solarized_bg='dark'
let g:airline_powerline_fonts = 1

" ctrlp
let g:ctrlp_max_files=0
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll|o)$',
  \ }
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

nmap <leader>c <Plug>OSCYankOperator
nmap <leader>cc <leader>c_
vmap <leader>c <Plug>OSCYankVisual

