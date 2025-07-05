{
  imports = [
    ./options.nix
    ./colorscheme.nix
    ./autocmds.nix
    ./keymaps.nix
    ./snacks.nix
    ./editing
    ./coding
    ./ui
    ./navigation
    ./languages
    ./notes
  ];

  vim = {
    viAlias = true;
    vimAlias = true;
    enableLuaLoader = true;
  };
}
