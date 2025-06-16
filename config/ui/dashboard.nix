{lib, ...}: let
  inherit (lib.generators) mkLuaInline;
in {
  vim.utility.snacks-nvim.setupOpts.dashboard = {
    sections = [
      {section = "header";}
      {
        icon = " ";
        title = "Recent Files";
        section = "recent_files";
        cwd = true;
        indent = 2;
        padding = 1;
      }
      {
        icon = " ";
        title = "Git Status";
        section = "terminal";
        enabled = mkLuaInline ''function() return Snacks.git.get_root() ~= nil end'';
        cmd = "git status --short --branch --renames";
        height = 8;
        padding = 1;
        ttl = 5 * 60;
        indent = 3;
      }
      {
        section = "keys";
        gap = 1;
        padding = 1;
      }
    ];

    preset = {
      keys = [
        {
          icon = " ";
          key = "f";
          desc = "Find File";
          action = "<leader><space>";
        }
        {
          icon = " ";
          key = "n";
          desc = "New File";
          action = ":ene | startinsert";
        }
        {
          icon = " ";
          key = "g";
          desc = "Find Text";
          action = "<leader>sg";
        }
        {
          icon = " ";
          key = "r";
          desc = "Recent Files";
          action = "<leader>fr";
        }
        {
          icon = " ";
          key = "c";
          desc = "Config";
          action = "<leader>fc";
        }
        {
          icon = " ";
          key = "q";
          desc = "Quit";
          action = ":qa";
        }
      ];
    };
  };
}
