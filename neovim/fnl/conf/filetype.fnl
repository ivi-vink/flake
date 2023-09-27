(fn playbook? [filename]
  (P filename)
  (local pattern (vim.regex :^playbook.*))
  (pattern:match_str filename))

(fn group-vars? [relative-dir]
  (local pattern (vim.regex :group_vars$))
  (pattern:match_str relative-dir))

(fn roles? [relative-dir]
  (local pattern (vim.regex :roles$))
  (pattern:match_str relative-dir))

(fn task? [relative-file]
  (local pattern (vim.regex :.*tasks.*))
  (pattern:match_str relative-file))

(fn ansible-files? [items]
  (local [item & rest] items)
  (if (not item) :yaml
      (task? item) :yaml.ansible
      (roles? item) :yaml.ansible
      (group-vars? item) :yaml.ansible
      (ansible-files? rest)))

(fn yaml-filetype [path buf]
  (local [repo?]
         (vim.fs.find :.git
                      {:upward true
                       :path (vim.fs.dirname path)
                       :stop (vim.fs.dirname (vim.loop.cwd))}))
  (local files (or (not repo?) (icollect [path file-or-dir (vim.fs.dir (vim.fs.dirname repo?)
                                                                       {:skip #(not= "."
                                                                                     ($1:sub 1
                                                                                             1))
                                                                        :depth 2})]
                                 (do
                                   path))))
  (if (and repo? (playbook? (vim.fn.fnamemodify path ":t"))) :yaml.ansible
      (and repo? (task? (vim.fn.fnamemodify path ":."))) :yaml.ansible
      repo? (ansible-files? files)
      :yaml))

(vim.filetype.add {:extension {:yml yaml-filetype :yaml yaml-filetype}})
