{ lib, ... }:
let
  inherit (lib.generators) mkLuaInline;
in {
  vim.utility.snacks-nvim = {
    enable = true;
    setupOpts = {
      animate.enabled = true; # Efficient animations including over 45 easing functions (library)
      bigfile.enabled = true; # Deal with big files
      bufdelete.enabled = true; # Delete buffers without disrupting window layout
      # dashboard.enabled = true; # Beautiful declarative dashboards
      debug.enabled = true; # Pretty inspect & backtraces for debugging
      dim.enabled = true; # Focus on the active scope by dimming the rest
      # explorer.enabled = true; # A file explorer (picker in disguise)
      git.enabled = true; # Git utilities
      gitbrowse.enabled = true; # Open the current file, branch, commit, or repo in a browser (e.g. GitHub, GitLab, Bitbucket)
      image.enabled = true; # Image viewer using Kitty Graphics Protocol, supported by kitty, wezterm and ghostty
      indent.enabled = true; # Indent guides and scopes
      input.enabled = true; # Better vim.ui.input
      layout.enabled = true; # Window layouts
      # lazygit.enabled = true; # Open LazyGit in a float, auto-configure colorscheme and integration with Neovim
      notifier.enabled = true; # Pretty vim.notify
      notify.enabled = true; # Utility functions to work with Neovim's vim.notify
      # picker.enabled = true; # Picker for selecting items
      profiler.enabled = true; # Neovim lua profiler
      quickfile.enabled = true; # When doing nvim somefile.txt, it will render the file as quickly as possible, before loading your plugins.
      # TODO rename.enabled = true; # LSP-integrated file renaming with support for plugins like neo-tree.nvim and mini.files.
      scope.enabled = true; # Scope detection, text objects and jumping based on treesitter or indent
      scratch.enabled = true; # Scratch buffers with a persistent file
      # scroll.enabled = true; # Smooth scrolling
      statuscolumn.enabled = true; # Pretty status column
      # terminal.enabled = true; # Create and toggle floating/split terminals
      toggle.enabled = true; # Toggle keymaps integrated with which-key icons / colors
      util.enabled = true; # Utility functions for Snacks (library)
      win.enabled = true; # Create and manage floating windows or splits
      words.enabled = true; # Auto-show LSP references and quickly navigate between them
      zen.enabled = true; # Zen mode • distraction-free coding

      indent = {
        indent.char = "┊";
      };
    };
  };

  vim.autocmds = [
    {
      desc = "Setup Snacks debug and toggle functionality";
      event = ["User"];
      pattern = ["DeferredUIEnter"]; # triggered by lz.n after load() is done and after UIEnter
      callback = mkLuaInline ''
        function()
          -- Setup some globals for debugging
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd -- Override print to use snacks for `:=` command

          -- Create some toggle mappings
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
          Snacks.toggle.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" }):map("<leader>uA")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
          Snacks.toggle.dim():map("<leader>uD")
          Snacks.toggle.animate():map("<leader>ua")
          Snacks.toggle.inlay_hints():map("<leader>uh")
          Snacks.toggle.indent():map("<leader>ug")
          Snacks.toggle.scroll():map("<leader>uS")
          Snacks.toggle.profiler():map("<leader>dpp")
          Snacks.toggle.profiler_highlights():map("<leader>dph")
          Snacks.toggle.zen():map("<leader>uz")
          Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")

          local tsc = require("treesitter-context")
          Snacks.toggle({
            name = "Treesitter Context",
            get = tsc.enabled,
            set = function(state)
              if state then
                tsc.enable()
              else
                tsc.disable()
              end
            end,
          }):map("<leader>ut")
        end
      '';
    }
  ];
}
