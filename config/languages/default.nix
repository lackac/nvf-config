{
  imports = [
    ./diagnostics.nix
    ./treesitter.nix
    ./lsp.nix

    ./lua.nix
    ./nix.nix
    ./ruby.nix
  ];

  vim.languages = {
    enableTreesitter = true;
    enableFormat = true;
    enableExtraDiagnostics = true;
  };
}
