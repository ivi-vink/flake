if exists('current_compiler')
  finish
endif
let current_compiler = 'go-test'

if exists(':CompilerSet') != 2
  command -nargs=* CompilerSet setlocal <args>
endif

" The errorformat can also use vim's regular expression syntax (albeit in a rather awkward way) which gives us a solution to the problem. We can use a non-capturing group and a zero-width assertion to require the presence of these signaling phrases without consuming them. This then allows the %m to pick them up. As plain regular expression syntax this zero-width assertion looks like:
"
" \%(undefined reference\|multiple definition\)\@=
"
" But in order to use it in efm we need to replace \ by %\ and % by %%


CompilerSet makeprg=compile\ racket
CompilerSet errorformat=\%Z%*\\S%.%#,
                        \%C\ \ \ %f:%l:%c,
                        \%C\ \ \ %f:%l:%c:\ %m,
                        \%C\ \ %.%#%\\%%(module%\\spath:%\\\|at\:%\\\|in\:%\\\|expected\:%\\\|given\:%\\)%\\@=%m,
                        \%C\ %.%#,
                        \%E%\\%%(%\\w%\\)%\\@=%f:%*\\d:%*\\d:\ %m,
                        \%E%*\\f:%*\\d:%*\\d:\ %m,
                        \%E%\\%%(%\\S%\\+:%\\\|%\.%\\+--%\\)%\\@=%m,
" vim: sw=2 sts=2 et
