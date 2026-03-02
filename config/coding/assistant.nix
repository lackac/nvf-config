{ lib, pkgs, ... }:
let
  inherit (lib.nvim.binds) mkKeymap;
in
{
  vim.extraPlugins.opencode = {
    package = pkgs.vimPlugins.opencode-nvim;
    setup = builtins.readFile ./opencode.lua;
  };

  vim.keymaps = [
    (mkKeymap [ "n" "x" ] "<leader>aa"
      ''function() require("opencode").ask("@this: ", { submit = true }) end''
      {
        desc = "Ask OpenCode";
        lua = true;
        silent = true;
      }
    )
    (mkKeymap [ "n" "x" ] "<leader>a." ''function() require("opencode").select() end'' {
      desc = "OpenCode Actions";
      lua = true;
      silent = true;
    })
    (mkKeymap [ "n" "x" ] "<leader>ax" ''function() require("opencode").prompt("explain") end'' {
      desc = "Explain With OpenCode";
      lua = true;
      silent = true;
    })
    (mkKeymap "n" "<leader>al" ''function() require("opencode").select_session() end'' {
      desc = "List OpenCode Sessions";
      lua = true;
      silent = true;
    })
    (mkKeymap "n" "<leader>a<Tab>"
      ''
        function()
          local ok_opencode, opencode = pcall(require, "opencode")
          if ok_opencode and type(opencode.command) == "function" then
            opencode.command("agent.cycle")
            return
          end

          local ok_config, config = pcall(require, "opencode.config")
          if not ok_config then
            return
          end

          local server = config.opts and config.opts.server
          if server and type(server.send_tab) == "function" then
            server.send_tab()
          end
        end
      ''
      {
        desc = "Cycle OpenCode Agent";
        lua = true;
        silent = true;
      }
    )
    (mkKeymap "n" "<leader>aS" ''function() require("opencode").command("session.interrupt") end'' {
      desc = "Stop OpenCode Run";
      lua = true;
      silent = true;
    })
    (mkKeymap "n" "<leader>as"
      ''
        function()
          local ok, config = pcall(require, "opencode.config")
          if not ok then
            return
          end

          local server = config.opts and config.opts.server
          if server and type(server.start_focus) == "function" then
            server.start_focus()
          else
            require("opencode").start()
          end
        end
      ''
      {
        desc = "Start OpenCode Pane";
        lua = true;
        silent = true;
      }
    )
    (mkKeymap "n" "<leader>aK" ''function() require("opencode").stop() end'' {
      desc = "Stop OpenCode Pane";
      lua = true;
      silent = true;
    })
    (mkKeymap [ "n" "x" ] "<C-x>"
      ''
        function()
          local ok, config = pcall(require, "opencode.config")
          if not ok then
            return
          end

          local server = config.opts and config.opts.server
          if server and type(server.send_prefix) == "function" then
            server.send_prefix()
          end
        end
      ''
      {
        desc = "OpenCode Prefix (tmux)";
        lua = true;
        silent = true;
      }
    )
  ];
}
