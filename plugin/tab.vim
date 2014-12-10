"some tab function,
"intend to maintain different working directory for each tab,
"auto switch directory when switch tab
"
func! TabSwitchToPrevTab()
	"because tablast not work
	execute "tabn " . g:PreTabNr
endfunc

"pattern, function
"dict = {
"	'name':'name',
"	'pattern':"pattern",
"	'enter_callback':"enter_function",
"	'leave_callback':"leave_function" 
"	}

function! s:TabCallEnterTrigger(nr)
	for t in g:TabTrigger
		if t.enter_callback != ""
			"echo "TabEnter execute trigger:" . t.name
			call {t.enter_callback}(a:nr)
		endif
	endfor
endfunction

function! s:TabCallLeaveTrigger(nr)
	for t in g:TabTrigger
		if t.leave_callback != ""
			"echo "TabLeave execute trigger:" . t.name
			call {t.leave_callback}(a:nr)
		endif
	endfor
endfunction

if !exists("g:PreTabNr")
	let g:PreTabNr = 1 
endif

if !exists("g:LastTabPages")
	let g:LastTabPages = 1 "origin as 1 tab exists
endif

if !exists("g:TabDirs")
	let g:TabDirs = ["","","","","","","","","","",""] "index 0 not use
endif

if !exists("s:TabAutocmdLoaded")
	let s:TabAutocmdLoaded = 1
	autocmd TabEnter * call s:TabCallEnterFunc()
	autocmd TabLeave * call s:TabCallLeaveFunc()
endif

"if a tab enter, check if some new tab create
func! s:TabCallEnterFunc()
	"echo "tab enter:" tabpagenr()
	let TabPages = tabpagenr('$')
	if g:LastTabPages != TabPages
		if g:LastTabPages < TabPages
			if TabPages >= 9
				echo "tab.vim don't support more than 9 tabs"
				return
			endif
			"echo "one page add"
			let nr = tabpagenr()
			if g:TabDirs[nr] != ""
				"echo "page nr dir not empty"
				let saveTabDirs = g:TabDirs[:]
				let g:TabDirs[nr] = getcwd()
				let g:TabDirs[nr+1 : ] = saveTabDirs[nr : ]
			else
				"echo "page nr dir empty"
				"XXX can't get cwd when tab enter
				"leave it blank, rely on tableave
			endif
			let g:LastTabPages = TabPages
		else
			"echo "one page close:" g:PreTabNr
			let nr = g:PreTabNr
			if nr > TabPages
				"the last page close
				"echo "last page close"
				let g:TabDirs[nr] = ""
			else
				"echo "not the last page close"
				let saveTabDirs = g:TabDirs[:]
				let g:TabDirs[nr : TabPages] = saveTabDirs[nr+1 : TabPages+1]
				let g:TabDirs[TabPages+1] = ""
			endif
			let g:LastTabPages = TabPages
			let tabdir = g:TabDirs[tabpagenr()]
			exec "silent cd " . tabdir
		endif
	else
		let tabdir = g:TabDirs[tabpagenr()]
		exec "silent cd " . tabdir
	endif
	let nr = tabpagenr()
	call s:TabCallEnterTrigger(nr)
	"echo g:LastTabPages
	"echo g:TabDirs
	"call getchar()
endfunc

"if a tab leave, check if some tab close
func! s:TabCallLeaveFunc()
	"remember previous tab nr
	"echo "tab leave:" tabpagenr()
	let TabPages = tabpagenr('$')
	let nr = tabpagenr()
	if g:LastTabPages != TabPages
		"XXX this don't work, pagenr not imedietely reduce in here
		"do it in tabenter
		"echo "some page close"
	else
		"echo "page the same"
		let g:TabDirs[nr] = getcwd() "save dir
	endif
	let g:PreTabNr = nr
	let nr = tabpagenr()
	call s:TabCallLeaveTrigger(nr)
	"echo g:LastTabPages
	"echo g:TabDirs
	"call getchar()
	"echo getcwd()
endfunc

function! s:TabGetDir(n)
	if a:n == tabpagenr()
		return getcwd()
	else
		let tabdir = g:TabDirs[a:n]
		return tabdir
	endif
endfunc

"clear tabline setting
set tabline&
set tabline=%!TabMyTabLine()
hi TabLineSel term=standout ctermfg=60 guibg=Red guifg=White
hi TabLine term=standout ctermfg=grey guibg=Red guifg=White
function! TabMyTabLabel(n)
	let buflist = tabpagebuflist(a:n)
	let winnr = tabpagewinnr(a:n)
	let bufname = bufname(buflist[winnr - 1])
	if bufname == ""
		let bufname = "   "
	endif
	let last_slash = strridx(bufname, "/")
	let filename = strpart(bufname, last_slash+1)
	"return "[" .  a:n . "]" . " "  . bufname(buflist[winnr - 1])
	return filename . ""
endfunction

function! s:GetLastDir(path)
	let last_slash = strridx(a:path, "/")
	if last_slash != -1
		return strpart(a:path, last_slash+1)
	else
		return a:path
	endif
endfunction


function! TabMyTabLine()
	let s = ''
	for i in range(tabpagenr('$'))
		" select the highlighting
		if i + 1 == tabpagenr()
			let s .= '%#TabLineSel#'
			" the label is made by MyTabLabel()
			"let s .= ' ' . '#' . (i+1) . ' %{MyTabLabel(' . (i + 1) . ')} '
			let s .= ' ' . '*' . (i+1) . '*' . ' %{TabMyTabLabel(' . (i + 1) . ')} ' . '[' . s:GetLastDir(getcwd()) . ']'
		else
			let s .= '%#TabLine#'
			let s .= ' ' . '*' . (i+1) . '*' . ' %{TabMyTabLabel(' . (i + 1) . ')} ' . '[' . s:GetLastDir(s:TabGetDir(i+1)) . ']'
		endif
	endfor
	return s
endfunction 

