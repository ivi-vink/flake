;; vim.cmd([[augroup vimrc_plugin_buffers]])
;; vim.cmd([[au!]])
;; vim.cmd(
;;         [[autocmd BufWritePre *.md,*.hcl,*.tf,*.py,*.cpp,*.qml,*.js,*.txt,*.json,*.html,*.lua,*.yaml,*.yml,*.bash,*.sh,*.go :lua require"vimrc.buffers".clean_trailing_spaces()]])
;; 
;; vim.cmd(
;;         [[autocmd BufReadPost * lua require"vimrc.buffers".setup_white_space_highlight(vim.fn.bufnr())]])
;; 
;; vim.cmd(
;;         [[autocmd BufReadPre *.tf,*.hcl packadd vim-terraform]])
;; 
;; vim.cmd([[augroup END]])

