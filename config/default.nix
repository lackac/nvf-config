{
  imports = [
    ./options.nix
    ./colorscheme.nix
    ./editing
  ];

  vim = {
    viAlias = true;
    vimAlias = true;
    enableLuaLoader = true;
  };
}
