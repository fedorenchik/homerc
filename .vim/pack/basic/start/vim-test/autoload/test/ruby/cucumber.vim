if !exists('g:test#ruby#cucumber#file_pattern')
  let g:test#ruby#cucumber#file_pattern = '\v\.feature$'
endif

function! test#ruby#cucumber#test_file(file) abort
  if a:file =~# g:test#ruby#cucumber#file_pattern
    return !empty(glob('features/**/*.rb'))
  endif
endfunction

function! test#ruby#cucumber#build_position(type, position) abort
  if a:type ==# 'nearest'
    return [a:position['file'].':'.a:position['line']]
  elseif a:type ==# 'file'
    return [a:position['file']]
  else
    return []
  endif
endfunction

function! test#ruby#cucumber#build_args(args, color) abort
  let args = a:args

  if !a:color
    let args = ['--no-color'] + args
  endif

  return args
endfunction

function! test#ruby#cucumber#executable() abort
  if !empty(glob('.zeus.sock'))
    return 'zeus cucumber'
  elseif filereadable('./bin/cucumber') && get(g:, 'test#ruby#use_binstubs', 1)
    return './bin/cucumber'
  elseif filereadable('Gemfile') && get(g:, 'test#ruby#bundle_exec', 1)
    return 'bundle exec cucumber'
  else
    return 'cucumber'
  endif
endfunction
