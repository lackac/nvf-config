{lib, ...}: let
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryAfter;
in {
  vim = {
    languages.markdown = {
      enable = true;

      extensions.markview-nvim = {
        enable = true;
        setupOpts = {
          preview = {
            icon_provider = "mini";
          };
        };
      };
    };

    pluginRC.markview-extras = entryAfter ["markview-nvim"] ''
      require("markview.extras.checkboxes").setup({
        states = {
          { " ", "/", "X" },
          { "?", "!", "*" },
        },
      })
    '';

    autocmds = [
      {
        desc = "Markview buffer mappings";
        event = ["User"];
        pattern = ["MarkviewAttach"];
        callback = mkLuaInline ''
          function(event)
            local buf_id = event.data.buf_id

            vim.keymap.set('n', 'g.', "<cmd>Checkbox toggle<cr>", { buffer = buf_id, desc = "Toggle checkbox" })
            vim.keymap.set('n', 'gX', "<cmd>Checkbox interactive<cr>", { buffer = buf_id, desc = "Toggle checkbox (interactive)" })
          end
        '';
      }
    ];
  };
}
