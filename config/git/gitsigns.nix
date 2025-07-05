{
  vim.git.gitsigns = {
    enable = true;
    codeActions.enable = true;
    mappings = {
      nextHunk = "]h";
      previousHunk = "[h";
      toggleBlame = null;
      toggleDeleted = null;
    };
  };
}
