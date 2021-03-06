scriptversion 4


func! planet#session#Save() abort
  if ! empty(v:this_session)
    exe 'SSave! ' .. fnamemodify(v:this_session, ":t")
  else
    exe 'SSave ' .. fnamemodify(getcwd(-1), ":t")
  end
endfunc

func! planet#session#SetCurrent() abort
  if exists('g:last_session')
    exe 'aun 📚&s.Current:\ ' .. g:last_session
    unlet g:last_session
  endif
  if ! empty(v:this_session)
    exe 'an 840.20  📚&s.Current:\ ' .. fnamemodify(v:this_session, ":t") .. ' <Nop>'
    let g:last_session = fnamemodify(v:this_session, ":t")
  endif
endfunc

func! planet#session#MenuList() abort
  for session in startify#session_list('')
    exe 'an 840.500 📚&s.Session\ List.' .. session .. ' :SLoad ' .. session .. '<CR>'
  endfor
endfunc

" TODO: support for sessions in project dir
func! planet#session#SetCwdSession() abort
  set undodir=./.planetvim/undo
  set viminfofile=./.planetvim/viminfo
  set viewdir=./.planetvim/view
  "TODO: planetvim config file
endfunc
