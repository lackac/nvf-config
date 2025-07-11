{lib, ...}: let
  inherit (lib.generators) mkLuaInline;
in {
  vim.statusline.lualine.setupOpts = {
    tabline = {
      lualine_a = [
        (mkLuaInline ''
          {
            function()
              local width = math.min(40, vim.o.columns / 3)
              return libui.root(width)
            end
          }
        '')
      ];

      lualine_b = [
        (mkLuaInline ''
          {
            'buffers',
            show_filename_only = true,   -- Shows shortened relative path when set to false.
            hide_filename_extension = false,   -- Hide filename extension when set to true.
            show_modified_status = true, -- Shows indicator when the buffer is modified.

            max_length = function()
              return vim.o.columns - math.min(40, vim.o.columns / 3) - 4
            end,

            filetype_names = {
              snacks_dashboard = 'Dashboard',
              snacks_picker_input = 'Picker',
              snacks_picker_preview = 'Picker',
              snacks_picker_list = 'Picker',
            }, -- Shows specific buffer name for that filetype ( { `filetype` = `buffer_name`, ... } )

            buffers_color = {
              -- Same values as the general color option can be used here.
              active = 'lualine_b_normal',     -- Color for active buffer.
              inactive = 'lualine_b_inactive', -- Color for inactive buffer.
            },

            symbols = {
              modified = ' ●',      -- Text to show when the buffer is modified
              alternate_file = '^', -- Text to show to identify the alternate file
              directory =  '',     -- Text to show when the buffer is a directory
            },

            component_separators = { left = "|", right = "" },
            section_separators = { left = "", right = "" },
          }
        '')
      ];

      lualine_z = [
        (mkLuaInline ''
          {
            'tabs',

            -- only show tabs if there are more than 1
            cond = function() return #vim.fn.gettabinfo() > 1 end,

            max_length = function() return vim.o.columns / 5 end,
            mode = 0,

            tabs_color = {
              active = 'lualine_z_normal',     -- Color for active tab.
              inactive = 'lualine_z_inactive', -- Color for inactive tab.
            },

            show_modified_status = false,

            component_separators = { left = "|", right = "" },
            section_separators = { left = "", right = "" },
          }
        '')
      ];
    };
  };
}
