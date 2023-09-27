if exists('current_compiler')
  finish
endif
let current_compiler = 'go-test'

if exists(':CompilerSet') != 2
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=compile\ helm\ lint
CompilerSet errorformat=\[%t%.%#\]%.%#\ template:\ %f:%l:%c:\ %m,
                        \\[%t%.%#\]\ %f:\ %m,

" vim: sw=2 sts=2 et
