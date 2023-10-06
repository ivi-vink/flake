if exists('current_compiler')
  finish
endif
let current_compiler = 'go-test'

if exists(':CompilerSet') != 2
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=compile\ ansible-lint
CompilerSet errorformat=%Z%f:%l\ %m,%Z%f:%l,%E%\\%%(%\\S%\\)%\\@=%m,%C%\\%%(%\\S%\\)%\\@=%m,%-G
