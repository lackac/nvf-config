{
  vim.ui.smartcolumn = {
    enable = true;
    setupOpts = {
      colorcolumn = ["80" "100" "120"];
      disabled_filetypes = [
        "help"
        "text"
        "markdown"
        "snacks_dashboard"
        "snacks_picker_input"
        "snacks_picker_preview"
        "snacks_picker_list"
      ];
    };
  };
}
