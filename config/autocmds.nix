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
  ];
}
