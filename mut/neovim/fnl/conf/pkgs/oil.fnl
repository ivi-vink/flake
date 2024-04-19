(local oil (require :oil))
(local fzf (require :fzf-lua))

(oil.setup
  {
   :default_file_explorer  true
   :skip_confirm_for_simple_edits  true

   :columns  [:size :permissions]
   :view_options
   {
    :show_hidden  false
    :is_hidden_file  (fn [name bufnr]
                        (vim.startswith name "."))
    :is_always_hidden  (fn [name bufnr] false)
    :sort  [["type" "asc"] ["name" "asc"]]}


   :keymaps
   {
    "g?"  "actions.show_help"
    "<CR>"  "actions.select"
    "<C-s>"  "actions.select_vsplit"
    "<C-h>"  "actions.select_split"
    "<C-t>"  "actions.select_tab"
    "<C-p>"  #(fzf.files)
    "<C-c>"  "actions.close"
    "<C-l>"  "actions.refresh"
    "."  "actions.open_cmdline"
    "gx"  {:callback (fn []
                       (local file (oil.get_cursor_entry))
                       (local dir (oil.get_current_dir))
                       (if (and dir file)
                           (do
                            (vim.cmd (.. :argadd " " dir file.name)
                             (vim.cmd :args)))))}
    "gX"  {:callback (fn []
                       (local file (oil.get_cursor_entry))
                       (local dir (oil.get_current_dir))
                       (if (and dir file)
                           (do
                            (vim.cmd (.. :argdel " " dir file.name)
                             (vim.cmd :args)))))}
    "gc"  {:callback (fn []
                       (vim.cmd "argdel *")
                       (vim.cmd "args"))}
    "-"  "actions.parent"
    "_"  "actions.open_cwd"
    "cd"  "actions.cd"
    "~"  "actions.tcd"
    "gs"  "actions.change_sort"
    "g."  "actions.toggle_hidden"}})
