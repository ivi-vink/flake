(let [nt (require :neotest)
      python (require :neotest-python)]
  (nt.setup {:adapters [(python {:dap {:justMyCode false}})]}))

