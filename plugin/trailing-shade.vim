if exists('g:loaded_trailing_shade')
	finish
else
	let g:loaded_trailing_shade = 1
endif

"
" Configuration

if !exists('g:trailing_shade_cterm')
	let g:trailing_shade_cterm = 8
endif

if !exists('g:trailing_shade_gui')
	let g:trailing_shade_gui = 0x363636
endif

if !exists('g:trailing_shade_after_cursor')
	let g:trailing_shade_after_cursor = 0
endif

"
" Utils

function! s:MatchTrailingWhitespace()
	match TrailingShade /\s\+$/
endfunction

function! s:MatchTrailingWhitespaceAroundCursor()
	match TrailingShade /\s\+\%#\@<!$/
endfunction

function! s:MatchTrailingWhitespaceAfterCursor()
	match TrailingShade /\%#\s\+$/
endfunction

if g:trailing_shade_after_cursor
	let s:MatchTrailingWhitespaceInsertMode = function('s:MatchTrailingWhitespaceAfterCursor')
else
	let s:MatchTrailingWhitespaceInsertMode = function('s:MatchTrailingWhitespaceAroundCursor')
endif

function! s:TrailingShadeOffHere(buffer_number, windows)
	augroup TrailingShadeHightlight
		execute 'autocmd! BufWinEnter <buffer='..a:buffer_number..'>'
		execute 'autocmd! InsertEnter <buffer='..a:buffer_number..'>'
		execute 'autocmd! InsertLeave <buffer='..a:buffer_number..'>'
		execute 'autocmd! BufWinLeave <buffer='..a:buffer_number..'>'
	augroup END

	for window_id in a:windows
		call win_execute(window_id, 'call clearmatches()')
	endfor
endfunction

function! s:TrailingShadeOnHere(buffer_number, windows)
	if !buflisted(a:buffer_number)
		call s:TrailingShadeOffHere(a:buffer_number, a:windows)
		return
	endif

	augroup TrailingShadeHightlight
		execute 'autocmd! BufWinEnter <buffer='..a:buffer_number..'> call s:MatchTrailingWhitespace()'
		execute 'autocmd! InsertEnter <buffer='..a:buffer_number..'> call s:MatchTrailingWhitespaceInsertMode()'
		execute 'autocmd! InsertLeave <buffer='..a:buffer_number..'> call s:MatchTrailingWhitespace()'
		execute 'autocmd! BufWinLeave <buffer='..a:buffer_number..'> call clearmatches()'
	augroup END

	for window_id in a:windows
		call win_execute(window_id, 'call <SID>MatchTrailingWhitespace()')
	endfor
endfunction

function! s:TrailingShadeOn()
	augroup TrailingShadeNewBuffer
		autocmd!
		autocmd BufAdd * call s:TrailingShadeOnHere(bufnr(), getbufinfo(bufnr())[0].windows)
		autocmd BufRead * call s:TrailingShadeOnHere(bufnr(), getbufinfo(bufnr())[0].windows)
		autocmd BufNewFile * call s:TrailingShadeOnHere(bufnr(), getbufinfo(bufnr())[0].windows)
		autocmd BufDelete * call s:TrailingShadeOffHere(bufnr(), getbufinfo(bufnr())[0].windows)
	augroup END

	for info in getbufinfo()
		call s:TrailingShadeOnHere(info.bufnr, info.windows)
	endfor
endfunction

function! s:TrailingShadeOff()
	augroup TrailingShadeNewBuffer
		autocmd!
	augroup END

	for info in getbufinfo()
		call s:TrailingShadeOffHere(info.bufnr, info.windows)
	endfor
endfunction

function! s:GetHighlightValue(name, mode, component, reverse_component, default)
	let is_reverse = synIDattr(hlID(a:name), 'reverse', a:mode)
	if ! is_reverse
		let component = a:component
	else
		let component = a:reverse_component
	endif

	let value = synIDattr(hlID(a:name), component, a:mode)
	if value ==# ''
		return a:default
	endif

	return value
endfunction

function! s:ColorOffset(normal, offset)
	if &background ==# 'dark'
		return a:normal + a:offset
	else
		return a:normal - a:offset
	endif
endfunction

function! s:AddTrailingShadeHighlight()
	let terminal_color = s:GetHighlightValue('Normal', 'cterm', 'bg', 'fg', 'none')
	if terminal_color !=# 'none'
		let terminal_color = s:ColorOffset(terminal_color, g:trailing_shade_cterm)
	endif

	let gui_color = s:GetHighlightValue('Normal', 'gui', 'bg', 'fg', 'none')
	if gui_color !=# 'none'
		let gui_color = s:ColorOffset('0x'.strpart(gui_color, 1), g:trailing_shade_gui)
	endif

	execute 'highlight! TrailingShade ctermfg=none ctermbg='..terminal_color..' guifg=none guibg='..printf('#%x', gui_color)
endfunction

augroup TrailingShadeAddColors
	autocmd!
	autocmd ColorScheme * call s:AddTrailingShadeHighlight()
augroup END

"
" Commands

command -nargs=0 -bar TrailingShadeOnHere call <SID>TrailingShadeOnHere(bufnr(), getbufinfo(bufnr())[0].windows)
command -nargs=0 -bar TrailingShadeOffHere call <SID>TrailingShadeOffHere(bufnr(), getbufinfo(bufnr())[0].windows)
command -nargs=0 -bar TrailingShadeOn call <SID>TrailingShadeOn()
command -nargs=0 -bar TrailingShadeOff call <SID>TrailingShadeOff()

"
" Main

call s:AddTrailingShadeHighlight()
call s:TrailingShadeOn()

