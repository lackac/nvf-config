{
  vim.treesitter = {
    enable = true;

    autotagHtml = true;
    context = {
      enable = true;
      setupOpts = {
        mode = "cursor"; # or "topline"
        max_lines = 3;
      };
    };
    indent.enable = true;
    highlight.enable = true;
    incrementalSelection.enable = true;

    mappings.incrementalSelection = {
      incrementByNode = "<C-S>";
      decrementByNode = "<C-BS>";
      init = null;
      incrementByScope = null;
    };
  };
}
