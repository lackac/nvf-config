{lib, ...}: let
  inherit (lib.nvim.binds) mkKeymap;

  mkPickerMap = key: body: desc:
    mkKeymap "n" key "function() ${body} end" {
      inherit desc;
      lua = true;
    };
in {
  vim.keymaps = [
    # Main
    (mkPickerMap "<leader><space>" "Snacks.picker.smart()" "Smart Find Files")
    (mkPickerMap "<leader>." "Snacks.picker.resume()" "Resume")
    (mkPickerMap "<leader>/" "Snacks.picker.grep()" "Grep")
    (mkPickerMap "<leader>:" "Snacks.picker.command_history()" "Command History")
    (mkPickerMap "<leader>n" "Snacks.picker.notifications()" "Notification History")
    (mkPickerMap "<leader>e" "Snacks.explorer()" "File Explorer")

    # Find
    (mkPickerMap "<leader>fb" "Snacks.picker.buffers()" "Buffers")
    (mkPickerMap "<leader>fc" "Snacks.picker.files({ cwd = '~/Code/lackac/nvf-config' })" "Find Config File")
    (mkPickerMap "<leader>ff" "Snacks.picker.files()" "Find Files")
    (mkPickerMap "<leader>fg" "Snacks.picker.git_files()" "Find Git Files")
    (mkPickerMap "<leader>fp" "Snacks.picker.projects()" "Projects")
    (mkPickerMap "<leader>fP" "Snacks.picker.pickers()" "Pickers")
    (mkPickerMap "<leader>fr" "Snacks.picker.recent({ filter = { cwd = true } })" "Recent")
    (mkPickerMap "<leader>fR" "Snacks.picker.recent()" "Recent Global")

    # Git
    (mkPickerMap "<leader>gb" "Snacks.picker.git_branches()" "Git Branches")
    (mkPickerMap "<leader>gl" "Snacks.picker.git_log()" "Git Log")
    (mkPickerMap "<leader>gL" "Snacks.picker.git_log_line()" "Git Log Line")
    (mkPickerMap "<leader>gs" "Snacks.picker.git_status()" "Git Status")
    (mkPickerMap "<leader>gS" "Snacks.picker.git_stash()" "Git Stash")
    (mkPickerMap "<leader>gd" "Snacks.picker.git_diff()" "Git Diff (Hunks)")
    (mkPickerMap "<leader>gf" "Snacks.picker.git_log_file()" "Git Log File")

    # Search
    (mkPickerMap ''<leader>s"'' "Snacks.picker.registers()" "Registers")
    (mkPickerMap "<leader>s/" "Snacks.picker.search_history()" "Search History")
    (mkPickerMap "<leader>sa" "Snacks.picker.autocmds()" "Autocmds")
    (mkPickerMap "<leader>sb" "Snacks.picker.lines()" "Buffer Lines")
    (mkPickerMap "<leader>sB" "Snacks.picker.grep_buffers()" "Grep Open Buffers")
    (mkPickerMap "<leader>sc" "Snacks.picker.commands()" "Commands")
    (mkPickerMap "<leader>sd" "Snacks.picker.diagnostics()" "Diagnostics")
    (mkPickerMap "<leader>sD" "Snacks.picker.diagnostics_buffer()" "Buffer Diagnostics")
    (mkPickerMap "<leader>sg" "Snacks.picker.grep()" "Grep")
    (mkPickerMap "<leader>sh" "Snacks.picker.help()" "Help Pages")
    (mkPickerMap "<leader>sH" "Snacks.picker.highlights()" "Highlights")
    (mkPickerMap "<leader>si" "Snacks.picker.icons()" "Icons")
    (mkPickerMap "<leader>sj" "Snacks.picker.jumps()" "Jumps")
    (mkPickerMap "<leader>sk" "Snacks.picker.keymaps()" "Keymaps")
    (mkPickerMap "<leader>sl" "Snacks.picker.loclist()" "Location List")
    (mkPickerMap "<leader>sm" "Snacks.picker.marks()" "Marks")
    (mkPickerMap "<leader>sM" "Snacks.picker.man()" "Man Pages")
    (mkPickerMap "<leader>sq" "Snacks.picker.qflist()" "Quickfix List")
    (mkPickerMap "<leader>st" "Snacks.picker.todo_comments()" "Todo")

    (mkPickerMap "<leader>su" "Snacks.picker.undo()" "Undo History")
    ((mkPickerMap "<leader>sw" "Snacks.picker.grep_word()" "Visual selection or word") // {mode = ["n" "x"];})

    # LSP
    (mkPickerMap "gd" "Snacks.picker.lsp_definitions()" "Goto Definition")
    (mkPickerMap "gD" "Snacks.picker.lsp_declarations()" "Goto Declaration")
    ((mkPickerMap "gr" "Snacks.picker.lsp_references()" "References") // {nowait = true;})
    (mkPickerMap "gI" "Snacks.picker.lsp_implementations()" "Goto Implementation")
    (mkPickerMap "gy" "Snacks.picker.lsp_type_definitions()" "Goto T[y]pe Definition")
    (mkPickerMap "<leader>ss" "Snacks.picker.lsp_symbols()" "LSP Symbols")
    (mkPickerMap "<leader>sS" "Snacks.picker.lsp_workspace_symbols()" "LSP Workspace Symbols")
  ];
}
