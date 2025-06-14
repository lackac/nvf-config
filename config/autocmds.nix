{ lib, ... }:
let
  inherit (lib.generators) mkLuaInline;
in {
  vim.augroups = [
    {
      name = "StartupPicker";
      clear = true;
    }
  ];

  vim.autocmds = [
    {
      desc = "Check arguments for benefit of next UIEnter autocmd";
      group = "StartupPicker";
      event = ["VimEnter"];
      callback = mkLuaInline ''
        function()
          for _, v in pairs(vim.v.argv) do
            if v == '-' then
              vim.g.read_from_stdin = 1
              break
            end
          end
        end
      '';
    }
    {
      desc = "Open picker showing most recent files when entering vim";
      group = "StartupPicker";
      event = ["UIEnter"];
      callback = mkLuaInline ''
        function()
          if
            vim.fn.argc() == 0
            and vim.api.nvim_buf_get_name(0) == ""
            and vim.g.read_from_stdin == nil
          then
            require('fzf-lua').oldfiles({ cwd_only = true })
          end
        end
      '';
    }

    {
      desc = "Effectively disable the command line window to prevent opening it accidentally when pressing 'q:'";
      event = ["CmdWinEnter"];
      callback = mkLuaInline ''
        function()
          vim.cmd("quit")
        end
      '';
    }
  ];
}
