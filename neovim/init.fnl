(fn build-init []
  (let [{: build} (require :hotpot.api.make)
        ;; by default, Fennel wont perform strict global checking when
        ;; compiling but we can force it to check by providing a list
        ;; of allowed global names, this can catch some additional errors in
        ;; this file.
        allowed-globals (icollect [n _ (pairs _G)] n)
        opts {:verbosity 1 ;; set to 1 (or dont inclued the key) to see messages
              :compiler {:modules {:allowedGlobals allowed-globals}}}]
    ;; just pass back the whole path as is
    (build "/home/mike/dotnix/neovim/init.fnl" opts ".+" #(values $1))))

(let [hotpot (require :hotpot)
      setup hotpot.setup
      build hotpot.api.make.build
      uv vim.loop]

  ;; do some configuration stuff
  (setup {:provide_require_fennel true
          :compiler {:modules {:correlate true}
                     :macros {:env :_COMPILER
                              :compilerEnv _G
                              :allowedGlobals false}}})

  ;; watch this file for changes and auto-rebuild on save
  (let [handle (uv.new_fs_event)
        ;; uv wont accept condensed paths
        path (vim.fn.expand "/home/mike/dotnix/neovim/init.fnl")]
    ;; note the vim.schedule call
    (uv.fs_event_start handle path {} #(vim.schedule build-init))
    ;; close the uv handle when we quit nvim
    (vim.api.nvim_create_autocmd :VimLeavePre {:callback #(uv.close handle)})))

(import-macros { : settings} :macros)

(tset (. vim "g") "mapleader" " ")
(tset (. vim "g") "maplocalleader" " ")

(vim.cmd "colorscheme gruvbox-material")

(settings 
  backup false 
  backupcopy yes)

(let [ts (require :nvim-treesitter.configs)] 
  ((. ts :setup
     {:highlight {:enable true}})))

(let [cmp (require :cmp)
      snip (fn [args] ((. (require :luasnip) :lsp_expand) (. args :body)))] 
  ((. cmp :setup) 
   {:snippet {:expand snip}
    :completion {:autocomplete false}
    :mapping 
    (cmp.mapping.preset.insert 
      {"<C-b>" (cmp.mapping.scroll_docs -4)
       "<C-A>" (cmp.mapping.complete)})
    :sources (cmp.config.sources
              [{:name :conjure} 
               {:name :nvim_lsp}
               {:name :path}
               {:name :luasnip}])}))

             

        
                           
; {}
;       snippet = {}
;                  -- REQUIRED - you must specify a snippet engine
;                  expand = function(args)
;                  require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
;                  end,
;       ,
;       completion = {}
;                     autocomplete = false
;       ,
;       window = {}
;                 -- completion = cmp.config.window.bordered(),
;                 -- documentation = cmp.config.window.bordered(),
;       ,
;       mapping = cmp.mapping.preset.insert({})
;                                            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
;                                            ['<C-f>'] = cmp.mapping.scroll_docs(4),
;                                            ['<C-A>'] = cmp.mapping.complete(),
;                                            ['<C-e>'] = cmp.mapping.abort(),
;                                            ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
;       ,
;       sources = cmp.config.sources({})
;                                     { name = 'conjure' },
;                                     { name = 'nvim_lsp' },
;                                     { name = 'luasnip' },
;                                     { name = 'path' },
;     
; 
