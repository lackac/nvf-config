{ lib, pkgs, ... }:
let
  inherit (lib.nvim.binds) mkKeymap;
  inherit (lib.generators) mkLuaInline;
in
{
  vim.utility.smart-splits = {
    enable = true;

    setupOpts.mux.backend = mkLuaInline ''
      function()
        if vim.env.TMUX and vim.env.TMUX ~= "" then
          return "smart-splits-backend-tmux"
        elseif vim.env.REX_SESSION and vim.env.REX_SESSION ~= ""
          and vim.env.REX_BLOCK and vim.env.REX_BLOCK ~= "" then
          return "smart-splits-backend-rex"
        end
        return {}
      end
    '';

    keymaps = {
      move_cursor_previous = null;
      swap_buf_left = null;
      swap_buf_right = null;
      swap_buf_up = null;
      swap_buf_down = null;
    };
  };

  vim.extraPlugins = {
    smart-splits-backend-rex.package = pkgs.vimPlugins.smart-splits-backend-rex;
    smart-splits-backend-tmux.package = pkgs.vimPlugins.smart-splits-backend-tmux;
  };

  # nvf's bundled smart-splits is still v2; the pinned nixpkgs provides v3.
  vim.lazy.plugins.smart-splits.package = lib.mkForce (
    pkgs.vimPlugins.smart-splits-nvim.overrideAttrs { pname = "smart-splits"; }
  );

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
