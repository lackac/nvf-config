{
  description = "Standalone neovim configuration in nvf";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nvf = {
      url = "github:notashelf/nvf";
      # url = "path:/Users/lackac/Code/notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nvf,
    ...
  }: let
    inherit (nixpkgs) lib;
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    pkgsFor = system: import nixpkgs {inherit system;};
    forEachSystem = f: lib.genAttrs systems (system: f (pkgsFor system));
  in {
    # Export the base configuration module for reuse in other flakes
    nvfModules.default = import ./config;

    packages = forEachSystem (pkgs: rec {
      default = nvf-config;
      nvf-config =
        (nvf.lib.neovimConfiguration {
          inherit pkgs;
          modules = [self.nvfModules.default];
        }).neovim;
      inspect = pkgs.writeShellApplication {
        name = "nvf-inspect-config";
        text = ''nvim "$(${nvf-config}/bin/nvf-print-config-path)"'';
      };
    });

    devShells = forEachSystem (
      pkgs: let
        packages = self.packages.${pkgs.stdenv.hostPlatform.system};
      in {
        default = pkgs.mkShell {
          packages = with pkgs;
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

    # Format the nix code in this flake
    # alejandra is a nix formatter with a beautiful output
    formatter = forEachSystem (pkgs: pkgs.alejandra);
  };
}
