{ lib, pkgs, ... }:
let
  inherit (lib.nvim.binds) mkKeymap;
in
{
  vim.extraPlugins.opencode = {
    package = pkgs.vimPlugins.opencode-nvim;
    setup = builtins.readFile ./opencode.lua;
  };

  vim.keymaps = [
    (mkKeymap [ "n" "x" ] "<leader>aa" ''function() require("opencode").ask("@this: ") end'' {
      desc = "Ask OpenCode";
      lua = true;
      silent = true;
    })
    (mkKeymap [ "n" "x" ] "<leader>a." ''function() require("opencode").select() end'' {
      desc = "OpenCode Actions";
      lua = true;
      silent = true;
    })
    (mkKeymap [ "n" "x" ] "<leader>ax" ''function() require("opencode").prompt("explain") end'' {
      desc = "Explain With OpenCode";
      lua = true;
      silent = true;
    })
  ];
}
