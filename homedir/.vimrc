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
set hls is
set ignorecase
set smartcase
set modeline

set colorcolumn=81

" mouse drag on
set mouse=a

" language specific settings
autocmd Filetype haskell setlocal ts=2 sw=2 expandtab
autocmd Filetype rust setlocal ts=4 sw=4 expandtab
autocmd Filetype c,cpp setlocal ts=2 sw=2 expandtab
autocmd Filetype javascript setlocal ts=2 sw=2 expandtab
autocmd Filetype html setlocal ts=2 sw=2 expandtab
autocmd Filetype python setlocal ts=4 sw=4 expandtab
autocmd Filetype cs setlocal ts=4 sw=4 expandtab

" syntax highlight
syntax on
autocmd BufRead,BufNewFile *.rs set filetype=rust
autocmd BufRead,BufNewFile *.ll set filetype=llvm
autocmd BufRead,BufNewFile *.coffee set filetype=coffee
autocmd BufRead,BufNewFile *.as set filetype=actionscript
autocmd BufRead,BufNewFile *.swift set filetype=swift

" TEMPORARY SETTINGS
"autocmd BufRead,BufNewFile *.tjs,*.ts set filetype=javascript
"autocmd BufRead,BufNewFile *.cxx,*.cxxx set filetype=cpp

" remove trailing space
autocmd BufWritePre *.cc,*.cpp,*.js :%s/\s\+$//e

" cscope settings
set csprg=/usr/bin/cscope
set nocsverb
"if filereadable("./cscope.out")
"	cs add ./cscope.out
"endif
set csverb
set csto=0
set cst

" find ctags db up to the root
set tags=tags;/

" find cscope db up to the root
function! LoadCscope()
	let db = findfile("cscope.out", ".;")
	if (!empty(db))
		let path = strpart(db, 0, match(db, "/cscope.out$"))
		set nocscopeverbose " suppress 'duplicate connection' error
		exe "cs add " . db . " " . path
		set cscopeverbose
	endif
endfunc
au BufEnter /* call LoadCscope()

" cscope shortcuts
func! Css()
	let css = expand("<cword>")
	new 
	exe "cs find s ".css
	if getline(1) == ""
		exe "q!"
	endif
endfunc
nmap ,css :call Css()<cr>

func! Csc()
	let csc = expand("<cword>")
	new
	exe "cs find c ".csc
	if getline(1) == ""
		exe "q!"
	endif
endfunc
nmap ,csc :call Csc()<cr>

func! Csd()
	let csd = expand("<cword>")
	new
	exe "cs find d ".csd
	if getline(1) == ""
		exe "q!"
	endif
endfunc
nmap ,csd :call Csd()<cr>

func! Csg()
	let csg = expand("<cword>")
	new
	exe "cs find g ".csg
	if getline(1) == ""
		exe "q!"
	endif
endfunc
nmap ,csg :call Csg()<cr>

" search selection
vnoremap // y/<C-R>"<CR>

" key mappings for folding
map <F1> v]}zf
map <F2> zo

" key mappings for file buffers
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

" key mappings for tabs
map <F7> :tabp<CR>
map <F8> :tabn<CR>
map <F9> :tabe .<CR>

" opposite of J command
map <C-j> i<CR><Esc>

