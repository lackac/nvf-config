{ lib, ... }:
let
  inherit (lib.nvim.binds) mkKeymap;
in {
  vim.utility.oil-nvim = {
    enable = true;
    setupOpts = {
      keymaps = {
        "<C-h>" = false;
        "<C-l>" = false;
        "<C-t>" = false;
        "<C-s>" = "actions.select_split";
        "<C-x>" = "actions.select_split";
        "<C-v>" = "actions.select_vsplit";
      };
    };
  };

  vim.keymaps = [
    (mkKeymap "n" "-" "function() require('oil').open() end" { desc = "Open parent directory"; lua = true; silent = true; })
  ];
}
