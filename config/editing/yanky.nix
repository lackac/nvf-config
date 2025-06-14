{ lib, ... }:
let
  inherit (lib.nvim.binds) mkKeymap;
in {
  vim.utility.yanky-nvim = {
    enable = true;
    setupOpts.ring.storage = "sqlite";
  };

  vim.keymaps = [
    (mkKeymap ["n" "x"] "<leader>p" "<cmd>YankyRingHistory<cr>" {desc = "Open Yank History";})
    (mkKeymap ["n" "x"] "y" "<Plug>(YankyYank)" {desc = "Yank Text";})
    (mkKeymap ["n" "x"] "p" "<Plug>(YankyPutAfter)" {desc = "Put Text After Cursor";})
    (mkKeymap ["n" "x"] "P" "<Plug>(YankyPutBefore)" {desc = "Put Text Before Cursor";})
    (mkKeymap ["n" "x"] "gp" "<Plug>(YankyGPutAfter)" {desc = "Put Text After Selection";})
    (mkKeymap ["n" "x"] "gP" "<Plug>(YankyGPutBefore)" {desc = "Put Text Before Selection";})
    (mkKeymap "n" "[y" "<Plug>(YankyCycleForward)" {desc = "Cycle Forward Through Yank History";})
    (mkKeymap "n" "]y" "<Plug>(YankyCycleBackward)" {desc = "Cycle Backward Through Yank History";})
    (mkKeymap "n" "]p" "<Plug>(YankyPutIndentAfterLinewise)" {desc = "Put Indented After Cursor (Linewise)";})
    (mkKeymap "n" "[p" "<Plug>(YankyPutIndentBeforeLinewise)" {desc = "Put Indented Before Cursor (Linewise)";})
    (mkKeymap "n" "]P" "<Plug>(YankyPutIndentAfterLinewise)" {desc = "Put Indented After Cursor (Linewise)";})
    (mkKeymap "n" "[P" "<Plug>(YankyPutIndentBeforeLinewise)" {desc = "Put Indented Before Cursor (Linewise)";})
    (mkKeymap "n" ">p" "<Plug>(YankyPutIndentAfterShiftRight)" {desc = "Put and Indent Right";})
    (mkKeymap "n" "<p" "<Plug>(YankyPutIndentAfterShiftLeft)" {desc = "Put and Indent Left";})
    (mkKeymap "n" ">P" "<Plug>(YankyPutIndentBeforeShiftRight)" {desc = "Put Before and Indent Right";})
    (mkKeymap "n" "<P" "<Plug>(YankyPutIndentBeforeShiftLeft)" {desc = "Put Before and Indent Left";})
    (mkKeymap "n" "=p" "<Plug>(YankyPutAfterFilter)" {desc = "Put After Applying a Filter";})
    (mkKeymap "n" "=P" "<Plug>(YankyPutBeforeFilter)" {desc = "Put Before Applying a Filter";})
  ];
}
