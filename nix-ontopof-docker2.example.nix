
{
  description = "Nix packages on top of docker pattern";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in
    {

      # Requires dirty nixbld with access to docker daemon
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};

          # from: https://github.com/nix-community/home-manager/blob/70824bb5c790b820b189f62f643f795b1d2ade2e/modules/programs/neovim.nix#L412
          neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
            viAlias = true;
            vimAlias = true;
            withPython3 = false;
            withRuby = false;
            withNodeJs = false;
            extraPython3Packages = _: [];
            extraLuaPackages = _: [];

            plugins = with pkgs.vimPlugins; [
              # highlighting
              nvim-treesitter.withAllGrammars
              playground
              gruvbox-material
              kanagawa-nvim
              lsp_lines-nvim
              gitsigns-nvim
              vim-helm
              lualine-nvim

              # external
              oil-nvim
              vim-fugitive
              venn-nvim
              gv-vim
              zoxide-vim
              obsidian-nvim
              go-nvim

              # Coding
              fzf-lua
              nvim-lspconfig
              null-ls-nvim
              lsp_signature-nvim
              nvim-dap
              nvim-dap-ui
              nvim-nio
              nvim-dap-python
              luasnip
              vim-test
              nvim-lint
              vim-surround
              conform-nvim
              trouble-nvim
              vim-easy-align
              nvim-comment

              # cmp
              nvim-cmp
              cmp-cmdline
              cmp-nvim-lsp
              cmp-buffer
              cmp-path
              cmp_luasnip

              # conjure
              vim-racket
              nvim-parinfer
              hotpot-nvim
            ];
            customRC = "";
          };

          neovim-package = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (neovimConfig
            // {
              wrapRc = false;
            });

          st-terminfo = with pkgs; stdenv.mkDerivation rec {
            pname = "st-terminfo";
            version = "0.9.2";

            src = fetchurl {
              url = "https://dl.suckless.org/st/st-${version}.tar.gz";
              hash = "sha256-ayFdT0crIdYjLzDyIRF6d34kvP7miVXd77dCZGf5SUs=";
            };

            nativeBuildInputs = [ ncurses ];

            outputs = [ "out" ];

            buildPhase = ''
            echo no build
            '';
            installPhase = ''
            export HOME=$(mktemp -d)
            mkdir -p "$out/share/terminfo"
            cat st.info | tic -x -o "$out/share/terminfo" -
            '';
          };

          nvim-container = pkgs.dockerTools.buildImage {
            name =  "nvim-container";
            tag = "latest";
            copyToRoot = pkgs.buildEnv {
              extraPrefix = "/usr";
              name = "neovim-nix-ide-usr";
              paths =  with pkgs; [
                neovim-package
                docker-client
                zoxide
                xclip
                k9s
                st-terminfo
              ];
            };
          };
# # TODO: this is just for me
# RUN curl -sSL https://raw.githubusercontent.com/Shourai/st/refs/heads/master/st.info | tic -x -
        in
        {
          nvim-container-install = pkgs.writeShellScriptBin "nvim-container-install" ''
            #!/bin/sh
            docker image load -i ${nvim-container}
            Dockerfile="/tmp/$(id -u)/nix-ontop-docker"
            mkdir -p "$(dirname "$Dockerfile")"
            cat <<DOCKERFILE >"$Dockerfile"
            FROM pionativedev.azurecr.io/pionative/pnsh-ide-support:latest
            COPY --from=nvim-container:latest /usr /usr
            DOCKERFILE
            docker build -f "$Dockerfile" -t pionativedev.azurecr.io/pionative/pnsh-nvim:latest -- .
          '';
        });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.neovim-container);
    };
}
