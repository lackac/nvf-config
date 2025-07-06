{lib, ...}: let
  inherit (lib.generators) mkLuaInline;
in {
  vim.autocmds = [
    {
      desc = "Effectively disable the command line window to prevent opening it accidentally when pressing 'q:'";
      event = ["CmdWinEnter"];
      callback = mkLuaInline ''
        function()
          vim.cmd("quit")
        end
      '';
    }

    {
      desc = "Check if we need to reload the file when it changed";
      event = ["FocusGained" "TermClose" "TermLeave"];
      callback = mkLuaInline ''
        function()
          if vim.o.buftype ~= "nofile" then
            vim.cmd("checktime")
          end
        end
      '';
    }

    {
      desc = "Highlight on yank";
      event = ["TextYankPost"];
      callback = mkLuaInline ''
        function()
          (vim.hl or vim.highlight).on_yank()
        end
      '';
    }

    {
      desc = "resize splits if window got resized";
      event = ["VimResized"];
      callback = mkLuaInline ''
        function()
          local current_tab = vim.fn.tabpagenr()
          vim.cmd("tabdo wincmd =")
          vim.cmd("tabnext " .. current_tab)
        end
      '';
    }

    {
      desc = "go to last loc when opening a buffer";
      event = ["BufReadPost"];
      callback = mkLuaInline ''
        function(event)
          local exclude = { "gitcommit" }
          local buf = event.buf
          if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf]._last_loc then
            return
          end
          vim.b[buf]._last_loc = true
          local mark = vim.api.nvim_buf_get_mark(buf, '"')
          local lcount = vim.api.nvim_buf_line_count(buf)
          if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
          end
        end
      '';
    }

    {
      desc = "close some filetypes with <q>";
      event = ["FileType"];
      pattern = [
        "PlenaryTestPopup"
        "checkhealth"
        "dbout"
        "gitsigns-blame"
        "grug-far"
        "help"
        "lspinfo"
        "neotest-output"
        "neotest-output-panel"
        "neotest-summary"
        "notify"
        "qf"
        "spectre_panel"
        "startuptime"
        "tsplayground"
      ];
      callback = mkLuaInline ''
        function(event)
          vim.bo[event.buf].buflisted = false
          vim.schedule(function()
            vim.keymap.set("n", "q", function()
              vim.cmd("close")
              pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
            end, {
              buffer = event.buf,
              silent = true,
              desc = "Quit buffer",
            })
          end)
        end
      '';
    }

    {
      desc = "make it easier to close man-files when opened inline";
      event = ["FileType"];
      pattern = ["man"];
      callback = mkLuaInline ''
        function(event)
          vim.bo[event.buf].buflisted = false
        end
      '';
    }
  ];
}
