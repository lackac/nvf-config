{lib, ...}: let
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.binds) mkKeymap;

  wkGroup = lhs: group: {
    "@1" = lhs;
    inherit group;
    mode = ["n" "v"];
  };
in {
  vim.binds.whichKey = {
    enable = true;
    setupOpts = {
      preset = "helix";
      spec = [
        (wkGroup "<leader>c" "code")
        (wkGroup "<leader>d" "debug")
        (wkGroup "<leader>dp" "profiler")
        (wkGroup "<leader>f" "file/find")
        (wkGroup "<leader>g" "git")
        (wkGroup "<leader>gh" "hunks")
        (wkGroup "<leader>q" "quit/session")
        (wkGroup "<leader>s" "search")
        ((wkGroup "<leader>u" "ui")
          // {
            icon = {
              icon = "󰙵 ";
              color = "cyan";
            };
          })
        ((wkGroup "<leader>x" "diagnostics/quickfix")
          // {
            icon = {
              icon = "󱖫 ";
              color = "green";
            };
          })
        (wkGroup "[" "prev")
        (wkGroup "]" "next")
        (wkGroup "g" "goto")
        (wkGroup "gs" "surround")
        (wkGroup "z" "fold")
        ((wkGroup "<leader>b" "buffer") // {expand = mkLuaInline ''function() return require("which-key.extras").expand.buf() end'';})
        ((wkGroup "<leader>w" "windows")
          // {
            proxy = "<c-w>";
            expand = mkLuaInline ''function() return require("which-key.extras").expand.win() end'';
          })
      ];
    };

    # disable groups setup by nvf
    register = {
      "<leader>x" = null;
      "<leader>lw" = null;
    };
  };

  # most of these keymaps are borrowed from old configs and things I liked while using LazyVim
  vim.keymaps = [
    # which-key related
    (mkKeymap "n" "<leader>?" ''function() require("which-key").show({ global = false }) end'' {
      desc = "Buffer Keymaps (which-key)";
      lua = true;
    })
    (mkKeymap "n" "<c-w><space>" ''function() require("which-key").show({ keys = "<c-w>", loop = true }) end'' {
      desc = "Window Hydra Mode (which-key)";
      lua = true;
    })

    # better up/down
    (mkKeymap ["n" "x"] "j" "v:count == 0 ? 'gj' : 'j'" {
      desc = "Down";
      expr = true;
      silent = true;
    })
    (mkKeymap ["n" "x"] "<Down>" "v:count == 0 ? 'gj' : 'j'" {
      desc = "Down";
      expr = true;
      silent = true;
    })
    (mkKeymap ["n" "x"] "k" "v:count == 0 ? 'gk' : 'k'" {
      desc = "Up";
      expr = true;
      silent = true;
    })
    (mkKeymap ["n" "x"] "<Up>" "v:count == 0 ? 'gk' : 'k'" {
      desc = "Up";
      expr = true;
      silent = true;
    })

    # buffers
    (mkKeymap "n" "<S-h>" "<cmd>bprevious<cr>" {desc = "Prev Buffer";})
    (mkKeymap "n" "<S-l>" "<cmd>bnext<cr>" {desc = "Next Buffer";})
    (mkKeymap "n" "[b" "<cmd>bprevious<cr>" {desc = "Prev Buffer";})
    (mkKeymap "n" "]b" "<cmd>bnext<cr>" {desc = "Next Buffer";})
    (mkKeymap "n" "<leader>bb" "<cmd>e #<cr>" {desc = "Switch to Other Buffer";})
    (mkKeymap "n" "<leader>`" "<cmd>e #<cr>" {desc = "Switch to Other Buffer";})
    (mkKeymap "n" "<leader>bd" ''function() Snacks.bufdelete() end'' {
      desc = "Delete Buffer";
      lua = true;
    })
    (mkKeymap "n" "<leader>bo" ''function() Snacks.bufdelete.other() end'' {
      desc = "Delete Other Buffers";
      lua = true;
    })
    (mkKeymap "n" "<leader>bD" "<cmd>:bd<cr>" {desc = "Delete Buffer and Window";})

    # clear search and stop snippet on escape
    (mkKeymap ["i" "n" "s"] "<esc>" ''
        function()
          vim.cmd("nohlsearch")
          -- TODO LazyVim.cmp.actions.snippet_stop()
          return "<esc>"
        end
      '' {
        expr = true;
        desc = "Escape and Clear hlsearch";
        lua = true;
      })

    # Clear search, diff update and redraw
    # taken from runtime/lua/_editor.lua
    (mkKeymap "n" "<leader>ur" "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>" {desc = "Redraw / Clear hlsearch / Diff Update";})

    # https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
    (mkKeymap "n" "n" "'Nn'[v:searchforward].'zv'" {
      expr = true;
      desc = "Next Search Result";
    })
    (mkKeymap "x" "n" "'Nn'[v:searchforward]" {
      expr = true;
      desc = "Next Search Result";
    })
    (mkKeymap "o" "n" "'Nn'[v:searchforward]" {
      expr = true;
      desc = "Next Search Result";
    })
    (mkKeymap "n" "N" "'nN'[v:searchforward].'zv'" {
      expr = true;
      desc = "Prev Search Result";
    })
    (mkKeymap "x" "N" "'nN'[v:searchforward]" {
      expr = true;
      desc = "Prev Search Result";
    })
    (mkKeymap "o" "N" "'nN'[v:searchforward]" {
      expr = true;
      desc = "Prev Search Result";
    })

    # Add undo break-points
    (mkKeymap "i" "," ",<c-g>u" {})
    (mkKeymap "i" "." ".<c-g>u" {})
    (mkKeymap "i" ";" ";<c-g>u" {})

    # keywordprg
    (mkKeymap "n" "<leader>K" "<cmd>norm! K<cr>" {desc = "Keywordprg";})

    # commenting
    (mkKeymap "n" "gco" "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>" {desc = "Add Comment Below";})
    (mkKeymap "n" "gcO" "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>" {desc = "Add Comment Above";})

    # new file
    (mkKeymap "n" "<leader>fn" "<cmd>enew<cr>" {desc = "New File";})

    # scratch file
    (mkKeymap "n" "<leader>," ''function() Snacks.scratch() end'' {
      desc = "Toggle Scratch Buffer";
      lua = true;
    })
    (mkKeymap "n" "<leader>S" ''function() Snacks.scratch.select() end'' {
      desc = "Select Scratch Buffer";
      lua = true;
    })

    # location list
    (mkKeymap "n" "<leader>xl" ''
        function()
          local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
          if not success and err then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      '' {
        desc = "Location List";
        lua = true;
      })

    # quickfix list
    (mkKeymap "n" "<leader>xq" ''
        function()
          local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
          if not success and err then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      '' {
        desc = "Quickfix List";
        lua = true;
      })

    (mkKeymap "n" "[q" ''
        function()
          if require("trouble").is_open() then
            require("trouble").prev({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end
      '' {
        desc = "Previous Trouble/Quickfix Item";
        lua = true;
      })
    (mkKeymap "n" "]q" ''
        function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end
      '' {
        desc = "Next Trouble/Quickfix Item";
        lua = true;
      })

    # diagnostic
    (mkKeymap "n" "<leader>cd" ''vim.diagnostic.open_float'' {
      desc = "Line Diagnostics";
      lua = true;
    })
    (mkKeymap "n" "]d" ''vim.diagnostic.goto_next'' {
      desc = "Next Diagnostic";
      lua = true;
    })
    (mkKeymap "n" "[d" ''vim.diagnostic.goto_prev'' {
      desc = "Prev Diagnostic";
      lua = true;
    })
    (mkKeymap "n" "]e" ''function() vim.diagnostic.goto_next({ severity = "ERROR" }) end'' {
      desc = "Next Error";
      lua = true;
    })
    (mkKeymap "n" "[e" ''function() vim.diagnostic.goto_prev({ severity = "ERROR" }) end'' {
      desc = "Prev Error";
      lua = true;
    })
    (mkKeymap "n" "]w" ''function() vim.diagnostic.goto_next({ severity = "WARN" }) end'' {
      desc = "Next Warning";
      lua = true;
    })
    (mkKeymap "n" "[w" ''function() vim.diagnostic.goto_prev({ severity = "WARN" }) end'' {
      desc = "Prev Warning";
      lua = true;
    })

    # git browse
    (mkKeymap ["n" "x"] "<leader>gB" ''function() Snacks.gitbrowse() end'' {
      desc = "Git Browse (open)";
      lua = true;
    })
    (mkKeymap ["n" "x"] "<leader>gY" ''
        function()
          Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
        end
      '' {
        desc = "Git Browse (copy)";
        lua = true;
      })

    # quit
    (mkKeymap "n" "<leader>qq" "<cmd>qa<cr>" {desc = "Quit All";})

    # highlights under cursor
    (mkKeymap "n" "<leader>ui" ''vim.show_pos'' {
      desc = "Inspect Pos";
      lua = true;
    })
    (mkKeymap "n" "<leader>uI" ''
        function()
          vim.treesitter.inspect_tree()
          vim.api.nvim_input("I")
        end
      '' {
        desc = "Inspect Tree";
        lua = true;
      })
    (mkKeymap "n" "]]" ''function() Snacks.words.jump(vim.v.count1) end'' {
      desc = "Next Reference";
      lua = true;
    })
    (mkKeymap "n" "[[" ''function() Snacks.words.jump(-vim.v.count1) end'' {
      desc = "Prev Reference";
      lua = true;
    })

    # windows
    (mkKeymap "n" "<leader>-" "<C-W>s" {
      desc = "Split Window Below";
      noremap = false;
    })
    (mkKeymap "n" "<leader>|" "<C-W>v" {
      desc = "Split Window Right";
      noremap = false;
    })
    (mkKeymap "n" "<leader>wd" "<C-W>c" {
      desc = "Delete Window";
      noremap = false;
    })
  ];
}
