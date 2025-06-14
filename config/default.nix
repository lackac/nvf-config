{
  imports = [
    ./options.nix
    ./colorscheme.nix
    ./autocmds.nix
    ./editing
    ./navigation
  ];

  vim = {
    viAlias = true;
    vimAlias = true;
    enableLuaLoader = true;
  };
}
