{lib, ...}: let
  inherit (lib.nvim.dag) entryAfter;
in {
  vim = {
    mini.icons = {
      enable = true;
    };

    pluginRC.mini-icons-extra = entryAfter ["mini-icons"] ''
      MiniIcons.mock_nvim_web_devicons()
    '';
  };
}
