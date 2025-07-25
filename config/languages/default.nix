{
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

  vim.languages = {
    enableTreesitter = true;
    enableFormat = true;
    enableExtraDiagnostics = true;
  };
}
