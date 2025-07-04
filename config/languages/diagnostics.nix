{lib, ...}: let
  inherit (lib.generators) mkLuaInline;
in {
  vim.diagnostics = {
    enable = true;

    config = {
      underline = true;
      virtual_text = true;
      signs.text = mkLuaInline ''
        {
          [vim.diagnostic.severity.ERROR] = "󰅚 ",
          [vim.diagnostic.severity.WARN] = "󰀪 ",
          [vim.diagnostic.severity.INFO] = " ",
          [vim.diagnostic.severity.HINT] = "󰌵 ",
        }
      '';

      nvim-lint.enable = true;
    };
  };
}
