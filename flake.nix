{
  description = "Standalone neovim configuration in nvf";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      # url = "path:/Users/lackac/Code/notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      nvf,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      pkgsFor = system: import nixpkgs { inherit system; };
      forEachSystem = f: lib.genAttrs systems (system: f (pkgsFor system));
      treefmtEval = forEachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      # Export the base configuration module for reuse in other flakes
      nvfModules.default = import ./config;

      packages = forEachSystem (pkgs: rec {
        default = nvf-config;
        nvf-config =
          (nvf.lib.neovimConfiguration {
            inherit pkgs;
            modules = [ self.nvfModules.default ];
          }).neovim;
        inspect = pkgs.writeShellApplication {
          name = "nvf-inspect-config";
          text = ''nvim "$(${nvf-config}/bin/nvf-print-config-path)"'';
        };
      });

      devShells = forEachSystem (
        pkgs:
        let
          packages = self.packages.${pkgs.stdenv.hostPlatform.system};
        in
        {
          default = pkgs.mkShell {
            packages =
              with pkgs;
              [
                git
              ]
              ++ [
                packages.nvf-config
                packages.inspect
              ];
          };
        }
      );

      formatter = forEachSystem (
        pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper
      );

      checks = forEachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.check self;
      });
    };
}
