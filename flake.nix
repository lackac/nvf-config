{
  description = "Standalone neovim configuration in nvf";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, nvf, ... }:
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
    in
    {
      packages = forEachSystem (pkgs: rec {
        default = nvf-config;
        nvf-config = (nvf.lib.neovimConfiguration {
          inherit pkgs;
          modules = [ (import ./config) ];
        }).neovim;
        inspect = pkgs.writeShellApplication {
          name = "nvf-inspect-config";
          text = ''nvim "$(${nvf-config}/bin/nvf-print-config-path)"'';
        };
      });

      devShells = forEachSystem (pkgs:
        let
          packages = self.packages.${pkgs.system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              git
            ] ++ [
              packages.nvf-config
              packages.inspect
            ];
          };
        });
    };
}
