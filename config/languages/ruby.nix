{
  lib,
  config,
  ...
}: let
  inherit (lib.generators) mkLuaInline;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.languages.ruby;
in {
  vim = {
    languages.ruby = {
      enable = true;

      format.enable = false;
      extraDiagnostics.enable = false;
    };

    formatter.conform-nvim = {
      enable = true;
      setupOpts.formatters_by_ft.ruby = ["rubocop"];
      setupOpts.formatters.rubocop = mkLuaInline ''
        function(bufnr)
          return {
            command = require("conform.util").find_executable({
              "bin/rubocop",
            }, "${getExe cfg.format.package}"),
          }
        end
      '';
    };

    diagnostics.nvim-lint = {
      enable = true;
      linters_by_ft.ruby = ["rubocop"];
    };

    luaConfigRC.rubocop-linter = entryAfter ["pluginConfigs"] ''
      require('lint').linters.rubocop.cmd = function()
        return require("conform").get_formatter_info("rubocop").command
      end
    '';
  };
}
