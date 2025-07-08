{lib, ...}: let
  inherit (lib.generators) mkLuaInline;
in {
  vim.autocomplete.blink-cmp = {
    enable = true;
    friendly-snippets.enable = true;

    mappings = {
      close = null;
      complete = null;
      confirm = null;
      next = null;
      previous = null;
      scrollDocsDown = null;
      scrollDocsUp = null;
    };

    sourcePlugins = {
      emoji.enable = true;
      spell.enable = true;
    };

    setupOpts = {
      keymap = {
        preset = "enter";

        "<C-space>" = [];
        "<C-s>" = ["show" "show_documentation" "hide_documentation"];
        "<C-y>" = ["select_and_accept"];
        "<CR>" = ["accept" "fallback"];

        "<C-d>" = ["scroll_documentation_down" "fallback"];
        "<C-u>" = ["scroll_documentation_up" "fallback"];
      };

      cmdline.sources = [];

      sources = {
        providers = {
          spell = {
            opts = {
              preselect_current_word = false;
              enable_in_context = mkLuaInline ''
                function()
                  local curpos = vim.api.nvim_win_get_cursor(0)
                  local captures = vim.treesitter.get_captures_at_pos(
                    0,
                    curpos[1] - 1,
                    curpos[2] - 1
                  )
                  local in_spell_capture = false
                  for _, cap in ipairs(captures) do
                    if cap.capture == 'spell' then
                      in_spell_capture = true
                    elseif cap.capture == 'nospell' then
                      return false
                    end
                  end
                  return in_spell_capture
                end
              '';
            };
          };
        };
      };

      snippets.preset = "luasnip";

      signature = {
        enabled = true;
        window.border = "rounded";
      };

      completion = {
        list = {
          selection = {
            preselect = true;
            auto_insert = true;
          };
        };
        trigger.show_in_snippet = false;

        documentation.window.border = "rounded";
        menu.border = "rounded";
      };
    };
  };
}
