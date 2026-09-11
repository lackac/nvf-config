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
    opencode-nvim = {
      url = "github:nickjvandyke/opencode.nvim";
      flake = false;
    };
    codediff-nvim = {
      url = "github:esmuellert/codediff.nvim/v4.0.2";
      flake = false;
    };
    review-nvim = {
      url = "github:georgeguimaraes/review.nvim/v1.9.1";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      nvf,
      opencode-nvim,
      codediff-nvim,
      review-nvim,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      pluginOverlay = final: prev: {
        codediff-watcher =
          let
            version = "0.23.2";
            sources = {
              aarch64-darwin = {
                platform = "macos-arm64";
                hash = "sha256-IiWOlWRh+dFHEhKvBXUTafEbrOLvhXA9RnYvZm5BdaE=";
              };
              aarch64-linux = {
                platform = "linux-arm64";
                hash = "sha256-F4oRo4XbAko9UTKg4U64Y+fi2Bbix2O8fdpbYKCCUiI=";
              };
              x86_64-linux = {
                platform = "linux-x64";
                hash = "sha256-iJk4gvKAQwSA6S3CV0MLVyID/ErNOITM98rFztsJEQI=";
              };
            };
            source = sources.${prev.stdenv.hostPlatform.system};
          in
          prev.stdenvNoCC.mkDerivation {
            pname = "codediff-watcher";
            inherit version;
            src = prev.fetchzip {
              url = "https://github.com/esmuellert/codediff/releases/download/v${version}/codediff-watcher-${version}-${source.platform}.tar.gz";
              inherit (source) hash;
              stripRoot = false;
            };
            nativeBuildInputs = prev.lib.optionals prev.stdenv.hostPlatform.isLinux [ prev.autoPatchelfHook ];
            buildInputs = prev.lib.optionals prev.stdenv.hostPlatform.isLinux [ prev.stdenv.cc.cc.lib ];
            installPhase = ''
              runHook preInstall
              mkdir -p "$out/bin"
              install -Dm755 codediff-watcher "$out/bin/codediff-watcher"
              runHook postInstall
            '';
          };

        vimPlugins = prev.vimPlugins // {
          opencode-nvim = prev.vimUtils.buildVimPlugin {
            pname = "opencode-nvim";
            version = "unstable";
            src = opencode-nvim;
          };
          codediff-nvim = prev.vimPlugins.codediff-nvim.overrideAttrs {
            name = "vimplugin-codediff.nvim-4.0.2";
            version = "4.0.2";
            src = codediff-nvim;
            patches = [ ./config/git/codediff-staging.patch ];
          };
          review-nvim = prev.vimUtils.buildVimPlugin {
            pname = "review.nvim";
            version = "1.9.1";
            src = review-nvim;
            dependencies = [ prev.vimPlugins.nui-nvim ];
            patches = [
              ./config/git/review-paths.patch
              ./config/git/review-opencode.patch
            ];
          };
        };
      };

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ pluginOverlay ];
        };
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
