" Returns the index of the first (or last) line containing (non-blank) text,
" assuming there is at least one such line in the list.
function! s:IndexOfTextLine(lines, reverse) abort
  let [l:i, l:step] = a:reverse ? [len(a:lines) - 1, -1] : [0, 1]
  while a:lines[l:i] =~# '\v^\s*$'
    let l:i += l:step
  endwhile
  return l:i
endfunction

function! s:GetTextLineBounds(lines) abort
  return [s:IndexOfTextLine(a:lines, 0), s:IndexOfTextLine(a:lines, 1)]
endfunction

" Partitions lines into a (possibly empty) list of leading blank lines, a list
" of text lines, and a (possibly empty) list of trailing blank lines.
function! s:PartitionTextLines(lines) abort
  let [l:start, l:end] = s:GetTextLineBounds(a:lines)
  return [
      \ a:lines[:-(len(a:lines) - l:start + 1)],
      \ a:lines[(l:start):(l:end)],
      \ a:lines[(l:end + 1):]]
endfunction

function! s:ShiftLinewise(lines, leftwards) abort
  let [l:prefix, l:text, l:suffix] = s:PartitionTextLines(a:lines)
  return a:leftwards
      \ ? l:text + l:prefix + l:suffix
      \ : l:prefix + l:suffix + l:text
endfunction

" Splits a string in two, leading (or trailing) whitespace, and the rest of the
" line, in the order in which they appear.
function! s:SplitOnTextBoundary(string, reverse) abort
  let l:pattern = a:reverse ? '\v^(.{-})(\s*)$' : '\v^(\s*)(.*)$'
  return matchlist(a:string, l:pattern)[1:2]
endfunction

function! s:FuseLines(a, b, c) abort
  let l:a_and_b = a:a[:-2] + [a:a[-1] . a:b[0]] + a:b[1:]
  return l:a_and_b[:-2] + [l:a_and_b[-1] . a:c[0]] + a:c[1:]
endfunction

function! s:ShiftCharacterwise(lines, leftwards) abort
  let [l:prefix, l:text, l:suffix] = s:PartitionTextLines(a:lines)

  " Process last text line first. Since "first" and "last" may refer to the same
  " text line, processing the last one first is necessary to make byte offsets work.
  let [l:text[-1], l:trailing] = s:SplitOnTextBoundary(l:text[-1], 1)
  let l:suffix = [l:trailing] + l:suffix
  let [l:leading, l:text[0]] = s:SplitOnTextBoundary(l:text[0], 0)
  let l:prefix = l:prefix + [l:leading]

  return a:leftwards
      \ ? s:FuseLines(l:text, l:prefix, l:suffix)
      \ : s:FuseLines(l:prefix, l:suffix, l:text)
endfunction

function! s:ShiftRegisterLines(lines, type, leftwards) abort
  if match(a:lines, '\v\S') < 0
    return a:lines
  endif
  if a:type is# 'V'
    return s:ShiftLinewise(a:lines, a:leftwards)
  elseif a:type is# 'v'
    return s:ShiftCharacterwise(a:lines, a:leftwards)
  endif
  " TODO(glts) Implement blockwise Visual mode.
  return a:lines
endfunction

function! s:PlugMappingString(leftwards, put_command) abort
  return "\<Plug>Push"
      \ . (a:leftwards ? 'Left' : 'Right')
      \ . (a:put_command is# 'p' ? 'After' : 'Before')
endfunction

" Use {put_command} to put from {register} {count} times, shifting the register
" contents past whitespace in {leftwards} direction. Restores the register afterwards.
function! push#Push(register, count, put_command, leftwards) abort
  let l:plug = s:PlugMappingString(a:leftwards, a:put_command)
  silent! call repeat#setreg(l:plug, a:register)

  let l:reg = getreg(a:register, 1, 1)
  let l:regtype = getregtype(a:register)

  let l:reg_shifted = s:ShiftRegisterLines(l:reg, l:regtype, a:leftwards)
  call setreg(a:register, l:reg_shifted, l:regtype)
  execute 'normal! "' . a:register . a:count . a:put_command

  call setreg(a:register, l:reg, l:regtype)

  silent! call repeat#set(l:plug, a:count)
endfunction
