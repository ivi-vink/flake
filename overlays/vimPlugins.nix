{pkgs, ...}: (final: prev: {
  vimPlugins = let
    getVimPlugin = {
      name,
      git,
      rev,
      ref ? "master",
    }:
      pkgs.vimUtils.buildVimPlugin {
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
      nvim-cinnamon = getVimPlugin {
        name = "vim-easygrep";
        git = "declancm/cinnamon.nvim";
        rev = "e48538cba26f079822329a6d12b8cf2b916e925a";
      };
      nvim-nio = getVimPlugin {
        name = "nvim-nio";
        git = "nvim-neotest/nvim-nio";
        rev = "5800f585def265d52f1d8848133217c800bcb25d";
      };
      nvim-parinfer = getVimPlugin {
        name = "nvim-parinfer";
        git = "gpanders/nvim-parinfer";
        rev = "82bce5798993f4fe5ced20e74003b492490b4fe8";
      };
      codeium-vim = getVimPlugin {
        name = "codeium-vim";
        git = "Exafunction/codeium.vim";
        rev = "be2fa21f4f63850382a0cefeaa9f766b977c9f0c";
        ref = "refs/heads/main";
      };
    };
})
