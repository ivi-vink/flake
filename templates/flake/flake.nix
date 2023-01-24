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
      python = pkgs.python310;
      poetry = inputs.poetry2nix.packages.${system}.poetry;
      inherit (inputs.poetry2nix.legacyPackages.${system}) mkPoetryEnv defaultPoetryOverrides;

      more-providers = inputs.nixpkgs-terraform-providers-bin.legacyPackages.${system}.providers;
      terraform = pkgs.terraform.withPlugins (p: [
        more-providers.microsoft.azuredevops
      ]);
    in {
      devShells.default = pkgs.mkShell {
        name = "default-shell";
        buildInputs = [
          terraform
          poetry
          pkgs.nodejs
        ];
      };
    });
}
