{
  imports = [
    ./options.nix
    ./colorscheme.nix
  ];

  vim = {
    viAlias = true;
    vimAlias = true;
    enableLuaLoader = true;
  };
}
