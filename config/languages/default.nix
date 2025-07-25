{lib, ...}: let
  extraLanguages = ["bash" "clang" "css" "gleam" "go" "html" "python" "rust" "sql" "terraform" "ts" "typst"];
in {
  imports = [
    ./diagnostics.nix
    ./treesitter.nix
    ./lsp.nix

    ./elixir.nix
    ./lua.nix
    ./markdown.nix
    ./nix.nix
    ./ruby.nix
  ];

  vim.languages =
    {
      enableTreesitter = true;
      enableFormat = true;
      enableExtraDiagnostics = true;
    }
    // lib.genAttrs extraLanguages (_: {enable = true;});
}
