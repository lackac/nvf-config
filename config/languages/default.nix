{
  imports = [
    ./treesitter.nix
    ./lsp.nix
    ./nix.nix
    ./lua.nix
  ];

  vim.languages = {
    enableTreesitter = true;
    enableFormat = true;
    enableExtraDiagnostics = true;
  };
}
