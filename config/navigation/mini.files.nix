{lib, ...}: let
  inherit (lib.nvim.binds) mkKeymap;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryBefore;
in {
  vim = {
    mini.files = {
      enable = true;
      setupOpts = {
        content = {
          filter = mkLuaInline ''function(fs_entry) return not vim.startswith(fs_entry.name, '.') end'';
        };
        mappings = {
          go_in = "L";
          go_in_plus = "<cr>";
          go_out = "-";
          go_out_plus = "<esc>";
        };
      };
    };

    keymaps = [
      (mkKeymap "n" "-" "function() require('mini.files').open(vim.api.nvim_buf_get_name(0), true, MiniFiles.helpers.current_config) end" {
        desc = "Open parent directory";
        lua = true;
        silent = true;
      })
      (mkKeymap "n" "<leader>F" "function() require('mini.files').open() end" {
        desc = "Open mini.files";
        lua = true;
        silent = true;
      })
    ];

    luaConfigRC.minifiles_helpers = entryBefore ["autocmds"] ''
      MiniFiles.helpers = {
        show_dotfiles = false,

        filter_show = function(fs_entry) return true end,

        filter_hide = MiniFiles.config.content.filter,

        current_config = { content = { filter = MiniFiles.config.content.filter } },

        toggle_dotfiles = function()
          MiniFiles.helpers.show_dotfiles = not MiniFiles.helpers.show_dotfiles
          local new_filter = MiniFiles.helpers.show_dotfiles and MiniFiles.helpers.filter_show or MiniFiles.helpers.filter_hide
          MiniFiles.helpers.current_config = { content = { filter = new_filter } }
          MiniFiles.refresh(MiniFiles.helpers.current_config)
        end,

        map_split = function(buf_id, lhs, direction)
          local rhs = function()
            -- Make new window and set it as target
            local cur_target = MiniFiles.get_explorer_state().target_window
            local new_target = vim.api.nvim_win_call(cur_target, function()
              vim.cmd(direction .. ' split')
              return vim.api.nvim_get_current_win()
            end)

            MiniFiles.set_target_window(new_target)
            MiniFiles.go_in()
          end

          local desc = 'Open in ' .. direction .. ' split'
          vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
        end,

        set_cwd = function()
          local path = (MiniFiles.get_fs_entry() or {}).path
          if path == nil then return vim.notify('Cursor is not on valid entry') end
          vim.fn.chdir(vim.fs.dirname(path))
        end,

        yank_path = function()
          local path = (MiniFiles.get_fs_entry() or {}).path
          if path == nil then return vim.notify('Cursor is not on valid entry') end
          vim.fn.setreg(vim.v.register, path)
        end,

        ui_open = function() vim.ui.open(MiniFiles.get_fs_entry().path) end
      }
    '';

    autocmds = [
      {
        desc = "more mini.files buffer mappings";
        event = ["User"];
        pattern = ["MiniFilesBufferCreate"];
        callback = mkLuaInline ''
          function(args)
            local buf_id = args.data.buf_id
            local mf = MiniFiles.helpers

            vim.keymap.set('n', 'g.', mf.toggle_dotfiles, { buffer = buf_id, desc = "Toggle Showing Dotfiles" })

            mf.map_split(buf_id, '<C-s>', 'horizontal')
            mf.map_split(buf_id, '<C-v>', 'vertical')

            vim.keymap.set('n', 'gc', mf.set_cwd,   { buffer = buf_id, desc = 'Set cwd' })
            vim.keymap.set('n', 'gx', mf.ui_open,   { buffer = buf_id, desc = 'OS open' })
            vim.keymap.set('n', 'gy', mf.yank_path, { buffer = buf_id, desc = 'Yank path' })

            vim.keymap.set('n', '<Left>', MiniFiles.go_out, { buffer = buf_id, desc = 'Go up' })
            vim.keymap.set('n', '<Right>', MiniFiles.go_in, { buffer = buf_id, desc = 'Go in' })
          end
        '';
      }

      {
        desc = "trigger Snacks.rename from mini.files";
        event = ["User"];
        pattern = ["MiniFilesActionRename"];
        callback = mkLuaInline ''
          function(event)
            Snacks.rename.on_rename_file(event.data.from, event.data.to)
          end
        '';
      }
    ];
  };
}
