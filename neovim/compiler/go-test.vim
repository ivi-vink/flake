if exists('current_compiler')
  finish
endif
let current_compiler = 'go-test'

if exists(':CompilerSet') != 2
  command -nargs=* CompilerSet setlocal <args>
endif

" %f>%l:%c:%t:%n:%m
CompilerSet makeprg=go\ test
CompilerSet errorformat=%.%#:\ %m\ %f:%l,%.%#:\ %m\ at\ %f:%l%.%#,

" vim: sw=2 sts=2 et
