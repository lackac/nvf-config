{ lib, ... }:
let
  inherit (lib.nvim.binds) mkKeymap;
in {
  vim.fzf-lua = {
    enable = true;
    profile = "default-title";
  };

  vim.keymaps = [
    # Main
    (mkKeymap "n" "<leader><space>" "<cmd>FzfLua files<cr>" {desc = "Find Files";})
    (mkKeymap "n" "<leader>/" "<cmd>FzfLua live_grep<cr>" {desc = "Live Grep";})
    (mkKeymap "n" "<leader>:" "<cmd>FzfLua command_history<cr>" {desc = "Command History";})
    (mkKeymap "n" "<leader>." "<cmd>FzfLua resume<cr>" {desc = "Resume last FzfLua";})

    # Find
    (mkKeymap "n" "<leader>fb" "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>" {desc = "Find Buffers";})
    (mkKeymap "n" "<leader>fc" "<cmd>FzfLua files cwd=~/Code/lackac/nvf-config<cr>" {desc = "Find Config Files";})
    (mkKeymap "n" "<leader>fg" "<cmd>FzfLua git_files<cr>" {desc = "Find Files (git-files)";})
    (mkKeymap "n" "<leader>fr" "<cmd>FzfLua oldfiles<cr>" {desc = "Recent Files";})

    # Git
    (mkKeymap "n" "<leader>gc" "<cmd>FzfLua git_commits<CR>" {desc = "Git Commits";})
    (mkKeymap "n" "<leader>gs" "<cmd>FzfLua git_status<CR>" {desc = "Git Status";})
    (mkKeymap "n" "<leader>gC" "<cmd>FzfLua git_bcommits<cr>" {desc = "Buffer commits";})
    (mkKeymap "n" "<leader>gb" "<cmd>FzfLua git_blame<cr>" {desc = "Git Blame";})
    (mkKeymap "n" "<leader>gB" "<cmd>FzfLua git_branches<cr>" {desc = "Git Branches";})
    (mkKeymap "n" "<leader>gS" "<cmd>FzfLua git_stash<cr>" {desc = "Git Stash";})

    # Search
    (mkKeymap "n" ''<leader>s"'' "<cmd>FzfLua registers<cr>" {desc = "Search Registers";})
    (mkKeymap "n" "<leader>sa" "<cmd>FzfLua autocmds<cr>" {desc = "Search Auto Commands";})
    (mkKeymap "n" "<leader>sb" "<cmd>FzfLua grep_curbuf<cr>" {desc = "Search in Buffer";})
    (mkKeymap "n" "<leader>sc" "<cmd>FzfLua commands<cr>" {desc = "Search Commands";})
    (mkKeymap "n" "<leader>sd" "<cmd>FzfLua diagnostics_document<cr>" {desc = "Search Document Diagnostics";})
    (mkKeymap "n" "<leader>sD" "<cmd>FzfLua diagnostics_workspace<cr>" {desc = "Search Workspace Diagnostics";})
    (mkKeymap "n" "<leader>sg" "<cmd>FzfLua live_grep<cr>" {desc = "Live Grep";})
    (mkKeymap "n" "<leader>sh" "<cmd>FzfLua help_tags<cr>" {desc = "Search Help Pages";})
    (mkKeymap "n" "<leader>sH" "<cmd>FzfLua highlights<cr>" {desc = "Search Highlight Groups";})
    (mkKeymap "n" "<leader>sj" "<cmd>FzfLua jumps<cr>" {desc = "Jumplist";})
    (mkKeymap "n" "<leader>sk" "<cmd>FzfLua keymaps<cr>" {desc = "Search Keymaps";})
    (mkKeymap "n" "<leader>sl" "<cmd>FzfLua loclist<cr>" {desc = "Search Location List";})
    (mkKeymap "n" "<leader>sM" "<cmd>FzfLua man_pages<cr>" {desc = "Search Man Pages";})
    (mkKeymap "n" "<leader>sm" "<cmd>FzfLua marks<cr>" {desc = "Search Marks";})
    (mkKeymap "n" "<leader>sq" "<cmd>FzfLua quickfix<cr>" {desc = "Search Quickfix List";})
    (mkKeymap "n" "<leader>sw" "<cmd>FzfLua grep_cword<cr>" {desc = "Grep Word Under Cursor";})
    (mkKeymap "v" "<leader>sw" "<cmd>FzfLua grep_visual<cr>" {desc = "Grep Selection";})
    (mkKeymap "n" "<leader>sW" "<cmd>FzfLua grep_cWORD<cr>" {desc = "Grep Word Under Cursor";})
  ];
}
