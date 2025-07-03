{
  vim.statusline.lualine = {
    enable = true;
    disabledFiletypes = ["snacks_dashboard"];
    refresh = {
      statusline = 100;
      tabline = 100;
      winbar = 100;
    };
    sectionSeparator = {
      left = "";
      right = "";
    };
    componentSeparator = {
      left = "";
      right = "";
    };

    activeSection = {
      a = [
        ''{ "mode" }''
      ];

      b = [
        ''
          {
            "filetype",
            colored = true,
            icon_only = true,
            separator = "",
            padding = { left = 1, right = 0 },
          }
        ''
        ''
          {
            "filename",
            path = 1,
            symbols = {modified = '', readonly = ''},
            padding = { left = 0, right = 1 },
          }
        ''
      ];

      c = [
        ''
          {
            "diff",
            colored = true,
            symbols = {
              added    = " ",
              modified = " ",
              removed  = " ",
            },
          }
        ''
      ];

      x = [
        ''
          require('snacks').profiler.status()
        ''
        ''
          {
            -- Lsp server name
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
            end,
            icon = ' ',
          }
        ''
        ''
          {
            "diagnostics",
            sources = {'nvim_lsp', 'nvim_diagnostic', 'nvim_diagnostic', 'vim_lsp', 'coc'},
            symbols = {error = '󰅙  ', warn = '  ', info = '  ', hint = '󰌵 '},
            colored = true,
            update_in_insert = false,
            always_visible = false,
            diagnostics_color = {
              color_error = { fg = 'red' },
              color_warn = { fg = 'yellow' },
              color_info = { fg = 'cyan' },
            },
          }
        ''
      ];

      y = [
        ''
          { "branch" }
        ''
      ];

      z = [
        ''
          { "progress", separator = " ", padding = { left = 1, right = 0 } }
        ''
        ''
          { "location", padding = { left = 0, right = 1 } }
        ''
      ];
    };
  };
}
