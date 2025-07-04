{lib, ...}: let
  inherit (lib.nvim.binds) mkKeymap;
in {
  vim.utility.smart-splits = {
    enable = true;

    keymaps = {
      move_cursor_previous = null;
      swap_buf_left = null;
      swap_buf_right = null;
      swap_buf_up = null;
      swap_buf_down = null;
    };
  };

  vim.keymaps = [
    (mkKeymap "n" "<C-Left>" "function() require('smart-splits').move_cursor_left() end" {
      desc = "Focus window/pane on left";
      lua = true;
      silent = true;
    })
    (mkKeymap "n" "<C-Down>" "function() require('smart-splits').move_cursor_down() end" {
      desc = "Focus window/pane down";
      lua = true;
      silent = true;
    })
    (mkKeymap "n" "<C-Up>" "function() require('smart-splits').move_cursor_up() end" {
      desc = "Focus window/pane up";
      lua = true;
      silent = true;
    })
    (mkKeymap "n" "<C-Right>" "function() require('smart-splits').move_cursor_right() end" {
      desc = "Focus window/pane on right";
      lua = true;
      silent = true;
    })
  ];
}
