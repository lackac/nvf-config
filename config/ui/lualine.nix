{ lib, ... }:
let
  inherit (lib.generators) mkLuaInline;
in
{
  vim.statusline.lualine = {
    enable = true;
    setupOpts.options.disabled_filetypes.statusline = [ "snacks_dashboard" ];
    setupOpts.options.refresh = {
      statusline = 100;
      tabline = 100;
      winbar = 100;
    };
    setupOpts.options.section_separators = {
      left = "";
      right = "";
    };
    setupOpts.options.component_separators = {
      left = "";
      right = "";
    };

    setupOpts.sections = {
      lualine_a = [
        { "@1" = "mode"; }
      ];

      lualine_b = [
        {
          "@1" = "filetype";
          colored = true;
          icon_only = true;
          separator = "";
          padding = {
            left = 1;
            right = 0;
          };
        }
        {
          "@1" = "filename";
          path = 1;
          symbols = {
            modified = "";
            readonly = "";
          };
          padding = {
            left = 0;
            right = 1;
          };
        }
      ];

      lualine_c = [
        {
          "@1" = "diff";
          colored = true;
          symbols = {
            added = " ";
            modified = " ";
            removed = " ";
          };
        }
      ];

      lualine_x = [
        (mkLuaInline ''
          require('snacks').profiler.status()
        '')
        {
          "@1" = mkLuaInline ''require("noice").api.status.command.get'';
          cond = mkLuaInline ''require("noice").api.status.command.has'';
          color = mkLuaInline ''function() return { fg = Snacks.util.color("Statement") } end'';
        }
        {
          "@1" = mkLuaInline ''require("noice").api.status.mode.get'';
          cond = mkLuaInline ''require("noice").api.status.mode.has'';
          color = mkLuaInline ''function() return { fg = Snacks.util.color("Constant") } end'';
        }
        {
          "@1" = mkLuaInline ''
            function()
              local buf_ft = vim.bo.filetype
              local excluded_buf_ft = { toggleterm = true, NvimTree = true, ["neo-tree"] = true, TelescopePrompt = true }

              if excluded_buf_ft[buf_ft] then
                return ""
              end

              local bufnr = vim.api.nvim_get_current_buf()
              local clients = vim.lsp.get_clients({ bufnr = bufnr })

              if vim.tbl_isempty(clients) then
                return "No Active LSP"
              end

              local active_clients = {}
              for _, client in ipairs(clients) do
                table.insert(active_clients, client.name)
              end

              return table.concat(active_clients, ", ")
            end
          '';
          icon = " ";
        }
        {
          "@1" = "diagnostics";
          sources = [
            "nvim_lsp"
            "nvim_diagnostic"
            "vim_lsp"
            "coc"
          ];
          symbols = {
            error = "󰅙  ";
            warn = "  ";
            info = "  ";
            hint = "󰌵 ";
          };
          colored = true;
          update_in_insert = false;
          always_visible = false;
          diagnostics_color = {
            color_error.fg = "red";
            color_warn.fg = "yellow";
            color_info.fg = "cyan";
          };
        }
      ];

      lualine_y = [
        { "@1" = "branch"; }
      ];

      lualine_z = [
        {
          "@1" = "progress";
          separator = " ";
          padding = {
            left = 1;
            right = 0;
          };
        }
        {
          "@1" = "location";
          padding = {
            left = 0;
            right = 1;
          };
        }
      ];
    };
  };
}
