if exists('g:loaded_trailing_shade')
	finish
else
	let g:loaded_trailing_shade = v:true
endif

"
" Utils

function! s:ABuf()
	let abuf = expand('<abuf>')
	if abuf ==# ''
		let buffer_number = 0
	else
		let buffer_number = str2nr(abuf)
	end
	return buffer_number != 0 ? buffer_number : bufnr()
endfunction

function! s:MatchTrailingWhitespace()
	match TrailingShade /\s\+$/
endfunction

function! s:MatchTrailingWhitespaceAroundCursor()
	match TrailingShade /\s\+\%#\@<!$/
endfunction

function! s:MatchTrailingWhitespaceAfterCursor()
	match TrailingShade /\%#\s\+$/
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

function! s:NeutralBrightest(color)
	let color = printf('%x', a:color)
	let red = str2nr(color[0:1], 16)
	let green = str2nr(color[2:3], 16)
	let blue = str2nr(color[4:5], 16)
	let largest_component = max([red, green, blue])
	return str2nr(repeat(printf('%x', largest_component), 3), 16)
endfunction

function! s:IsDarkBackground(normal, offset, white)
	if &background ==# 'dark'
		let result = a:normal + a:offset
		if result > a:white " in case color scheme ignores 'background' option
			return 0
		else
			return 1
		endif
	else
		let result = a:normal - a:offset
		if result < 0 " in case color scheme ignores 'background' option
			return 1
		else
			return 0
		endif
	endif
endfunction

function! s:IsDarkColor(color)
	return a:color < 0x808080
endfunction

function! s:MakeLighterShade(base, offset)
	return a:base + a:offset
endfunction

function! s:MakeDarkerShade(base, offset)
	let padding = s:NeutralBrightest(a:offset)
	return a:base - 2 * padding + a:offset
endfunction

function! s:ColorShadeCterm(normal, offset)
	if s:IsDarkBackground(a:normal, a:offset, 255)
		return a:normal + a:offset
	else
		return a:normal - a:offset
	endif
endfunction

function! s:ColorShadeGui(normal, offset)
	if s:IsDarkColor(a:normal)
		return s:MakeLighterShade(a:normal, a:offset)
	else
		return s:MakeDarkerShade(a:normal, a:offset)
	endif
endfunction

"
" Configuration

if !exists('g:trailing_shade_cterm')
	let g:trailing_shade_cterm = 8
endif

if !exists('g:trailing_shade_gui')
	let g:trailing_shade_gui = 0x363636
endif

if !exists('g:trailing_shade_after_cursor')
	let g:trailing_shade_after_cursor = v:false
endif

if g:trailing_shade_after_cursor
	let s:MatchTrailingWhitespaceInsertMode = function('s:MatchTrailingWhitespaceAfterCursor')
else
	let s:MatchTrailingWhitespaceInsertMode = function('s:MatchTrailingWhitespaceAroundCursor')
endif

"
" Plugin

function! s:AddHighlight()
	let terminal_color = s:GetHighlightValue('Normal', 'cterm', 'bg', 'fg', 'none')
	if terminal_color !=# 'none'
		let terminal_color = s:GetHighlightValue('Normal', 'cterm', 'fg', 'bg', 'none')
	endif

	let terminal_color = s:ColorShadeCterm(terminal_color, g:trailing_shade_cterm)

	let gui_color = s:GetHighlightValue('Normal', 'gui', 'bg', 'fg', 'none')
	if gui_color ==# 'none'
		let gui_color = s:GetHighlightValue('Normal', 'gui', 'fg', 'bg', 'none')
	endif

	let gui_color = s:ColorShadeGui('0x'.strpart(gui_color, 1), g:trailing_shade_gui)

	execute 'highlight! TrailingShade ctermfg=none ctermbg='..terminal_color..' guifg=none guibg='..printf('#%x', gui_color)
endfunction

function! s:AddBufferAutoCmds(buffer_number)
	augroup TrailingShade
		execute 'autocmd! BufWinEnter <buffer='..a:buffer_number..'> call s:MatchTrailingWhitespace()'
		execute 'autocmd! InsertEnter <buffer='..a:buffer_number..'> call s:MatchTrailingWhitespaceInsertMode()'
		execute 'autocmd! InsertLeave <buffer='..a:buffer_number..'> call s:MatchTrailingWhitespace()'
		execute 'autocmd! BufWinLeave <buffer='..a:buffer_number..'> call clearmatches()'
	augroup END
endfunction

function! s:RemoveBufferAutoCmds(buffer_number)
	augroup TrailingShade
		execute 'autocmd! BufWinEnter <buffer='..a:buffer_number..'>'
		execute 'autocmd! InsertEnter <buffer='..a:buffer_number..'>'
		execute 'autocmd! InsertLeave <buffer='..a:buffer_number..'>'
		execute 'autocmd! BufWinLeave <buffer='..a:buffer_number..'>'
	augroup END
endfunction

function! s:MatchTrailingWhitespaceInWindows(windows)
	for window_id in a:windows
		call win_execute(window_id, 'call <SID>MatchTrailingWhitespace()')
	endfor
endfunction

function! s:ClearMatchesInWindows(windows)
	for window_id in a:windows
		call win_execute(window_id, 'call clearmatches()')
	endfor
endfunction

function! s:OnHere(buffer_number, windows)
	call s:AddBufferAutoCmds(a:buffer_number)
	call s:MatchTrailingWhitespaceInWindows(a:windows)
endfunction

function! s:OffHere(buffer_number, windows)
	call s:RemoveBufferAutoCmds(a:buffer_number)
	call s:ClearMatchesInWindows(a:windows)
endfunction

function! s:On()
	augroup TrailingShadeGlobal
		autocmd!
		autocmd BufAdd * call s:OnHere(s:ABuf(), getbufinfo(s:ABuf())[0].windows)
		autocmd BufDelete * call s:OffHere(s:ABuf(), getbufinfo(s:ABuf())[0].windows)

		" Note to future self:
		" with 'WinNew' '<abuf>' is not a buffer in a new window, it is the
		" buffer that was active before the window was created.
		" so this code introduces more critical bugs, than fixes non critical ones.
		" autocmd WinNew * call s:MatchTrailingWhitespaceInWindows(getbufinfo(s:ABuf('<abuf>'))[0].windows)
	augroup END

	for info in getbufinfo()
		if info.listed
			call s:OnHere(info.bufnr, info.windows)
		endif
	endfor
endfunction

function! s:Off()
	augroup TrailingShadeGlobal
		autocmd!
	augroup END

	for info in getbufinfo()
		call s:OffHere(info.bufnr, info.windows)
	endfor
endfunction

augroup TrailingShadeAddHighlight
	autocmd!
	autocmd ColorScheme * call s:AddHighlight()
augroup END

"
" Commands

command -nargs=0 -bar TrailingShadeOnHere call <SID>OnHere(bufnr(), getbufinfo(bufnr())[0].windows)
command -nargs=0 -bar TrailingShadeOffHere call <SID>OffHere(bufnr(), getbufinfo(bufnr())[0].windows)
command -nargs=0 -bar TrailingShadeOn call <SID>On()
command -nargs=0 -bar TrailingShadeOff call <SID>Off()

"
" Main

call s:AddHighlight()
call s:On()

