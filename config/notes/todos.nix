{
  vim.notes.todo-comments = {
    enable = true;
    setupOpts = {
      highlight.pattern = ".*<(KEYWORDS)(\\([^\\)]*\\))?";
      search.pattern = "\\b(KEYWORDS)(\\([^\\)]*\\))?";
    };
    mappings = {
      quickFix = null;
      telescope = null;
      trouble = null;
    };
  };
}
