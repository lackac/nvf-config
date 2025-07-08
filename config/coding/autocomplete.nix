{
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
      ripgrep.enable = true;
      spell.enable = true;
    };

    setupOpts = {
      keymap = {
        preset = "enter";

        "<C-space>" = [];
        "<C-y>" = ["select_and_accept"];

        "<C-d>" = ["scroll_documentation_down" "fallback"];
        "<C-u>" = ["scroll_documentation_up" "fallback"];
        "<esc>" = ["hide" "fallback"];
      };

      cmdline.sources = [];

      sources = {
        default = [
          "snippets"
          "lsp"
          "path"
          "ripgrep"
          "buffer"
          "emoji"
        ];
      };

      snippets.preset = "luasnip";

      signature = {
        enabled = true;
        window.border = "rounded";
      };

      completion = {
        list = {
          selection = {
            preselect = false;
            auto_insert = true;
          };
        };

        documentation.window.border = "rounded";
        menu.border = "rounded";
      };
    };
  };
}
