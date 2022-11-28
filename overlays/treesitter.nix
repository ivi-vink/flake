{mvinkioPkgs, ...}: (final: prev: {
  tree-sitter = mvinkioPkgs.tree-sitter;
  vimPlugins =
    prev.vimPlugins
    // {
      nvim-treesitter = mvinkioPkgs.vimPlugins.nvim-treesitter.overrideAttrs (old: {
        version = "2022-10-28";
        src = builtins.fetchGit {
          url = "file:///home/mike/projects/nvim-treesitter";
          rev = "2c0ae6e8e81366ba088f1e5be62f467212cda52e";
        };
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
