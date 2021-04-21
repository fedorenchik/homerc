scriptversion 4

let g:PV_config = "$HOME/.vim/planetvimrc.vim"
if filereadable(expand(g:PV_config))
  silent exe "source " .. fnameescape(g:PV_config)
endif

func! planet#planet#ConfigUpdate(conf_var) abort
  if empty(v:this_session) && filewritable(expand(g:PV_config))
    silent call system('grep "let ' .. a:conf_var .. ' =" ' .. g:PV_config)
    if ! v:shell_error
      silent call system('sed -i -e "s/^let ' .. a:conf_var .. ' = .*$/let ' .. a:conf_var .. ' = ' .. eval(a:conf_var) .. '/" ' .. g:PV_config)
    else
      silent call system('echo "let ' .. a:conf_var .. ' = ' .. eval(a:conf_var) .. '" >> ' .. g:PV_config)
    endif
  else
    silent call system('echo "let ' .. a:conf_var .. ' = ' .. eval(a:conf_var) .. '" > ' .. g:PV_config)
  endif
endfunc

func! planet#planet#SetEasyMode() abort
  set im
  set selectmode=mouse,key
  set keymodel=startsel,stopsel
  set guioptions-=c
  set guioptions+=r
  silent! nun b
  silent! nun B
  silent! nun e
  silent! nun E
  silent! nun f
  silent! nun F
  silent! nun ge
  silent! nun gE
  silent! nun h
  silent! nun j
  silent! nun k
  silent! nun l
  silent! nun t
  silent! nun T
  silent! nun w
  silent! nun W
endfunc

func! planet#planet#SetStandardMode() abort
  set noim
  set selectmode=
  set keymodel=
  set guioptions+=c
  set guioptions-=r
  silent! nun b
  silent! nun B
  silent! nun e
  silent! nun E
  silent! nun f
  silent! nun F
  silent! nun ge
  silent! nun gE
  silent! nun h
  silent! nun j
  silent! nun k
  silent! nun l
  silent! nun t
  silent! nun T
  silent! nun w
  silent! nun W
endfunc

func! planet#planet#SetSuperChargedMode() abort
  set noim
  set selectmode=
  set keymodel=
  set guioptions+=c
  set guioptions-=r
  nn <silent> b :bn<CR>
  nn <silent> B :bp<CR>
  nn <silent> e g;
  nn <silent> E g,
  nn <silent> f :call PlanetVim_f()<CR>
  nn <silent> F :call PlanetVim_F()<CR>
  nn <silent> ge 1gt
  nn <silent> gE :tabl<CR>
  nn <silent> h :call PlanetVim_h()<CR>
  nn <silent> j :lbel<CR>
  nn <silent> k :lab<CR>
  nn <silent> l :call PlanetVim_l()<CR>
  nn <silent> t :call PlanetVim_t()<CR>
  nn <silent> T :call PlanetVim_T()<CR>
  nn <silent> w :call PlanetVim_w()<CR>
  nn <silent> W :call PlanetVim_W()<CR>
endfunc

func! planet#planet#SetPerSessionOptions()
  "TODO: undofile, undodir, spellfile, viminfo, viewdir
  exe "set viminfofile=~/.vim/viminfo/" .. fnamemodify(v:this_session, ":t") .. ".viminfo"
  silent! rviminfo!
endfunc

func! planet#planet#SaveExit() abort
  confirm wall
  qa!
endfunc

func! planet#planet#EmergencyExit() abort
  set noautowrite
  set noautowriteall
  cquit!
endfunc

func! planet#planet#CheckExitSaveSession() abort
  if empty(v:this_session) || v:exiting != 0
    return
  end
  "TODO: auto-save and auto-load quickfix/loclist files (up to 10 of each, loclists: for each window)
  exe 'SSave! ' .. fnamemodify(v:this_session, ":t")
endfunc
