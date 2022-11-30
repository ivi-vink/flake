{pkgs, ...}: (final: prev: {
  vimPlugins = let
    getVimPlugin = {
      name,
      git,
      rev,
      ref ? "master",
    }:
      pkgs.vimUtils.buildVimPluginFrom2Nix {
        inherit name;
        src = builtins.fetchGit {
          url = "https://github.com/${git}";
          submodules = true;
          inherit rev;
          inherit ref;
        };
      };
  in
    prev.vimPlugins
    // {
      neotest-python = getVimPlugin {
        name = "neotest-python";
        git = "nvim-neotest/neotest-python";
        rev = "e53920d145d37783c8d8428365a0a230e0a18cb5";
      };
      firvish-nvim = getVimPlugin {
        name = "firvish-nvim";
        git = "Furkanzmc/firvish.nvim";
        rev = "127f9146175d6bbaff6a8b761081cfd2279f8351";
      };
      nvim-parinfer = getVimPlugin {
        name = "nvim-parinfer";
        git = "gpanders/nvim-parinfer";
        rev = "82bce5798993f4fe5ced20e74003b492490b4fe8";
      };
      vim-just = getVimPlugin {
        name = "vim-just";
        git = "NoahTheDuke/vim-just";
        rev = "838c9096d4c5d64d1000a6442a358746324c2123";
      };
      vim-rest-console = getVimPlugin {
          name = "vim-rest-console";
          git = "diepm/vim-rest-console";
          rev = "7b407f47185468d1b57a8bd71cdd66c9a99359b2";
      };
    };
})
