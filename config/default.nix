{
  config,
  lib,
  ...
}: {
  options.nvf-config = {
    enabledLanguages = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      description = "List of languages to enable. null means all languages are enabled.";
    };
  };

  imports = [
    ./options.nix
    ./colorscheme.nix
    ./autocmds.nix
    ./keymaps.nix
    ./snacks.nix
    ./editing
    ./coding
    ./git
    ./ui
    ./navigation
    ./languages
    ./notes
  ];

  config = {
    vim = {
      viAlias = true;
      vimAlias = true;
      enableLuaLoader = true;
    };
  };
}
