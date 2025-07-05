{lib, ...}: let
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.binds) mkKeymap;
in {
  vim.ui.nvim-ufo = {
    enable = true;
    setupOpts = {
      provider_selector = mkLuaInline ''
        function(bufnr, filetype, buftype)
          return {'treesitter', 'indent'}
        end
      '';
    };
  };

  vim.keymaps = [
    (mkKeymap "n" "zR" "require('ufo').openAllFolds" {
      desc = "Open all folds";
      lua = true;
    })
    (mkKeymap "n" "zM" "require('ufo').closeAllFolds" {
      desc = "Close all folds";
      lua = true;
    })
  ];
}
