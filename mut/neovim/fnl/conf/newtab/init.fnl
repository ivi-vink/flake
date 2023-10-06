(local pickers (require :telescope.pickers))
(local finders (require :telescope.finders))
(local conf (. (require :telescope.config) :values))
(local themes (require :telescope.themes))
(local actions (require :telescope.actions))
(local action_state (require :telescope.actions.state))

(fn colors [opts]
  (local opts (if opts opts {}))
  (local finder
         (pickers.new opts
                      {:prompt_title :colors
                       :finder (finders.new_oneshot_job [:fd
                                                         :-d1
                                                         "."
                                                         (os.getenv :HOME)
                                                         (.. (os.getenv :HOME)
                                                             :/projects)]
                                                        {})
                       :attach_mappings (fn [prompt_buf map]
                                          (actions.select_default:replace (fn []
                                                                            (actions.close prompt_buf)
                                                                            (local selection
                                                                                   (action_state.get_selected_entry))
                                                                            (vim.cmd (.. :tabnew
                                                                                         (. selection
                                                                                            1)))
                                                                            (vim.cmd (.. :tc
                                                                                         (. selection
                                                                                            1))))))
                       :sorter (conf.generic_sorter opts)}))
  (finder:find))

(vim.api.nvim_create_user_command :NewTab (fn [] (colors (themes.get_ivy))) {})

(vim.api.nvim_create_user_command :Colors colors {})
