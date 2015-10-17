" This plugin relies on the three-argument form of getreg() introduced in a
" series of 7.4 patches.
if exists('g:loaded_push') || !has('patch-7.4.249')
  finish
endif

let g:loaded_push = 1

nnoremap <silent> <Plug>PushLeftAfter :<C-U>call push#Push(v:register, v:count1, 'p', 1)<CR>
nnoremap <silent> <Plug>PushLeftBefore :<C-U>call push#Push(v:register, v:count1, 'P', 1)<CR>
nnoremap <silent> <Plug>PushRightAfter :<C-U>call push#Push(v:register, v:count1, 'p', 0)<CR>
nnoremap <silent> <Plug>PushRightBefore :<C-U>call push#Push(v:register, v:count1, 'P', 0)<CR>

nmap <unique> [=p <Plug>PushLeftAfter
nmap <unique> [=P <Plug>PushLeftBefore
nmap <unique> ]=p <Plug>PushRightAfter
nmap <unique> ]=P <Plug>PushRightBefore
