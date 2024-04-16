{...}: (final: prev: {
  tree-sitter = mvinkioPkgs.tree-sitter;
  vimPlugins =
    prev.vimPlugins
    // {
      nvim-treesitter = mvinkioPkgs.vimPlugins.nvim-treesitter.overrideAttrs (old: {
        version = "2022-10-28";
        passthru.withPlugins = grammarFn:
          final.vimPlugins.nvim-treesitter.overrideAttrs (_: {
            postPatch = let
              grammars = mvinkioPkgs.tree-sitter.withPlugins grammarFn;
            in ''
              rm -r parser
              ln -s ${grammars} parser
            '';
          });
      });
    };
})
