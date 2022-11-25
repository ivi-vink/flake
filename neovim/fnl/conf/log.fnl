(import-macros {: P} :conf.macros)

(local scratches {})
(fn scratch-buffer [name ft]
  (fn setopt [buf opt value]
    (vim.api.nvim_buf_set_option buf opt value)
    buf)

  (fn track [buf]
    (tset scratches name buf)
    buf)

  (track (-> (vim.api.nvim_create_buf true false)
             (setopt :filetype ft)
             (setopt :buftype :nofile)
             (setopt :bufhidden :hide)
             (setopt :swapfile false))))

(let [log (fn [...]
            (P [...]))]
  (vim.api.nvim_create_user_command :Scratch
                                    (fn [c]
                                      (let [name c.args]
                                        (fn exists? [buf]
                                          (not= buf nil))

                                        (fn get []
                                          (. scratches c.args))

                                        (fn goto [buf]
                                          (vim.api.nvim_set_current_buf buf))

                                        (let [buf (get)
                                              current (vim.api.nvim_get_current_buf)]
                                          (if (exists? buf) (goto buf)
                                              (goto (scratch-buffer name
                                                                    (vim.api.nvim_buf_get_option current
                                                                                                 :filetype)))))))
                                    {:complete log :nargs 1}))
