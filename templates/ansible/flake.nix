{
  inputs = {
    nixpkgs.url = "nixpkgs";
    nix-filter.url = "github:numtide/nix-filter";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-terraform-providers-bin.url = "github:nix-community/nixpkgs-terraform-providers-bin";
    nixpkgs-terraform-providers-bin.inputs.nixpkgs.follows = "nixpkgs";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs =
        import inputs.nixpkgs
        {
          inherit system;
        };
      poetry = inputs.poetry2nix.packages.${system}.poetry;
      inherit (inputs.poetry2nix.legacyPackages.${system}) mkPoetryEnv defaultPoetryOverrides;
    in {
      devShells.default = pkgs.mkShell {
        name = "dev";
        buildInputs = [
          poetry
          pkgs.ansible-language-server
          pkgs.bashInteractive
        ];
        shellHook = ''
          [[ -f ./.venv/bin/activate ]] && {
              source ./.venv/bin/activate
              source ~/awx-login.sh
              # NOTE(mike): this is necessary to make ansible-lint work with
              # playbooks that use:
              #vars_files:
              #  - ./secrets/vault.yaml
              initool s ansible.cfg defaults vault_identity devena | initool s - defaults vault_password_file ~/pass-ansible-vault-client > /tmp/ansible.cfg
              cp /tmp/ansible.cfg ansible.cfg
          }
        '';
      };
    });
}
