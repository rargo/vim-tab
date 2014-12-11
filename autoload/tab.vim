if !exists("g:TabTrigger")
	let g:TabTrigger = []
endif

function! tab#TabShowTrigger()
	let i = 1
	for t in g:TabTrigger
		echo "tab trigger " . i . "---> name:" . t.name . " enter_callback:" . t.enter_callback . " leave_callback:" . t.leave_callback
		let i = i+1
	endfor
endfunction

function! tab#TabAddTrigger(trigger)
	let newTrigger = copy(a:trigger)
	if has_key(newTrigger,'name')
		let newTrigger.name = a:trigger['name']
	else
		echo "TabAddTrigger:error trigger"
		return
	endif

	for t in g:TabTrigger
		if t.name == a:trigger['name']
			echo "TabAddTrigger:trigger " . t.name . " already exists"
			return
		endif
	endfor

	if has_key(newTrigger,'pattern')
		let newTrigger.pattern = a:trigger['pattern']
	else
		let newTrigger.pattern = ""
	endif

	if has_key(newTrigger,'enter_callback')
		let newTrigger.enter_callback = a:trigger['enter_callback']
	else
		let newTrigger.enter_callback = ""
	endif

	if has_key(newTrigger,'leave_callback')
		let newTrigger.leave_callback = a:trigger['leave_callback']
	else
		let newTrigger.leave_callback = ""
	endif

	call add(g:TabTrigger,newTrigger)
endfunction

