{
  imports = [
    ./options.nix
    ./colorscheme.nix
    ./autocmds.nix
    ./snacks.nix
    ./keymaps.nix
    ./editing
    ./navigation
  ];

  vim = {
    viAlias = true;
    vimAlias = true;
    enableLuaLoader = true;
  };
}
