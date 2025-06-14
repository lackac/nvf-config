{
  imports = [
    ./options.nix
    ./colorscheme.nix
    ./editing
    ./navigation
  ];

  vim = {
    viAlias = true;
    vimAlias = true;
    enableLuaLoader = true;
  };
}
